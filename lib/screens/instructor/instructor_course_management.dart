import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/components/instructor/instructor_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

// ignore: must_be_immutable
class InstructorCourseManagementScreen extends StatefulWidget {
  const InstructorCourseManagementScreen({super.key, required this.userId});

  final String userId;

  @override
  State<InstructorCourseManagementScreen> createState() =>
      _InstructorCourseManagementScreenState();
}

class _InstructorCourseManagementScreenState
    extends State<InstructorCourseManagementScreen> {
  String? selectedCourse;

  Uint8List? fileBytes;
  String? fileName;

  bool uploadOk = true;

  final formKey = GlobalKey<FormState>();

  late final Stream<QuerySnapshot> courseStream;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['pdf', 'pptx', 'ppt'],
        type: FileType.custom);

    if (result != null) {
      setState(() {
        fileBytes = result.files.first.bytes!;
        fileName = result.files.first.name;
      });
    }
  }

  void addCourseOutline() async {
    // VALIDATE COURSE
    if (!formKey.currentState!.validate()) {
      return;
    }

    // VALIDATE SYLLABUS
    if (fileName == null) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: const Text('Please select a syllabus file.'),
          actions: [
            TextButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );

      return;
    }

    setState(() {
      uploadOk = false;
    });

    // QUERY EXISTING COURSE OUTLINES WITH THE SAME SELECTED COURSE CODE AND INSTRUCTOR ID
    final querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('courseCode', isEqualTo: selectedCourse)
        .where('instructorId', isEqualTo: widget.userId)
        .get();

    // DETERMINE VERSION NUMBER
    int newVersion = 1;
    if (querySnapshot.docs.isNotEmpty) {
      final versions = querySnapshot.docs.map((doc) {
        return doc['version'] ?? 1; // DEFAULT TO VERSION 1 IF NOT SET
      }).toList();
      newVersion = versions.reduce((a, b) => a > b ? a : b) + 1;
    }

    // UPLOAD FILE TO STORAGE AND GET DOWNLOAD URL
    final downloadUrl = await uploadFile();

    // SAVE TO DATABASE
    await FirebaseFirestore.instance.collection('courses').add({
      'syllabus': downloadUrl,
      'courseCode': selectedCourse,
      'instructorId': widget.userId,
      'version': newVersion,
      'timeStamp': FieldValue.serverTimestamp(),
    }).then(
      (_) {
        final tempSelectedCourse =
            courseList.firstWhere((element) => element.code == selectedCourse);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: Text(
                '${tempSelectedCourse.code} - ${tempSelectedCourse.title} Course Outline Successfully Added!'),
            actions: [
              TextButton(
                  onPressed:
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
                  child: const Text('Dismiss'))
            ],
          ),
        );

        setState(() {
          selectedCourse = null;
          fileName = null;
          fileBytes = null;
          uploadOk = true;
        });
      },
    );
  }

  Future<String> uploadFile() async {
    try {
      final timeStamp = DateTime.now().microsecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('courses/syllabus/$timeStamp-$fileName');
      final uploadTask = storageRef.putData(fileBytes!);

      final snapshot = await uploadTask.whenComplete(() {});

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload PDF: $e');
      throw Exception('Error uploading PDF');
    }
  }

  void openCourseLessonManagementScreen(String documentId) {
    // TO DO
    print(documentId);
  }

  @override
  void initState() {
    super.initState();
    courseStream = FirebaseFirestore.instance
        .collection('courses')
        .where('instructorId', isEqualTo: widget.userId)
        // .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: InstructorDrawer(userId: widget.userId),
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: InstructorAppbar(),
      ),
      body: Center(
        child: SizedBox(
          width: 1050,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ADD NEW COURSE OUTLINE
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add a New Course Outline'),
                      const Gap(5),
                      Form(
                        key: formKey,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // COURSE DROPDOWN
                            SizedBox(
                              width: 375,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                  labelText: selectedCourse == null
                                      ? 'Select Course' // IF NO FILE IS SELECTED
                                      : 'Course Selected', // IF THERE IS A FILE SELECTED
                                  border: const OutlineInputBorder(),
                                ),
                                items: courseList
                                    .map((course) => DropdownMenuItem(
                                          value: course.code,
                                          child: Text(
                                              '${course.code} - ${course.title}'), // CODE + TITLE
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCourse = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value == '') {
                                    return 'Please select a course';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const Gap(25),

                            Expanded(
                              child: Row(
                                children: [
                                  // FILE PREVIEW
                                  Flexible(
                                    child: Text(
                                      'Syllabus: ${fileName ?? 'No File Selected'}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const Gap(10),

                                  // FILE PICKER
                                  TextButton.icon(
                                    onPressed: pickFile,
                                    label: Text(fileName == null
                                        ? 'Select File'
                                        : 'Change File'),
                                    icon: const Icon(Icons.attach_file_rounded),
                                  ),
                                  const Gap(25),
                                ],
                              ),
                            ),

                            // ADD BUTTON
                            TextButton(
                              style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(primary),
                                foregroundColor:
                                    WidgetStatePropertyAll(Colors.white),
                              ),
                              onPressed: uploadOk ? addCourseOutline : null,
                              child: uploadOk
                                  ? const Text('Add')
                                  : const CircularProgressIndicator(),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // COURSE LIST
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 1050,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SECTION TITLE
                            const Text('My Course Outlines'),
                            const Gap(10),

                            // COURSE LIST
                            Expanded(
                              child: StreamBuilder(
                                stream: courseStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child:
                                          Text('No course outlines available.'),
                                    );
                                  }

                                  final courses = snapshot.data!.docs;

                                  final documents = snapshot.data!.docs
                                      .map((doc) => doc.id)
                                      .toList();

                                  return ListView.builder(
                                    itemCount: courses.length,
                                    itemBuilder: (context, index) {
                                      final course = courseList.firstWhere(
                                          (c) =>
                                              c.code ==
                                              courses[index]['courseCode']);

                                      return Card(
                                        child: ListTile(
                                          onTap: () =>
                                              openCourseLessonManagementScreen(
                                                  documents[index]),
                                          title: Text(
                                              '${course.code} - ${course.title} v${courses[index]['version']}'),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
