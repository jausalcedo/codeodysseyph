import 'dart:typed_data';

import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/student/student_exam_laboratory.dart';
import 'package:codeodysseyph/screens/student/student_exam_written.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:disclosure/disclosure.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentClassScreen extends StatefulWidget {
  const StudentClassScreen({
    super.key,
    required this.studentId,
    required this.classCode,
    required this.courseCodeYearBlock,
    required this.courseTitle,
  });

  final String studentId;
  final String classCode;
  final String courseCodeYearBlock;
  final String courseTitle;

  @override
  State<StudentClassScreen> createState() => _StudentClassScreenState();
}

class _StudentClassScreenState extends State<StudentClassScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // TAB ESSENTIALS
  late TabController tabController;
  late TabController performanceTabController;

  // SERVICES
  final _firestoreService = CloudFirestoreService();
  final _storageService = FirebaseStorageService();

  // LESSONS
  int? numberOfLessons;

  int? currentlyOpenLesson;

  // ACTIVITIES

  // OPERATIONS
  Future<void> downloadFile(String learningMaterialPath) async {
    final downloadUrl = await _storageService.storageRef
        .child(learningMaterialPath)
        .getDownloadURL();
    if (!await launchUrl(Uri.parse(downloadUrl))) {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text:
            'There was a problem downloading the learning material. Please try again in a few minutes...',
        confirmBtnText: 'Okay',
        // ignore: use_build_context_synchronously
        onCancelBtnTap: Navigator.of(context).pop,
      );
    }
  }

  void openSubmitActivityModal({
    required int lessonIndex,
    required int activityIndex,
    dynamic activity,
  }) {
    Map<String, dynamic> submissions = activity['submissions'] ?? {};
    List studentSubmission = submissions[widget.studentId] ?? [];
    List activityAttachments = activity['attachments'] ?? [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, setState) {
          void pickFile() async {
            Uint8List? attachmentBytes;
            String? attachmentFileName;

            FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              allowedExtensions: [
                'doc',
                'docx',
                'pdf',
                'txt',
                'md',
                'ppt',
                'pptx',
                'xls',
                'xlsx',
                'csv',
                'java',
                'c',
                'cpp',
                'html',
                'css',
                'js',
                'sql',
                'php',
                'json',
                'xml',
                'png',
                'jpg',
                'jpeg',
              ],
              type: FileType.custom,
            );

            if (result != null) {
              attachmentBytes = result.files.first.bytes!;
              attachmentFileName = result.files.first.name;

              QuickAlert.show(
                // ignore: use_build_context_synchronously
                context: context,
                type: QuickAlertType.loading,
              );

              final attachmentPath = await _storageService.uploadFile(
                'classes/files/',
                attachmentFileName,
                attachmentBytes,
              );

              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();

              setState(() {
                studentSubmission.add({
                  'fileName': attachmentFileName,
                  'attachment': attachmentPath,
                });
              });
            }
          }

          void removeAttachment(int attachmentIndex) async {
            await _storageService
                .deleteFile([studentSubmission[attachmentIndex]['attachment']]);
            setState(() {
              studentSubmission.removeAt(attachmentIndex);
            });
          }

          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lesson ${lessonIndex + 1} - Activity ${activityIndex + 1}',
                ),
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 750,
              child: ListView(
                children: [
                  // DEADLINE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deadline: ${DateFormat.yMMMEd().add_jm().format(activity['closeSchedule'].toDate())}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${activity['maxScore']} points',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // INSTRUCTIONS + POINTS
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${activity['instructions']} ${activityAttachments.isEmpty ? '' : 'Refer to the ${!(activityAttachments.length > 1) ? 'attachment' : 'attachments'} below:'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  activityAttachments.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activityAttachments.length,
                          itemBuilder: (context, index) {
                            final activityAttachment =
                                activityAttachments[index];
                            return Card(
                              child: ListTile(
                                title: Text(activityAttachment['fileName']),
                                trailing: IconButton(
                                  onPressed: () => downloadFile(
                                      activityAttachment['attachment']),
                                  icon: Icon(
                                    Icons.download_rounded,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  const Gap(10),
                  // ATTACH FILE BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Work',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: pickFile,
                        icon: const Icon(Icons.attach_file_rounded),
                        label: const Text("Attach File"),
                      ),
                    ],
                  ),
                  const Gap(10),
                  // STUDENT ATTACHMENT LIST
                  studentSubmission.isEmpty
                      ? const Text('No attachments')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: studentSubmission.length,
                          itemBuilder: (context, index) {
                            final attachment = studentSubmission[index];

                            return Card(
                              child: ListTile(
                                title: Text(attachment['fileName']),
                                trailing: IconButton(
                                  onPressed: () => removeAttachment(index),
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.warning,
                      title: 'Are you sure to submit?',
                      confirmBtnText: 'Yes',
                      onConfirmBtnTap: () => submitActivity(
                        activityIndex: activityIndex,
                        lessonIndex: lessonIndex,
                        attachments: studentSubmission,
                      ),
                      showCancelBtn: true,
                      cancelBtnText: 'Go Back',
                      onCancelBtnTap: Navigator.of(context).pop,
                    );
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void submitActivity({
    required int lessonIndex,
    required int activityIndex,
    dynamic attachments,
  }) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    await _firestoreService.submitActivityAnswer(
      classCode: widget.classCode,
      studentId: widget.studentId,
      lessonIndex: lessonIndex,
      activityIndex: activityIndex,
      attachments: attachments,
    );

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  // ASSESSMENTS

  void goToStudentWrittenExamScreen({
    required int examIndex,
    required dynamic exam,
    required dynamic violations,
  }) async {
    await _firestoreService.initializeExamScore(
      classCode: widget.classCode,
      examIndex: examIndex,
      studentId: widget.studentId,
    );

    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentWrittenExamScreen(
          classCode: widget.classCode,
          exam: exam,
          startTime: DateTime.now(),
          examIndex: examIndex,
          violations: violations,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  void goToStudentLaboratoryExamScreen({
    required dynamic exam,
    required int examIndex,
    required dynamic violations,
  }) async {
    await _firestoreService.initializeExamScore(
      classCode: widget.classCode,
      examIndex: examIndex,
      studentId: widget.studentId,
    );

    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentLaboratoryExamScreen(
          classCode: widget.classCode,
          exam: exam,
          startTime: DateTime.now(),
          examIndex: examIndex,
          violations: violations,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  // ANNOUNCEMENT ESSENTIALS
  final announcementsScrollController = ScrollController();

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (announcementsScrollController.hasClients) {
        announcementsScrollController.animateTo(
          announcementsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    // 4 tabs - Course Work / Assessments / My Grades / Announcements
    performanceTabController = TabController(length: 2, vsync: this);
    // 2 tabs - Course Work / Assessments

    tabController.addListener(() {
      if (tabController.index == tabController.previousIndex) return;

      if (tabController.index == 3) {
        scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: StudentAppbar(),
      ),
      body: Center(
        child: SizedBox(
          width: 1080,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // COURSE CODE YEAR BLOCK
                          Container(
                            width: 225,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 19, 27, 99),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.courseCodeYearBlock,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Gap(10),
                          // JAVA LOGO
                          Image.asset(
                            "assets/images/java-logo.png",
                            width: 50,
                            height: 50,
                          ),
                          // COURSE TITLE
                          Text(
                            widget.courseTitle,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 19, 27, 99),
                            ),
                          ),
                        ],
                      ),
                      // CLASS CODE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.classCode,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: primary,
                              ),
                            ),
                            const Text(
                              'Class Code',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  TabBar(
                    controller: tabController,
                    tabs: const [
                      Tab(text: 'Course Work'),
                      Tab(text: 'Assessments'),
                      Tab(text: 'My Scores'),
                      Tab(text: 'Announcements'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        // COURSE WORK
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lessons:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // LESSON LIST
                              Expanded(
                                child: ListView(
                                  children: [
                                    StreamBuilder(
                                      stream: _firestoreService
                                          .getClassDataStream(widget.classCode),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final classData = snapshot.data!.data();

                                        final lessonList =
                                            classData!['lessons'];
                                        numberOfLessons = lessonList.length;

                                        return DisclosureGroup(
                                          multiple: false,
                                          clearable: true,
                                          children: List<Widget>.generate(
                                            lessonList.length,
                                            (lessonIndex) {
                                              final lesson =
                                                  lessonList[lessonIndex];

                                              final List<dynamic> activities =
                                                  lesson['activities'] ?? [];

                                              final List<dynamic>
                                                  additionalResources =
                                                  lesson['additionalResources'] ??
                                                      [];

                                              return Disclosure(
                                                key: ValueKey(
                                                    'lesson-$lessonIndex'),
                                                wrapper: (state, child) {
                                                  return Card.outlined(
                                                    color: primary,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        color: Colors.black26,
                                                        width: state.closed
                                                            ? 1
                                                            : 2,
                                                      ),
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                header: DisclosureButton(
                                                  child: ListTile(
                                                    title: Text(
                                                      'Lesson ${lessonIndex + 1}: ${lesson['title']}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    trailing:
                                                        const DisclosureIcon(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                divider:
                                                    const Divider(height: 1),
                                                onToggle: (value) {
                                                  if (value == false) {
                                                    currentlyOpenLesson =
                                                        lessonIndex;
                                                  } else {
                                                    currentlyOpenLesson = null;
                                                  }
                                                },
                                                child: Container(
                                                  color: Colors.white,
                                                  width: double.infinity,
                                                  // CONTENT HEIGHT
                                                  height: 400,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // LEARNING MATERIAL
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Learning Material: ${lesson['title']}.pdf',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    WidgetStatePropertyAll(
                                                                        Colors.green[
                                                                            800]),
                                                                foregroundColor:
                                                                    const WidgetStatePropertyAll(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                              onPressed: () =>
                                                                  downloadFile(
                                                                      lesson[
                                                                          'learningMaterial']),
                                                              child: const Row(
                                                                children: [
                                                                  Text(
                                                                      'Download'),
                                                                  Icon(Icons
                                                                      .download_rounded)
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        // ACTIVITIES
                                                        const Text(
                                                          'Activities:',
                                                        ),
                                                        activities.isEmpty
                                                            ? const Text(
                                                                'No activities yet.')
                                                            : SizedBox(
                                                                height: 145,
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      activities
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          activityIndex) {
                                                                    final activity =
                                                                        activities[
                                                                            activityIndex];

                                                                    return Card(
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            'Activity ${activityIndex + 1} (${activity['maxScore']} points)'),
                                                                        trailing:
                                                                            Text(
                                                                          'Open From: ${DateFormat.yMMMEd().add_jm().format(activity['openSchedule'].toDate())}\nUntil: ${DateFormat.yMMMEd().add_jm().format(activity['closeSchedule'].toDate())}',
                                                                          style:
                                                                              const TextStyle(fontSize: 14),
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          openSubmitActivityModal(
                                                                            lessonIndex:
                                                                                lessonIndex,
                                                                            activityIndex:
                                                                                activityIndex,
                                                                            activity:
                                                                                activity,
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                        const Gap(5),

                                                        // ADDITIONAL RESOURCES
                                                        const Text(
                                                          'Additional Resources:',
                                                        ),
                                                        additionalResources
                                                                .isEmpty
                                                            ? const Text(
                                                                'Empty.')
                                                            : SizedBox(
                                                                height: 145,
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      additionalResources
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          Card(
                                                                    child:
                                                                        ListTile(
                                                                      title: Text(
                                                                          additionalResources[index]
                                                                              [
                                                                              'resourceName']),
                                                                      subtitle:
                                                                          Text(
                                                                              'Type: ${additionalResources[index]['resourceTitle']}'),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ASSESSMENTS
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // QUIZZES
                              // QUIZ LIST
                              // Expanded(
                              //   child: ListView(
                              //     children: [
                              //       Card(
                              //         color: primary,
                              //         child: ListTile(
                              //           textColor: Colors.white,
                              //           title: const Text(
                              //             'Midterm Quiz 1',
                              //             style: TextStyle(
                              //                 fontWeight: FontWeight.bold),
                              //           ),
                              //           subtitle: const Text(
                              //               'Exam Type: Multiple Choice'),
                              //           trailing: SizedBox(
                              //             width: 350,
                              //             child: Row(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.center,
                              //               children: [
                              //                 const Text(
                              //                     'Deadline\nThu, December 12, 2024 11:59 PM'),
                              //                 const Gap(25),
                              //                 // Text('Score\n50/50')
                              //                 SizedBox(
                              //                   width: 85,
                              //                   child: TextField(
                              //                     decoration:
                              //                         const InputDecoration(
                              //                       border:
                              //                           OutlineInputBorder(),
                              //                       label: Text(
                              //                         'Score',
                              //                         style: TextStyle(
                              //                             color: Colors.white),
                              //                       ),
                              //                       floatingLabelAlignment:
                              //                           FloatingLabelAlignment
                              //                               .center,
                              //                     ),
                              //                     controller:
                              //                         TextEditingController
                              //                             .fromValue(
                              //                       const TextEditingValue(
                              //                           text: '100/100'),
                              //                     ),
                              //                     style: const TextStyle(
                              //                         color: Colors.white),
                              //                     readOnly: true,
                              //                   ),
                              //                 )
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              const Text(
                                'Examinations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              StreamBuilder(
                                stream: _firestoreService
                                    .getClassDataStream(widget.classCode),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final classData = snapshot.data!.data();

                                  final List<dynamic> examList =
                                      classData['exams'] ?? [];

                                  return Expanded(
                                    child: examList.isEmpty
                                        ? const Column(
                                            children: [Text('No exams yet.')],
                                          )
                                        : ListView.builder(
                                            itemCount: examList.length,
                                            itemBuilder: (context, examIndex) {
                                              final exam = examList[examIndex];

                                              final Map<String, dynamic>
                                                  submissions =
                                                  exam['submissions'] ?? {};

                                              bool alreadyAnswered =
                                                  submissions.containsKey(
                                                      widget.studentId);

                                              return Card(
                                                child: ListTile(
                                                  enabled: (!DateTime.now()
                                                          .isBefore(exam[
                                                                  'openSchedule']
                                                              .toDate()) &&
                                                      !DateTime.now().isAfter(
                                                          exam['closeSchedule']
                                                              .toDate())),
                                                  onTap: alreadyAnswered
                                                      ? () => QuickAlert.show(
                                                            context: context,
                                                            type: QuickAlertType
                                                                .error,
                                                            title:
                                                                'You have already answered this exam.',
                                                          )
                                                      : () => QuickAlert.show(
                                                            context: context,
                                                            type: QuickAlertType
                                                                .warning,
                                                            title:
                                                                'Are you ready to take the exam?',
                                                            text:
                                                                'Reloading the exam page is strictly prohibited.\nAny attempt to reload will result in an automatic score of 0.\nChanging views/copy and pasting text will deduct points to your final score.',
                                                            onConfirmBtnTap: exam[
                                                                        'examType'] ==
                                                                    'Written'
                                                                ? () =>
                                                                    goToStudentWrittenExamScreen(
                                                                      examIndex:
                                                                          examIndex,
                                                                      exam:
                                                                          exam,
                                                                      violations:
                                                                          classData[
                                                                              'violations'],
                                                                    )
                                                                : () =>
                                                                    goToStudentLaboratoryExamScreen(
                                                                      exam:
                                                                          exam,
                                                                      examIndex:
                                                                          examIndex,
                                                                      violations:
                                                                          classData[
                                                                              'violations'],
                                                                    ),
                                                          ),
                                                  title: Text(
                                                    '${exam['exam']} ${exam['examType']} Examination',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  subtitle: Text(
                                                      'Exam Type: ${exam['examType'] == 'Written' ? 'Multiple Choice' : 'Coding Problem'}'),
                                                  trailing: SizedBox(
                                                    width: 450,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          'Open From: ${DateFormat.yMMMEd().add_jm().format(exam['openSchedule'].toDate())}\nUntil: ${DateFormat.yMMMEd().add_jm().format(exam['closeSchedule'].toDate())}',
                                                          textAlign:
                                                              TextAlign.end,
                                                        ),
                                                        const Gap(25),
                                                        SizedBox(
                                                          width: 100,
                                                          child: TextField(
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              label: Text(
                                                                  'Max Score'),
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                            ),
                                                            controller:
                                                                TextEditingController
                                                                    .fromValue(
                                                              TextEditingValue(
                                                                  text: exam[
                                                                          'maxScore']
                                                                      .toString()),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            readOnly: true,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // MY GRADES
                        Column(
                          children: [
                            TabBar(
                              controller: performanceTabController,
                              tabs: const [
                                Tab(text: 'Course Work'),
                                Tab(text: 'Assessments'),
                              ],
                            ),
                            StreamBuilder(
                              stream: _firestoreService
                                  .getClassDataStream(widget.classCode),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                final classData = snapshot.data!.data();
                                final List lessons =
                                    classData!['lessons'] ?? [];

                                bool hasActivities = lessons.any((lesson) =>
                                    (lesson['activities'] ?? []).isNotEmpty);

                                final List exams = classData['exams'] ?? [];

                                return Expanded(
                                  child: TabBarView(
                                    controller: performanceTabController,
                                    children: [
                                      // COURSE WORK
                                      !hasActivities
                                          ? const Center(
                                              child: Text(
                                                'No activities assigned yet.',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: ListView.builder(
                                                      itemCount: lessons.length,
                                                      itemBuilder: (context,
                                                          lessonIndex) {
                                                        final lesson = lessons[
                                                            lessonIndex];
                                                        final List activities =
                                                            lesson['activities'] ??
                                                                [];

                                                        return ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemCount:
                                                              activities.length,
                                                          itemBuilder: (context,
                                                              activityIndex) {
                                                            final activity =
                                                                activities[
                                                                    activityIndex];

                                                            String? score;

                                                            final Map<String,
                                                                    dynamic>
                                                                submissions =
                                                                activity[
                                                                        'submissions'] ??
                                                                    {};
                                                            if (submissions
                                                                .containsKey(widget
                                                                    .studentId)) {
                                                              score = activity[
                                                                              'submissions']
                                                                          [
                                                                          widget
                                                                              .studentId]
                                                                      ['score']
                                                                  .toString();
                                                            }

                                                            return Card(
                                                              child: ListTile(
                                                                title: Text(
                                                                    'Lesson ${lessonIndex + 1} - Activity ${activityIndex + 1}'),
                                                                trailing: Text(
                                                                  score == null
                                                                      ? 'Not yet taken.'
                                                                      : "Score: $score/${activity['maxScore']}",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                      // EXAMS
                                      exams.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No exams assigned yet.',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: ListView.builder(
                                                      itemCount: exams.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int examIndex) {
                                                        final exam =
                                                            exams[examIndex];

                                                        String? score;

                                                        final Map<String,
                                                                dynamic>
                                                            submissions =
                                                            exam['submissions'] ??
                                                                {};

                                                        if (submissions
                                                            .containsKey(widget
                                                                .studentId)) {
                                                          score = exam['submissions']
                                                                      [widget
                                                                          .studentId]
                                                                  ['score']
                                                              .toString();
                                                        }

                                                        return Card(
                                                          child: ListTile(
                                                            title: Text(
                                                                '${exam['exam']} ${exam['examType']} Exam'),
                                                            trailing: Text(
                                                              score == null
                                                                  ? 'Not yet taken.'
                                                                  : "Score: $score/${exam['maxScore']}",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        // ANNOUNCEMENTS
                        StreamBuilder(
                          stream: _firestoreService.getAnnouncements(
                              classCode: widget.classCode),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No announcements as of now...',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }

                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => scrollToBottom());

                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: ListView(
                                controller: announcementsScrollController,
                                children:
                                    snapshot.data!.docs.map<Widget>((doc) {
                                  Map<String, dynamic> data =
                                      doc.data() as Map<String, dynamic>;

                                  DateTime dateTime =
                                      data['timestamp'].toDate();

                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    alignment: Alignment.centerLeft,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['title'] != ''
                                                  ? data['title']
                                                      .toString()
                                                      .toUpperCase()
                                                  : 'ANNOUNCEMENT',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Divider(),
                                            Text(
                                              data['message'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const Gap(10),
                                            Text(
                                              'by ${data['instructorName']}\n${DateFormat.yMMMMEEEEd().add_jm().format(dateTime)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(), // Convert to a List<Widget>
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
