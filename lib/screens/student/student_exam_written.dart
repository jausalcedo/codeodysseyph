import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
  final _storageService = FirebaseStorageService();

  // STUDENT'S ANSWERS
  late List<String?> multipleChoiceAnswers;
  late List<String?> trueOrFalseAnswers;
  late List<String?> identificationAnswers;
  late List<String?> shortAAnswers;
  late List<String?> longAAnswers;

  // ANSWER CONTROLLERS
  late List<TextEditingController>? identificationControllers;
  late List<TextEditingController>? shortAnswerControllers;
  late List<TextEditingController>? longAnswerControllers;

  // ALL WRITTEN EXAM ITEMS
  late List<dynamic>? multipleChoiceList;
  late List<dynamic>? trueOrFalseList;
  late List<dynamic>? identificationList;
  late List<dynamic>? shortAnswerList;
  late List<dynamic>? longAnswerList;

  // ATTACHMENTS
  late List<Future<String>> mcAttachmentFutures;
  late List<Future<String>> tofAttachmentFutures;
  late List<Future<String>> iAttachmentFutures;
  late List<Future<String>> saAttachmentFutures;
  late List<Future<String>> laAttachmentFutures;

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

    double score = 0;

    // LOOP THROUGH THE STUDENT'S ANSWERS AND COMPARE WITH CORRECT ANSWERS

    // MULTIPLE CHOICE
    for (int i = 0; i < multipleChoiceList!.length; i++) {
      final item = multipleChoiceList![i];

      final correctAnswer = item['answer'].toString();
      final studentAnswer = multipleChoiceAnswers[i];

      if (studentAnswer == correctAnswer) {
        score += item['points'];
      }
    }

    // TRUE OR FALSE
    for (int i = 0; i < trueOrFalseList!.length; i++) {
      final item = trueOrFalseList![i];

      final correctAnswer = item['answer'].toString();
      final studentAnswer = trueOrFalseAnswers[i];

      if (studentAnswer == correctAnswer) {
        score += item['points'];
      }
    }

    // IDENTIFICATION
    for (int i = 0; i < identificationList!.length; i++) {
      final item = identificationList![i];

      final correctAnswer = item['answer'].toString();
      final studentAnswer = identificationAnswers[i];

      if (studentAnswer == correctAnswer) {
        score += item['points'];
      }
    }

    // Show the result using a dialog or navigation
    Navigator.of(context).pop(); // Close the confirmation dialog
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Submission Complete',
      text: multipleChoiceList!.isEmpty &&
              trueOrFalseList!.isEmpty &&
              identificationList!.isEmpty
          ? 'Your answers will be evaluated by the instructor.'
          : shortAnswerList!.isEmpty && longAnswerList!.isEmpty
              ? 'You got: $score.'
              : 'Your answers will be evaluated by the instructor.',
      confirmBtnText: 'Okay',
      onConfirmBtnTap: () {
        _firestoreService.submitExamAnswer(
          classCode: widget.classCode,
          isLab: false,
          examIndex: widget.examIndex,
          studentId: widget.studentId,
          score: score,
          changeViewViolations: changeViewViolations,
          writtenAnswer: {
            'multipleChoiceAnswers': multipleChoiceAnswers,
            'trueOrFalseAnswers': trueOrFalseAnswers,
            'identificationAnswers': identificationAnswers,
            'shortAAnswers': shortAAnswers,
            'longAAnswers': longAAnswers,
          },
          status: multipleChoiceList!.isEmpty &&
                  trueOrFalseList!.isEmpty &&
                  identificationList!.isEmpty
              ? 'Partial'
              : shortAnswerList!.isEmpty && longAnswerList!.isEmpty
                  ? 'Complete'
                  : 'Partial',
        );

        Navigator.of(context).pop();
        goBackToClass();
      },
    );
  }

  bool allowPop = false;

  void goToFullScreen() {
    html.document.documentElement!.requestFullscreen();
  }

  void exitFullScreen() {
    html.document.exitFullscreen();
  }

  void goBackToClass() {
    exitFullScreen();
    Navigator.of(context).pop();
  }

  // ANTI CHEAT
  int changeViewViolations = 0;

  void disableReload() {
    html.window.onBeforeUnload.listen((event) {
      // Prevent the reload
      event.preventDefault();
    });
  }

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

    multipleChoiceList = widget.exam['content']['Multiple Choice'];
    trueOrFalseList = widget.exam['content']['True or False'];
    identificationList = widget.exam['content']['Identification'];
    shortAnswerList = widget.exam['content']['Short Answer'];
    longAnswerList = widget.exam['content']['Long Answer'];

    multipleChoiceAnswers = List<String?>.generate(
      multipleChoiceList!.length,
      (index) => null,
    );

    trueOrFalseAnswers = List<String?>.generate(
      trueOrFalseList!.length,
      (index) => null,
    );

    identificationControllers = List<TextEditingController>.generate(
      identificationList!.length,
      (index) => TextEditingController(),
    );

    identificationAnswers = List<String?>.generate(
      identificationList!.length,
      (index) => null,
    );

    shortAnswerControllers = List<TextEditingController>.generate(
      shortAnswerList!.length,
      (index) => TextEditingController(),
    );

    shortAAnswers = List<String?>.generate(
      shortAnswerList!.length,
      (index) => null,
    );

    longAnswerControllers = List<TextEditingController>.generate(
      longAnswerList!.length,
      (index) => TextEditingController(),
    );

    longAAnswers = List<String?>.generate(
      longAnswerList!.length,
      (index) => null,
    );

    mcAttachmentFutures = multipleChoiceList!.expand((item) {
      final List attachments = item['attachments'];

      return attachments.map<Future<String>>((attachment) {
        return _storageService.storageRef
            .child(attachment['attachment'])
            .getDownloadURL();
      });
    }).toList();

    tofAttachmentFutures = trueOrFalseList!.expand((item) {
      final List attachments = item['attachments'];

      return attachments.map<Future<String>>((attachment) {
        return _storageService.storageRef
            .child(attachment['attachment'])
            .getDownloadURL();
      });
    }).toList();

    iAttachmentFutures = identificationList!.expand((item) {
      final List attachments = item['attachments'];

      return attachments.map<Future<String>>((attachment) {
        return _storageService.storageRef
            .child(attachment['attachment'])
            .getDownloadURL();
      });
    }).toList();

    saAttachmentFutures = shortAnswerList!.expand((item) {
      final List attachments = item['attachments'];

      return attachments.map<Future<String>>((attachment) {
        return _storageService.storageRef
            .child(attachment['attachment'])
            .getDownloadURL();
      });
    }).toList();

    laAttachmentFutures = longAnswerList!.expand((item) {
      final List attachments = item['attachments'];

      return attachments.map<Future<String>>((attachment) {
        return _storageService.storageRef
            .child(attachment['attachment'])
            .getDownloadURL();
      });
    }).toList();

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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Text(
                      'Progress:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          // MULTIPLE CHOICE
                          multipleChoiceList!.isNotEmpty
                              ? Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                        'Multiple Choice: ${multipleChoiceAnswers.where((item) => item != null).length} / ${multipleChoiceAnswers.length}'),
                                  ),
                                )
                              : const SizedBox(),

                          // TRUE OR FALSE
                          trueOrFalseList!.isNotEmpty
                              ? Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                        'True or False: ${trueOrFalseAnswers.where((item) => item != null).length} / ${trueOrFalseAnswers.length}'),
                                  ),
                                )
                              : const SizedBox(),

                          // IDENTIFICATION
                          identificationList!.isNotEmpty
                              ? Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                        'True or False: ${identificationAnswers.where((item) => item != null).length} / ${identificationAnswers.length}'),
                                  ),
                                )
                              : const SizedBox(),

                          // SHORT ANSWER
                          shortAnswerList!.isNotEmpty
                              ? Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                        'Short Answer: ${shortAAnswers.where((item) => item != null).length} / ${shortAAnswers.length}'),
                                  ),
                                )
                              : const SizedBox(),

                          // LONG ANSWER
                          longAnswerList!.isNotEmpty
                              ? Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                        'Long Answer: ${longAAnswers.where((item) => item != null).length} / ${longAAnswers.length}'),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // EXAM
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

                    // WRITTEN ITEMS
                    Expanded(
                      child: ListView(
                        children: [
                          // MULTIPLE CHOICE
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: multipleChoiceList!.length,
                            itemBuilder: (context, multipleChoiceIndex) {
                              final Map<String, dynamic> item =
                                  multipleChoiceList![multipleChoiceIndex];

                              final List attachments = item['attachments'];

                              return Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // QUESTION
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Multiple Choice'),
                                          Text(
                                            '${multipleChoiceIndex + 1}. ${item['question']}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(5),

                                      // ATTACHMENTS
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: attachments.length,
                                        itemBuilder: (context, index) =>
                                            FutureBuilder(
                                          future: mcAttachmentFutures[index],
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            return Image.network(
                                                snapshot.data!);
                                          },
                                        ),
                                      ),
                                      const Gap(5),

                                      // RADIO BUTTONS
                                      ...List.generate(
                                        item['choices'].length,
                                        (index) {
                                          return ListTile(
                                            title: Text(item['choices'][index]),
                                            leading: Radio<String>(
                                              value: item['choices'][index],
                                              groupValue: multipleChoiceAnswers[
                                                  multipleChoiceIndex],
                                              onChanged: (String? value) {
                                                setState(() {
                                                  multipleChoiceAnswers[
                                                          multipleChoiceIndex] =
                                                      value;
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

                          // TRUE OR FALSE
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: trueOrFalseList!.length,
                            itemBuilder: (context, trueOrFalseIndex) {
                              final Map<String, dynamic> item =
                                  trueOrFalseList![trueOrFalseIndex];

                              final List attachments = item['attachments'];

                              return Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // QUESTION
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('True or False'),
                                          Text(
                                            '${trueOrFalseIndex + 1}. ${item['question']}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(5),

                                      // ATTACHMENTS
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: attachments.length,
                                        itemBuilder: (context, index) =>
                                            FutureBuilder(
                                          future: tofAttachmentFutures[index],
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            return Image.network(
                                                snapshot.data!);
                                          },
                                        ),
                                      ),
                                      const Gap(5),

                                      // RADIO BUTTONS
                                      ...List.generate(
                                        2,
                                        (index) {
                                          return ListTile(
                                            title: Text(index % 2 == 0
                                                ? "True"
                                                : "False"),
                                            leading: Radio<String>(
                                              value: index % 2 == 0
                                                  ? "True"
                                                  : "False",
                                              groupValue: trueOrFalseAnswers[
                                                  trueOrFalseIndex],
                                              onChanged: (String? value) {
                                                setState(() {
                                                  trueOrFalseAnswers[
                                                      trueOrFalseIndex] = value;
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

                          // IDENTIFICATION
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: identificationList!.length,
                            itemBuilder: (context, identificationIndex) {
                              final Map<String, dynamic> item =
                                  identificationList![identificationIndex];

                              final List attachments = item['attachments'];

                              return Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // QUESTION
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Identification'),
                                          Text(
                                            '${identificationIndex + 1}. ${item['question']}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(5),

                                      // ATTACHMENTS
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: attachments.length,
                                        itemBuilder: (context, index) =>
                                            FutureBuilder(
                                          future: iAttachmentFutures[index],
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            return Image.network(
                                                snapshot.data!);
                                          },
                                        ),
                                      ),
                                      const Gap(5),

                                      // TEXT FIELD FOR ANSWER
                                      TextField(
                                        controller: identificationControllers![
                                            identificationIndex],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          label: Text('Your Answer'),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value.trim().isEmpty) {
                                              identificationAnswers[
                                                  identificationIndex] = null;
                                            } else {
                                              identificationAnswers[
                                                  identificationIndex] = value;
                                            }
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // SHORT ANSWER
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: shortAnswerList!.length,
                            itemBuilder: (context, shortAnswerIndex) {
                              final Map<String, dynamic> item =
                                  shortAnswerList![shortAnswerIndex];

                              final List attachments = item['attachments'];

                              return Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // QUESTION
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Identification'),
                                          Text(
                                            '${shortAnswerIndex + 1}. ${item['question']}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(5),

                                      // ATTACHMENTS
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: attachments.length,
                                        itemBuilder: (context, index) =>
                                            FutureBuilder(
                                          future: saAttachmentFutures[index],
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            return Image.network(
                                                snapshot.data!);
                                          },
                                        ),
                                      ),
                                      const Gap(5),

                                      // TEXT FIELD FOR ANSWER
                                      TextField(
                                        controller: shortAnswerControllers![
                                            shortAnswerIndex],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          label: Text('Your Answer'),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value.trim().isEmpty) {
                                              shortAAnswers[shortAnswerIndex] =
                                                  null;
                                            } else {
                                              shortAAnswers[shortAnswerIndex] =
                                                  value;
                                            }
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // LONG ANSWER
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: longAnswerList!.length,
                            itemBuilder: (context, longAnswerIndex) {
                              final Map<String, dynamic> item =
                                  longAnswerList![longAnswerIndex];

                              final List attachments = item['attachments'];

                              return Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // QUESTION
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Identification'),
                                          Text(
                                            '${longAnswerIndex + 1}. ${item['question']}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(5),

                                      // ATTACHMENTS
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: attachments.length,
                                        itemBuilder: (context, index) =>
                                            FutureBuilder(
                                          future: laAttachmentFutures[index],
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            return Image.network(
                                                snapshot.data!);
                                          },
                                        ),
                                      ),
                                      const Gap(5),

                                      // TEXT FIELD FOR ANSWER
                                      TextField(
                                        controller: longAnswerControllers![
                                            longAnswerIndex],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          label: Text('Your Answer'),
                                        ),
                                        minLines: 3,
                                        maxLines: 5,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value.trim().isEmpty) {
                                              longAAnswers[longAnswerIndex] =
                                                  null;
                                            } else {
                                              longAAnswers[longAnswerIndex] =
                                                  value;
                                            }
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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
