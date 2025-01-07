import 'dart:convert';

import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:gap/gap.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:highlight/languages/java.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class StudentCodingProblemActivityScreen extends StatefulWidget {
  const StudentCodingProblemActivityScreen({
    super.key,
    required this.classCode,
    required this.lessonIndex,
    required this.activityIndex,
    required this.activity,
    required this.studentId,
  });

  final String classCode;
  final int lessonIndex;
  final int activityIndex;
  final dynamic activity;
  final String studentId;

  @override
  State<StudentCodingProblemActivityScreen> createState() =>
      _StudentCodingProblemActivityScreenState();
}

class _StudentCodingProblemActivityScreenState
    extends State<StudentCodingProblemActivityScreen>
    with SingleTickerProviderStateMixin {
  // SERVICES
  final _firestoreService = CloudFirestoreService();

  // TAB ESSENTIALS
  late TabController tabController;

  // CODE EDITOR ESSENTIALS
  final codeEditorController = CodeController(
    language: java,
  );

  String script = """
public class Main {
  public static void main(String[] args) {
    // TYPE YOUR SOLUTION HERE
  }
}
""";

  late List<dynamic> correctTestCases;

  final apiKey = () {
    const apiKey = String.fromEnvironment(
      'API_KEY',
      defaultValue: 'fallback_api_key',
    );

    return apiKey;
  }();

  Future<String> checkSolution(List<dynamic> testCases) async {
    String? explanation;

    final schema = Schema.object(properties: {
      'testCaseResults': Schema.array(
        items: Schema.boolean(
            description:
                'A boolean value indicating whether the provided solution satisfies an individual test case.'),
      ),
      'explanation': Schema.string(
          description:
              'Explains the solution did not pass a test case if there are any.'),
    }, requiredProperties: [
      'testCaseResults',
      'explanation',
    ]);

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final prompt =
        'Check if the Java solution satisfies the results of the test cases when it is compiled, run, and inputted into the program. If the solution does not satisfy the test cases, return false, otherwise true. Java solution: ${codeEditorController.fullText}\n Test Cases: ${testCases.toString()}';

    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
      );

      await model.generateContent([Content.text(prompt)]).then((value) {
        final responseData = value.text;

        final parsedResponse = jsonDecode(responseData!);

        setState(() {
          correctTestCases = parsedResponse['testCaseResults'];
        });

        // POP THE LOADING
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        explanation = parsedResponse['explanation'];
      });
    } catch (e) {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'An Error Occured',
        text: '$e',
      );
    }
    return explanation ?? '';
  }

  void submitSolution(List<dynamic> testCases) {
    checkSolution(testCases).then((explanation) {
      double score = widget.activity['maxScore'] *
          (correctTestCases.where((value) => value == true).length /
              widget.activity['content']['testCases'].length);
      if (score < 0) score = 0;
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.success,
        title: 'You got: $score',
        onConfirmBtnTap: () {
          _firestoreService.submitActivityAnswer(
            classCode: widget.classCode,
            isCodingProblem: true,
            lessonIndex: widget.lessonIndex,
            activityIndex: widget.activityIndex,
            codingProblemAnswer: codeEditorController.fullText,
            studentId: widget.studentId,
            score: score,
          );
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
    codeEditorController.fullText = script;

    correctTestCases = List.generate(
      widget.activity['content']['testCases'].length,
      (_) => false,
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
        children: [
          // PROBLEM STATEMENT + EXAMPLE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Lesson ${widget.lessonIndex + 1} - Activity ${widget.activityIndex + 1}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const Gap(25),
                      Expanded(
                        child: ListView(
                          children: [
                            // PROBLEM STATEMENT
                            const Text(
                              'Problem Statement:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Gap(5),
                            Text(
                              widget.activity['content']['problemStatement'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Gap(25),
                            // CONSTRAINTS
                            const Text(
                              'Constraints:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Gap(5),
                            Text(
                              widget.activity['content']['constraints'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Gap(25),
                            // EXAMPLE
                            const Text(
                              'Example:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Gap(5),
                            // INPUT
                            const Text('Input:'),
                            Text(
                              '${widget.activity['content']['examples'][0]['input'].replaceAll(', ', '\n')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Gap(5),
                            // OUTPUT
                            const Text('Output:'),
                            Text(
                              widget.activity['content']['examples'][0]
                                  ['output'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CODE EDITOR
          SizedBox(
            width: 850,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    TabBar(
                      controller: tabController,
                      tabs: const [Tab(text: 'Code Editor')],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          // CODE EDITOR
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // CODE EDITOR
                              Expanded(
                                child: CodeTheme(
                                  data: CodeThemeData(styles: vsTheme),
                                  child: SingleChildScrollView(
                                    child: CodeField(
                                      controller: codeEditorController,
                                      // onChanged: (code) {
                                      //   if (code.length - previousCode.length >
                                      //       11) {
                                      //     print(code.length);
                                      //     print(previousCode.length);
                                      //     print('copy paste violation!');
                                      //     copyPasteViolations++;
                                      //   }
                                      //   setState(() {
                                      //     previousCode = code;
                                      //   });
                                      // },
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(10),

                              // RUN BUTTON
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: SizedBox(
                                  height: 40,
                                  width: 175,
                                  child: TextButton.icon(
                                    style: const ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(primary),
                                      foregroundColor:
                                          WidgetStatePropertyAll(Colors.white),
                                    ),
                                    onPressed: () => checkSolution(widget
                                        .activity['content']['testCases']),
                                    label: const Text('Check Solution'),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                  ),
                                ),
                              ),
                              const Gap(10),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // SUBMIT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // // TIME LEFT
                      // Center(child: Text('Time Left')),
                      // Center(
                      //   child: TimerCountdown(
                      //     timeTextStyle: TextStyle(
                      //       fontSize: 32,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //     format: totalMinutes > 60
                      //         ? CountDownTimerFormat.hoursMinutesSeconds
                      //         : CountDownTimerFormat.minutesSeconds,
                      //     endTime: widget.startTime.add(
                      //       Duration(minutes: totalMinutes),
                      //     ),
                      //   ),
                      // ),
                      const Gap(25),
                      // TEST CASES
                      ...List.generate(
                        widget.activity['content']['testCases'].length,
                        (index) => Card(
                          color: correctTestCases[index] == true
                              ? Colors.green[800]
                              : Colors.red[800],
                          child: ListTile(
                            textColor: Colors.white,
                            title: Text('Test Case ${index + 1}'),
                            trailing: Icon(
                              correctTestCases[index] == true
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Gap(25),

                      // SUBMIT BUTTON
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.green[800]),
                            foregroundColor:
                                const WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: () => submitSolution(
                              widget.activity['content']['testCases']),
                          child: const Text(
                            'Submit Solution',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
