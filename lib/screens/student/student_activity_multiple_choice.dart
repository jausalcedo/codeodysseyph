import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class StudentMultipleChoiceActivityScreen extends StatefulWidget {
  const StudentMultipleChoiceActivityScreen({
    super.key,
    required this.classCode,
    required this.studentId,
    required this.activity,
    required this.lessonIndex,
    required this.lessonTitle,
    required this.activityIndex,
  });

  final String classCode;
  final String studentId;
  final Map<String, dynamic> activity;
  final int lessonIndex;
  final String lessonTitle;
  final int activityIndex;

  @override
  State<StudentMultipleChoiceActivityScreen> createState() =>
      _StudentMultipleChoiceActivityScreenState();
}

class _StudentMultipleChoiceActivityScreenState
    extends State<StudentMultipleChoiceActivityScreen> {
  // SERVICES
  final _firestoreService = CloudFirestoreService();

  // STUDENT'S ANSWERS
  late List<String?> studentAnswers;

  // ALL MULTIPLE CHOICE ITEMS
  late List<dynamic>? multipleChoiceList;

  void openConfirmSubmitDialog() {
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
  }

  void checkAnswers() {
    int correctCount = 0;

    // LOOP THROUGH THE STUDENT'S ANSWERS AND COMPARE WITH CORRECT ANSWERS
    for (int i = 0; i < multipleChoiceList!.length; i++) {
      final correctAnswer = multipleChoiceList![i]['correctAnswer'].toString();
      final studentAnswer = studentAnswers[i];

      if (studentAnswer == correctAnswer) {
        correctCount++;
      }
    }

    // CALCULATE SCORE
    int totalQuestions = multipleChoiceList!.length;
    double score =
        (correctCount / totalQuestions) * widget.activity['maxScore'];

    // SHOW THE RESULT
    Navigator.of(context).pop();
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Submission Complete',
      text:
          'You answered $correctCount/$totalQuestions correctly (${score.toStringAsFixed(1)}%).',
      confirmBtnText: 'Okay',
      onConfirmBtnTap: () {
        _firestoreService.submitActivityAnswer(
          classCode: widget.classCode,
          isCodingProblem: false,
          lessonIndex: widget.lessonIndex,
          activityIndex: widget.activityIndex,
          studentId: widget.studentId,
          score: score,
          multipleChoiceAnswer: studentAnswers,
        );

        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    multipleChoiceList = widget.activity['content'];
    studentAnswers = List<String?>.generate(
      multipleChoiceList!.length,
      (index) => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: StudentAppbar(),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // NAVIGATION
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
                          // LESSON TITLE
                          SizedBox(
                            width: 500,
                            child: Text(
                              'Lesson ${widget.lessonIndex + 1}: ${widget.lessonTitle}',
                              maxLines: null,
                              overflow: TextOverflow.visible,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          // ACTIVITY TITLE
                          Text(
                            'Activity ${widget.activityIndex} ${widget.activity['title'] != '' ? ':${widget.activity['title']}' : ''}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DEADLINE
                          const Text('Close Schedule:'),
                          Text(
                            DateFormat.yMMMEd().add_jm().format(
                                widget.activity['closeSchedule'].toDate()),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        value:
                                            item['choices'][index].toString(),
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
          const Expanded(
            child: Column(
              children: [
                SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
