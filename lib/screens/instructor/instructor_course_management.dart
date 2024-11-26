import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/components/instructor/instructor_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/screens/instructor/instructor_course_lesson_management.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

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

  final _storageService = FirebaseStorageService();
  final _firestoreService = CloudFirestoreService();

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      // allowedExtensions: ['pdf', 'pptx', 'ppt'],
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );

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

    await _firestoreService
        .addCourseOutline(
      context,
      selectedCourse!,
      widget.userId,
      fileName!,
      fileBytes!,
    )
        .then((_) {
      setState(() {
        selectedCourse = null;
        fileName = null;
        fileBytes = null;
        uploadOk = true;
      });
    });
  }

  void openCourseLessonManagementScreen(String documentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            InstructorCourseLessonManagement(courseId: documentId),
      ),
    );
  }

  void deleteCourseOutline(String courseId, String courseTitleWithVersion) {
    // CONFIRM DELETION
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Confirm Delete?\n$courseTitleWithVersion',
      text: 'This action cannot be undone.',
      confirmBtnText: 'Delete',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        // DISMISS CONFIRM BUTTON
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        // SHOW LOADING
        QuickAlert.show(context: context, type: QuickAlertType.loading);

        // GET SYLLABUS REFERENCE
        await _firestoreService.getCourseData(courseId).then((result) async {
          final courseData = result.data()!;
          final syllabusRef = courseData['files'];

          // DELETE FROM FIREBASE STORAGE
          // ignore: use_build_context_synchronously
          await _storageService.deleteFile(syllabusRef).then((deleted) async {
            if (deleted) {
              await _firestoreService
                  .deleteCourseOutline(
                      // ignore: use_build_context_synchronously
                      context,
                      courseId,
                      courseTitleWithVersion)
                  .then((_) {
                // DISMISS LOADING
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              });
            } else {
              // DISMISS LOADING
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();

              // SHOW ERROR MESSAGE
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showMaterialBanner(
                MaterialBanner(
                  content: Text(
                      'There was an error deleting $courseTitleWithVersion.'),
                  actions: [
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .hideCurrentMaterialBanner(),
                      child: const Text('Dismiss'),
                    )
                  ],
                ),
              );
            }
          });
        });
      },
      showCancelBtn: true,
      cancelBtnText: 'Cancel',
      onCancelBtnTap: () => Navigator.of(context).pop(),
    );
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
                            const Text(
                              'My Course Outlines',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

                                  final courseIds = snapshot.data!.docs
                                      .map((doc) => doc.id)
                                      .toList();

                                  return ListView.builder(
                                    itemCount: courses.length,
                                    itemBuilder: (context, index) {
                                      final course = courseList.firstWhere(
                                          (c) =>
                                              c.code ==
                                              courses[index]['courseCode']);

                                      final courseTitleWithVersion =
                                          '${course.code} - ${course.title} v${courses[index]['version']}';

                                      return Card(
                                        child: ListTile(
                                          onTap: () =>
                                              openCourseLessonManagementScreen(
                                                  courseIds[index]),
                                          title: Text(courseTitleWithVersion),
                                          subtitle: Text(
                                              'Date Created: ${DateFormat.yMMMMEEEEd().add_jm().format((courses[index]['timeStamp'] as Timestamp).toDate())}'),
                                          trailing: IconButton(
                                            onPressed: () =>
                                                deleteCourseOutline(
                                              courseIds[index],
                                              courseTitleWithVersion,
                                            ),
                                            icon: const Icon(
                                              Icons.delete_rounded,
                                              color: Colors.red,
                                            ),
                                          ),
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
