// import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/components/instructor/instructor_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/screens/instructor/instructor_course_lesson_management.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/alert_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
// import 'package:file_picker/file_picker.dart';
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
  // ADD COURSE OUTLINE DATA
  String? selectedCourse;
  String outlineType = 'Create from Scratch';
  String? codeOdysseyCourseOutline;
  String? myCourseOutline;

  // Uint8List? fileBytes;
  // String? fileName;

  // bool uploadOk = true;

  // FORM KEYS
  final createCourseOutlineFormKey = GlobalKey<FormState>();

  // COURSE STREAMS
  late final Stream<QuerySnapshot> courseStream;

  // SERVICES
  final _storageService = FirebaseStorageService();
  final _firestoreService = CloudFirestoreService();
  final _errorService = AlertService();

  // void pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     allowMultiple: false,
  //     // allowedExtensions: ['pdf', 'pptx', 'ppt'],
  //     allowedExtensions: ['pdf'],
  //     type: FileType.custom,
  //   );

  //   if (result != null) {
  //     setState(() {
  //       fileBytes = result.files.first.bytes!;
  //       fileName = result.files.first.name;
  //     });
  //   }
  // }

  void createCourseOutline() async {
    // VALIDATE COURSE
    if (!createCourseOutlineFormKey.currentState!.validate()) {
      return;
    }

    // // VALIDATE SYLLABUS
    // if (fileName == null) {
    //   ScaffoldMessenger.of(context).showMaterialBanner(
    //     MaterialBanner(
    //       content: const Text('Please select a syllabus file.'),
    //       actions: [
    //         TextButton(
    //           onPressed: () =>
    //               ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
    //           child: const Text('Dismiss'),
    //         ),
    //       ],
    //     ),
    //   );

    //   return;
    // }

    // setState(() {
    //   uploadOk = false;
    // });

    if (outlineType == 'Create from Scratch') {
      await _firestoreService
          .createCourseOutline(
        context,
        selectedCourse!,
        widget.userId,
        // fileName!,
        // fileBytes!,
      )
          .then((_) {
        setState(() {
          selectedCourse = null;
          // fileName = null;
          // fileBytes = null;
          // uploadOk = true;
        });
      });
    } else {
      String? templateId;
      if (outlineType == 'From CodeOdyssey') {
        templateId = codeOdysseyCourseOutline;
      } else {
        templateId = myCourseOutline;
      }

      if (templateId == null) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please select a course outline template.',
        );
      }

      await _firestoreService.createCourseOutlineFromTemplate(
        context,
        selectedCourse!,
        widget.userId,
        templateId,
      );
    }
  }

  void openCourseLessonManagementScreen(String documentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorCourseLessonManagement(
          userId: widget.userId,
          courseId: documentId,
        ),
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
              _errorService.showBanner(
                // ignore: use_build_context_synchronously
                context,
                'There was an error deleting $courseTitleWithVersion.',
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
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: InstructorDrawer(userId: widget.userId),
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: InstructorAppbar(userId: widget.userId),
      ),
      body: Center(
        child: SizedBox(
          width: 1080,
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
                      const Text('Create a New Course Outline'),
                      const Gap(5),
                      Form(
                        key: createCourseOutlineFormKey,
                        child: Row(
                          // mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // OUTLINE TYPE
                            Row(
                              children: [
                                // COURSE DROPDOWN
                                SizedBox(
                                  width: 375,
                                  child: DropdownButtonFormField(
                                    decoration: InputDecoration(
                                      labelText: selectedCourse == null
                                          ? 'Select Course' // IF NO FILE IS SELECTED
                                          : 'Course', // IF THERE IS A FILE SELECTED
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
                                const Gap(5),

                                // OUTLINE TYPE
                                SizedBox(
                                  width: 260,
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('Outline Type'),
                                    ),
                                    value: outlineType,
                                    items: [
                                      'Create from Scratch',
                                      'From CodeOdyssey',
                                      'From My Existing Outlines'
                                    ]
                                        .map(
                                          (outlineType) => DropdownMenuItem(
                                            value: outlineType,
                                            child: Text(outlineType),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: selectedCourse == null
                                        ? null
                                        : (value) {
                                            setState(() {
                                              outlineType = value as String;
                                            });
                                          },
                                  ),
                                ),
                                const Gap(5),

                                // FROM CODEODYSSEY TEAM
                                outlineType == 'From CodeOdyssey'
                                    ? FutureBuilder(
                                        future:
                                            _firestoreService.getSimilarCourses(
                                                'W8KspheVoSaL40E0B106cdR5Dsj2',
                                                selectedCourse!),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          final courses = snapshot.data!.docs;

                                          return SizedBox(
                                            width: 310,
                                            child: DropdownButtonFormField(
                                              decoration: InputDecoration(
                                                border:
                                                    const OutlineInputBorder(),
                                                label: Text(
                                                    codeOdysseyCourseOutline ==
                                                            null
                                                        ? 'Select Outline'
                                                        : 'From CodeOdyssey'),
                                              ),
                                              value: codeOdysseyCourseOutline,
                                              items: courses.map(
                                                (course) {
                                                  final courseCode =
                                                      course['courseCode'];
                                                  final courseTitle = courseList
                                                      .firstWhere((course) =>
                                                          course.code ==
                                                          courseCode)
                                                      .title;

                                                  return DropdownMenuItem(
                                                    value: course.id,
                                                    child: Text(courseTitle),
                                                  );
                                                },
                                              ).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  codeOdysseyCourseOutline =
                                                      value!;
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox(),

                                // FROM EXISTING OUTLINES
                                outlineType == 'From My Existing Outlines'
                                    ? FutureBuilder(
                                        future:
                                            _firestoreService.getSimilarCourses(
                                                widget.userId, selectedCourse!),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return SizedBox(
                                              width: 310,
                                              child: DropdownButtonFormField(
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                ),
                                                value: 'Empty',
                                                items: ['Empty']
                                                    .map(
                                                      (empty) =>
                                                          DropdownMenuItem(
                                                        value: empty,
                                                        child: Text(empty),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: null,
                                              ),
                                            );
                                          }

                                          final courses = snapshot.data!.docs;

                                          return SizedBox(
                                            width: 310,
                                            child: DropdownButtonFormField(
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                label: Text('From CodeOdyssey'),
                                              ),
                                              value: codeOdysseyCourseOutline,
                                              items: courses.map(
                                                (course) {
                                                  final courseCode =
                                                      course['courseCode'];
                                                  final courseTitle = courseList
                                                      .firstWhere((course) =>
                                                          course.code ==
                                                          courseCode)
                                                      .title;
                                                  final version =
                                                      course['version'];

                                                  return DropdownMenuItem(
                                                    value: course.id,
                                                    child: Text(
                                                        '$courseCode - $courseTitle v$version'),
                                                  );
                                                },
                                              ).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  codeOdysseyCourseOutline =
                                                      value!;
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox()
                              ],
                            ),
                            const Gap(5),

                            // Expanded(
                            //   child: Row(
                            //     children: [
                            //       // FILE PREVIEW
                            //       Flexible(
                            //         child: Text(
                            //           'Syllabus: ${fileName ?? 'No File Selected'}',
                            //           overflow: TextOverflow.ellipsis,
                            //           maxLines: 1,
                            //         ),
                            //       ),
                            //       const Gap(10),

                            //       // FILE PICKER
                            //       TextButton.icon(
                            //         onPressed: pickFile,
                            //         label: Text(fileName == null
                            //             ? 'Select File'
                            //             : 'Change File'),
                            //         icon: const Icon(Icons.attach_file_rounded),
                            //       ),
                            //       const Gap(25),
                            //     ],
                            //   ),
                            // ),

                            // ADD BUTTON
                            TextButton(
                              style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(primary),
                                foregroundColor:
                                    WidgetStatePropertyAll(Colors.white),
                              ),
                              // onPressed: uploadOk ? addCourseOutline : null,
                              onPressed: createCourseOutline,
                              // child: uploadOk
                              //     ? const Text('Add')
                              //     : const CircularProgressIndicator(),
                              child: const Text('Create'),
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
                    width: 1080,
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
                                              'Date Created: ${courses[index]['timeStamp'] != null ? DateFormat.yMMMMEEEEd().add_jm().format((courses[index]['timeStamp'] as Timestamp).toDate()) : 'Loading...'}'),
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
