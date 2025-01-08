import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

class StudentWrittenExamScreen extends StatefulWidget {
  const StudentWrittenExamScreen({
    super.key,
    required this.classCode,
    required this.exam,
    required this.startTime,
    required this.examIndex,
    required this.violations,
    required this.studentId,
  });

  final String classCode;
  final dynamic exam;
  final DateTime startTime;
  final int examIndex;
  final dynamic violations;
  final String studentId;

  @override
  State<StudentWrittenExamScreen> createState() =>
      _StudentWrittenExamScreenState();
}

class _StudentWrittenExamScreenState extends State<StudentWrittenExamScreen>
    with WidgetsBindingObserver {
  // SERVICES
  final _firestoreService = CloudFirestoreService();

  // STUDENT'S ANSWERS
  late List<String?> studentAnswers;

  // ALL MULTIPLE CHOICE ITEMS
  late List<dynamic>? multipleChoiceList;

  void openConfirmSubmitDialog() {
    setState(() {
      allowPop = true;
    });
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Confirm Submission?',
      text: 'Once submitted, all your answers will be recorded.',
      confirmBtnText: 'Yes',
      confirmBtnColor: Colors.green[800]!,
      onConfirmBtnTap: () {
        checkAnswers();
      },
      showCancelBtn: true,
      cancelBtnText: 'Not yet',
      onCancelBtnTap: Navigator.of(context).pop,
    );
    setState(() {
      allowPop = false;
    });
  }

  void checkAnswers() {
    setState(() {
      allowPop = true;
    });

    int correctCount = 0;

    // Loop through the student's answers and compare with correct answers
    for (int i = 0; i < multipleChoiceList!.length; i++) {
      final correctAnswer = multipleChoiceList![i]['correctAnswer'].toString();
      final studentAnswer = studentAnswers[i];

      if (studentAnswer == correctAnswer) {
        correctCount++;
      }
    }

    // Calculate the score or percentage
    int totalQuestions = multipleChoiceList!.length;
    double score = (correctCount / totalQuestions) * widget.exam['maxScore'];

    // Show the result using a dialog or navigation
    Navigator.of(context).pop(); // Close the confirmation dialog
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Submission Complete',
      text:
          'You answered $correctCount/$totalQuestions correctly (${score.toStringAsFixed(1)}%).',
      confirmBtnText: 'Okay',
      onConfirmBtnTap: () {
        _firestoreService.submitExamAnswer(
          classCode: widget.classCode,
          isLab: false,
          examIndex: widget.examIndex,
          studentId: widget.studentId,
          score: score,
          changeViewViolations: changeViewViolations,
          writtenAnswer: studentAnswers,
        );

        Navigator.of(context).pop();
        goBackToClass();
      },
    );
  }

  bool allowPop = false;

  void goToFullScreen() {
    document.documentElement!.requestFullscreen();
  }

  void exitFullScreen() {
    document.exitFullscreen();
  }

  void goBackToClass() {
    exitFullScreen();
    Navigator.of(context).pop();
  }

  // ANTI CHEAT
  int changeViewViolations = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      changeViewViolations++;
    }
  }

  @override
  void initState() {
    super.initState();

    goToFullScreen();

    multipleChoiceList = widget.exam['content'];
    studentAnswers = List<String?>.generate(
      multipleChoiceList!.length,
      (index) => null,
    );

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    int hours = widget.exam['duration']['hours'] * 60;
    int totalMinutes = widget.exam['duration']['minutes'] + hours;

    return PopScope(
      canPop: allowPop,
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size(double.infinity, 75),
          child: StudentAppbar(backButton: false),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Expanded(
              child: Column(
                children: [],
              ),
            ),

            // MULTIPLE CHOICE ACTIVITY
            SizedBox(
              width: 750,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // EXAM TITLE
                            Text(
                              '${widget.exam['exam']} ${widget.exam['examType']} Exam',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DEADLINE
                            const Text('Deadline:'),
                            Text(
                              DateFormat.yMMMEd().add_jm().format(
                                  widget.exam['closeSchedule'].toDate()),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Gap(10),
                    const Divider(),
                    const Gap(10),

                    // QUESTIONS
                    Expanded(
                      child: ListView.builder(
                        itemCount: multipleChoiceList!.length,
                        itemBuilder: (context, itemIndex) {
                          final Map<String, dynamic> item =
                              multipleChoiceList![itemIndex];

                          return Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // QUESTION
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Question ${itemIndex + 1}:'),
                                      Text(
                                        item['question'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // RADIO BUTTONS
                                  ...List.generate(
                                    item['choices'].length,
                                    (index) {
                                      return ListTile(
                                        title: Text(item['choices'][index]),
                                        leading: Radio<String>(
                                          value: item['choices'][index],
                                          groupValue: studentAnswers[itemIndex],
                                          onChanged: (String? value) {
                                            setState(() {
                                              studentAnswers[itemIndex] = value;
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.green[800]),
                          foregroundColor:
                              const WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: openConfirmSubmitDialog,
                        child: const Text('Finish attempt'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // INVISIBLE WIDGET
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Center(child: Text('Time Left')),
                    Center(
                      child: TimerCountdown(
                        timeTextStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        format: totalMinutes > 60
                            ? CountDownTimerFormat.hoursMinutesSeconds
                            : CountDownTimerFormat.minutesSeconds,
                        endTime: widget.startTime.add(
                          Duration(minutes: totalMinutes),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
