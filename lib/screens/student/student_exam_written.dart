import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class StudentLaboratoryExamScreen extends StatefulWidget {
  const StudentLaboratoryExamScreen({
    super.key,
    required this.examIndex,
    required this.exam,
  });

  final int examIndex;

  final dynamic exam;

  @override
  State<StudentLaboratoryExamScreen> createState() =>
      _StudentLaboratoryExamScreenState();
}

class _StudentLaboratoryExamScreenState
    extends State<StudentLaboratoryExamScreen> {
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
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
      showCancelBtn: true,
      cancelBtnText: 'Not yet',
      onCancelBtnTap: Navigator.of(context).pop,
    );
  }

  @override
  void initState() {
    super.initState();
    multipleChoiceList = widget.exam['content'];
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // NAVIGATION
          const Expanded(
            child: Column(
              children: [
                Placeholder(),
              ],
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DEADLINE
                          const Text('Deadline:'),
                          Text(
                            DateFormat.yMMMEd()
                                .add_jm()
                                .format(widget.exam['deadline'].toDate()),
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
