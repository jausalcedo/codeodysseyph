import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/student/student_activity_multiple_choice.dart';
import 'package:codeodysseyph/screens/student/student_exam_laboratory.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:disclosure/disclosure.dart';
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
    with SingleTickerProviderStateMixin {
  // TAB ESSENTIALS
  late TabController tabController;

  // SERVICES
  final _firestoreService = CloudFirestoreService();
  final _storageService = FirebaseStorageService();

  // LESSONS
  int? numberOfLessons;

  // OPERATIONS
  Future<void> downloadLearningMaterial(String learningMaterialPath) async {
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

  void goToStudentWrittenExamScreen() {
    // to do
  }

  void goToStudentLaboratoryExamScreen(dynamic exam) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentLaboratoryExamScreen(
          exam: exam,
          startTime: DateTime.now(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this); // 4 tabs
  }

  @override
  Widget build(BuildContext context) {
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      Tab(text: 'My Grades'),
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
                                                                  downloadLearningMaterial(
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

                                                                    final DateTime
                                                                        deadline =
                                                                        activity['deadline']
                                                                            .toDate();

                                                                    return Card(
                                                                      child: ListTile(
                                                                          title: Text('Activity ${activityIndex + 1} ${activity['title'] != '' ? ':${activity['title']}' : ''} (${activity['maxScore']} points)'),
                                                                          subtitle: Text('Type: ${activity['activityType']}'),
                                                                          trailing: Text(
                                                                            'Deadline:\n${DateFormat.yMMMEd().add_jm().format(deadline)}',
                                                                            style:
                                                                                const TextStyle(fontSize: 14),
                                                                          ),
                                                                          onTap: () {
                                                                            if (activity['activityType'] ==
                                                                                'Multiple Choice') {
                                                                              Navigator.of(context).push(MaterialPageRoute(
                                                                                builder: (context) => StudentMultipleChoiceActivityScreen(
                                                                                  studentId: widget.studentId,
                                                                                  activity: activity,
                                                                                  lessonTitle: lesson['title'],
                                                                                  activityNumber: activityIndex + 1,
                                                                                ),
                                                                              ));
                                                                            }
                                                                          }),
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

                                              return Card(
                                                child: ListTile(
                                                  enabled: (DateTime.now()
                                                          .isBefore(
                                                              exam['closeTime']
                                                                  .toDate()) &&
                                                      DateTime.now().isAfter(
                                                          exam['openTime']
                                                              .toDate())),
                                                  onTap: exam['examType'] ==
                                                          'Written'
                                                      ? goToStudentWrittenExamScreen
                                                      : () =>
                                                          goToStudentLaboratoryExamScreen(
                                                              exam),
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
                                                          'Open From: ${DateFormat.yMMMEd().add_jm().format(exam['openTime'].toDate())}\nUntil: ${DateFormat.yMMMEd().add_jm().format(exam['closeTime'].toDate())}',
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
                                                            // style:
                                                            //     const TextStyle(
                                                            //   color:
                                                            //       Colors.white,
                                                            // ),
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
                        const Placeholder(),
                        // ANNOUNCEMENTS
                        const Placeholder(),
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
