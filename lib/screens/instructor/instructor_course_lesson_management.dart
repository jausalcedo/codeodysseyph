import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class InstructorCourseLessonManagement extends StatefulWidget {
  const InstructorCourseLessonManagement({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<InstructorCourseLessonManagement> createState() =>
      _InstructorCourseLessonManagementState();
}

class _InstructorCourseLessonManagementState
    extends State<InstructorCourseLessonManagement> {
  String extractSyllabusName(String syllabusWithTimeStamp) {
    final splitted = syllabusWithTimeStamp.split('-');

    String finalSyllabusName = '';

    for (int i = 1; i < splitted.length; i++) {
      if (i != splitted.length - 1) {
        finalSyllabusName += '${splitted[i]}-';
      } else {
        finalSyllabusName += splitted[i];
      }
    }

    return finalSyllabusName;
  }

  // FORM KEYS
  final lessonFormKey = GlobalKey<FormState>();
  final addBeforeLessonFormKey = GlobalKey<FormState>();

  // LESSON CONTROLLERS
  final lessonTitleController = TextEditingController();
  final lessonDescriptionController = TextEditingController();
  final addBeforeIndexController = TextEditingController();

  // LEARNING MATERIAL THINGS
  String? fileName;
  Uint8List? fileBytes;
  int? numberOfLessons;
  String addWhere = 'Add to Last';

  // SERVICES
  final _firestoreService = CloudFirestoreService();

  void openAddLessonModal() {
    // SHOW MODAL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add New Lesson',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StatefulBuilder(
              builder: (context, setState) => Row(
                children: [
                  DropdownButton(
                    value: addWhere,
                    items: ['Add to Last', 'Add Before']
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        addWhere = value!;
                      });
                    },
                  ),
                  const Gap(5),
                  addWhere == 'Add to Last'
                      ? const SizedBox()
                      : Form(
                          key: addBeforeLessonFormKey,
                          child: SizedBox(
                            width: 115,
                            child: TextFormField(
                              controller: addBeforeIndexController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Before Lesson'),
                              ),
                              textAlign: TextAlign.center,
                              validator: (value) {
                                if (value == null || value == '') {
                                  return 'Required.';
                                }

                                if (int.parse(value) <= 0 ||
                                    int.parse(value) > numberOfLessons!) {
                                  return 'Invalid input.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                  const Gap(10),
                  IconButton(
                    onPressed: () {
                      // CLEAR ALL FIELDS
                      lessonTitleController.clear();
                      lessonDescriptionController.clear();
                      addBeforeIndexController.clear();
                      fileName = null;
                      fileBytes = null;
                      // CLOSE THE MODAL
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                    style: const ButtonStyle(
                      foregroundColor: WidgetStatePropertyAll(Colors.red),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        content: SizedBox(
          width: 750,
          height: 350,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: StatefulBuilder(
              builder: (context, setState) {
                void pickFile() async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
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

                return ListView(
                  children: [
                    Form(
                      key: lessonFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE
                          const Text(
                            'Title:',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            controller: lessonTitleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter lesson title',
                            ),
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Required. Please enter lesson title.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),

                          // DESCRIPTION
                          const Text(
                            'Description:',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            controller: lessonDescriptionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter a short lesson description',
                            ),
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Required. Please enter a short description.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),

                          // LEARNING MATERIAL
                          const Text(
                            'Learning Material:',
                            style: TextStyle(fontSize: 20),
                          ),

                          // FILE NAME
                          Text(
                            fileName ?? 'None Selected',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Gap(10),

                          // SELECT FILE BUTTON
                          ElevatedButton.icon(
                            onPressed: pickFile,
                            label: Text(
                              fileName == null ? 'Select File' : 'Change File',
                            ),
                            icon: const Icon(Icons.attach_file_rounded),
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(primary),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          Center(
            child: TextButton.icon(
              onPressed: addLesson,
              label: const Text(
                'Add',
                style: TextStyle(fontSize: 18),
              ),
              icon: const Icon(Icons.add),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green[800]),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addLesson() async {
    if (!lessonFormKey.currentState!.validate()) {
      return;
    }

    if (addWhere == 'Add Before') {
      if (!addBeforeLessonFormKey.currentState!.validate()) {
        return;
      }
    }

    if (fileName == null) {
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please select a learning material.',
        onConfirmBtnTap: Navigator.of(context).pop,
      );
    }

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    await _firestoreService
        .addLesson(
      context: context,
      courseId: widget.courseId,
      fileName: fileName!,
      fileBytes: fileBytes!,
      lessonTitle: lessonTitleController.text,
      lessonDescription: lessonDescriptionController.text,
      insertAtIndex: addWhere == 'Add Before'
          ? int.parse(addBeforeIndexController.text) - 1
          : null,
    )
        .then((_) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    });
  }

  Future<void> deleteLesson(Map<String, dynamic> lesson) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Confirm Delete?\n${lesson['title']}',
      text: 'This action cannot be undone.',
      confirmBtnText: 'Delete',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        // DISMISS CONFIRM BUTTON
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        // SHOW LOADING
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
        );

        await _firestoreService
            .deleteLesson(context, widget.courseId, lesson)
            .then((_) {
          // DISMISS LOADING MODAL
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        });
      },
      showCancelBtn: true,
      cancelBtnText: 'Cancel',
      onCancelBtnTap: Navigator.of(context).pop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: InstructorAppbar(),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final courseData = snapshot.data!.data();

          final course = courseList
              .firstWhere((course) => course.code == courseData!['courseCode']);

          // final String rawSyllabusName =
          //     courseData!['syllabus'].split('/').last;

          // final syllabusName = extractSyllabusName(rawSyllabusName);

          final lessonList = courseData!['lessons'];
          numberOfLessons = lessonList.length;

          return Center(
            child: SizedBox(
              width: 1050,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // COURSE OUTLINE INFO
                      Text(
                        '${course.code} - ${course.title} v${courseData['version']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // TITLE
                          const Text(
                            'Lessons',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          // ADD LESSON BUTTON
                          TextButton.icon(
                            onPressed: openAddLessonModal,
                            label: const Text('Add New Lesson'),
                            icon: const Icon(Icons.add_rounded),
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(primary),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                          )
                        ],
                      ),
                      const Gap(10),

                      // LESSONS LISTVIEW
                      lessonList.length == 0
                          ? const Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                        'You haven\'t added a lesson yet. Click the button above to add your first lesson!'),
                                  ),
                                ],
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: lessonList.length,
                                itemBuilder: (context, index) => Card(
                                  child: ListTile(
                                    title: Text(
                                        'Lesson ${index + 1}: ${lessonList[index]['title']}'),
                                    trailing: IconButton(
                                      onPressed: () =>
                                          deleteLesson(lessonList[index]),
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
