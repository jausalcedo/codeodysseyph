import 'dart:convert';

import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/auth/auth_checker.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:gap/gap.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:highlight/languages/java.dart';
import 'package:quickalert/quickalert.dart';

class StudentDailyChallenge extends StatefulWidget {
  StudentDailyChallenge({super.key});
  final Map<String, dynamic> exam = {
    'exam': 'Coding Problem',
    'examType': '',
    'content': {
      'problemStatement': 'Given an integer n, find the sum of its digits.',
      'constraints': '1 < n < 10^9',
      'examples': [
        {
          'input': "'123'",
          'output': "'6'",
        }
      ],
      'testCases': [
        {
          'input': "'789'",
          'output': "'24'",
        },
        {
          'input': "'456'",
          'output': "'15'",
        },
        {
          'input': "'567'",
          'output': "'18'",
        },
      ],
    },
    'maxScore': 30,
  };

  @override
  State<StudentDailyChallenge> createState() => _StudentDailyChallengeState();
}

class _StudentDailyChallengeState extends State<StudentDailyChallenge>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // void goToFullScreen() {
  //   document.documentElement!.requestFullscreen();
  // }

  // TAB ESSENTIALS
  late TabController tabController;

  // CODE EDITOR ESSENTIALS
  final _codeEditorController = CodeController(
    language: java,
  );

  String script = """
public class Main {
  public static void main(String[] args) {
    // TYPE YOUR SOLUTION HERE
  }
}
""";

  // ANTI CHEAT
  List<double> violations = [];

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
        'Check if the Java solution satisfies the results of the test cases when it is compiled, run, and inputted into the program. If the solution does not satisfy the test cases, return false, otherwise true. Java solution: ${_codeEditorController.fullText}\n Test Cases: ${testCases.toString()}';

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

        print(parsedResponse['explanation']);

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
      print(violations);
      double initialScore = widget.exam['maxScore'] *
          (correctTestCases.where((value) => value == true).length /
              widget.exam['content']['testCases'].length);
      for (int i = 0; i < violations.length; i++) {
        initialScore -= violations[i];
      }
      if (initialScore < 0) initialScore = 0;
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.success,
        title: 'You got: $initialScore',
        text: explanation,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AuthChecker(),
          ));
        },
      );
    });
  }

  @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);

  //   if (!mounted) return;

  //   if (state == AppLifecycleState.inactive ||
  //       state == AppLifecycleState.paused) {
  //     violations.add(2.5);
  //   }
  // }

  @override
  void initState() {
    super.initState();

    // goToFullScreen();
    tabController = TabController(length: 1, vsync: this);
    _codeEditorController.text = script;

    // ANTI CHEAT
    WidgetsBinding.instance.addObserver(this);

    // INITIALIZE CORRECT TEST CASES
    correctTestCases = List.generate(
      widget.exam['content']['testCases'].length,
      (_) => false,
    );
  }

  final focusNode = FocusNode();

  // @override
  // void dispose() {
  //   if (mounted) {
  //     WidgetsBinding.instance.removeObserver(this);
  //     exitFullScreen();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: StudentAppbar(backButton: false),
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
                      const Text(
                        'Daily Code Challenge',
                        style: TextStyle(
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
                              widget.exam['content']['problemStatement'],
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
                              widget.exam['content']['constraints'],
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
                              '${widget.exam['content']['examples'][0]['input'].substring(1, widget.exam['content']['examples'][0]['input'].length - 1).replaceAll(', ', '\n')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Gap(5),
                            // OUTPUT
                            const Text('Output:'),
                            Text(
                              widget.exam['content']['examples'][0]['output'],
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
                                      controller: _codeEditorController,
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
                                    onPressed: () => checkSolution(
                                        widget.exam['content']['testCases']),
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
                      const Gap(25),
                      // TEST CASES
                      ...List.generate(
                        widget.exam['content']['testCases'].length,
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
                              widget.exam['content']['testCases']),
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
