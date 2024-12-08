import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class InstructorActivityScreen extends StatefulWidget {
  const InstructorActivityScreen({
    super.key,
    required this.instructorId,
    required this.activity,
    required this.lessonTitle,
    required this.activityNumber,
  });

  final String instructorId;
  final Map<String, dynamic> activity;
  final String lessonTitle;
  final int activityNumber;

  @override
  State<InstructorActivityScreen> createState() =>
      _InstructorActivityScreenState();
}

class _InstructorActivityScreenState extends State<InstructorActivityScreen> {
  late List<String?> myAnswers;

  void confirmSubmit() {
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
    final multipleChoiceList = widget.activity['content'];
    myAnswers = List<String?>.generate(
      multipleChoiceList.length,
      (index) => null, // Initialize all answers as null
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityType = widget.activity['activityType'];

    // ALL ITEMS
    List<dynamic>? multipleChoiceList;

    if (activityType == 'Multiple Choice') {
      multipleChoiceList = widget.activity['content'];
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: InstructorAppbar(userId: widget.instructorId),
      ),
      body: activityType == 'Multiple Choice'
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 750,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lessonTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Activity ${widget.activityNumber} ${widget.activity['title'] != '' ? ':${widget.activity['title']}' : ''}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const Gap(10),
                        const Divider(),
                        const Gap(10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: multipleChoiceList!.length,
                            itemBuilder: (context, itemIndex) {
                              final Map<String, dynamic> multipleChoiceItem =
                                  multipleChoiceList![itemIndex];

                              return Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // QUESTION
                                      Text(
                                        multipleChoiceItem['question'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      // RADIO BUTTONS
                                      ...List.generate(
                                        multipleChoiceItem['choices'].length,
                                        (index) {
                                          return ListTile(
                                            title: Text(
                                                multipleChoiceItem['choices']
                                                    [index]),
                                            leading: Radio<String>(
                                              value:
                                                  multipleChoiceItem['choices']
                                                      [index],
                                              groupValue: myAnswers[itemIndex],
                                              onChanged: (String? value) {
                                                setState(() {
                                                  myAnswers[itemIndex] = value;
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
                            onPressed: confirmSubmit,
                            child: const Text('Finish attempt'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          : const Placeholder(),
    );
  }
}
