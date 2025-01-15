import 'dart:convert';
import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:gap/gap.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:highlight/languages/java.dart';
import 'package:quickalert/quickalert.dart';

class StudentLaboratoryExamScreen extends StatefulWidget {
  const StudentLaboratoryExamScreen({
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
  State<StudentLaboratoryExamScreen> createState() =>
      _StudentLaboratoryExamScreenState();
}

class _StudentLaboratoryExamScreenState
    extends State<StudentLaboratoryExamScreen>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin {
  bool allowPop = false;
  int currentProblemChoice = 0;
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

  // TAB ESSENTIALS
  late TabController tabController;

  // CODE EDITOR ESSENTIALS
  final codeEditorController = CodeController(
    language: java,
  );

  // SERVICES
  final _firestoreService = CloudFirestoreService();

  String script = """
public class Main {
  public static void main(String[] args) {
    // TYPE YOUR SOLUTION HERE
  }
}
""";

  String previousCode = """
public class Main {
  public static void main(String[] args) {
    // TYPE YOUR SOLUTION HERE
  }
}
""";
  late List<CodeController> codeControllers; // List to store controllers
  late List<String> previousCodes;
  // ANTI CHEAT
  int copyPasteViolations = 0;
  int changeViewViolations = 0;

  Map<int, List<bool>> correctTestCases = {};
  void initializeCorrectTestCases(List<dynamic> problems) {
    for (int i = 0; i < problems.length; i++) {
      int testCaseCount = problems[i]['testCases'].length;
      correctTestCases[i] = List<bool>.filled(
          testCaseCount, false); // Initialize all test cases as false
    }
  }

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
        'Check if the Java solution satisfies the results of the test cases when it is compiled, run, and inputted into the program. If the solution does not satisfy the test cases, return false, otherwise true. Java solution: ${codeControllers[currentProblemChoice].fullText}\n Test Cases: ${testCases.toString()}';

    setState(() {
      allowPop = true;
    });

    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
      );

      await model.generateContent([Content.text(prompt)]).then((value) {
        final responseData = value.text;

        final parsedResponse = jsonDecode(responseData!);

        setState(() {
          correctTestCases[currentProblemChoice] =
              List<bool>.from(parsedResponse['testCaseResults']);

          print(correctTestCases);
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
    setState(() {
      allowPop = false;
    });

    return explanation ?? '';
  }

  void submitSolution() {
    double totalScore = 0; // Initialize the total score
    double maxScore = widget.exam['content'].fold(
        0.0, (sum, problem) => sum + problem['points']); // Total possible score
    int totalTestCases = 0; // Total test cases count

    // Calculate the total score across all problems
    widget.exam['content'].asMap().forEach((problemIndex, problem) {
      int problemScore = problem['points']; // Get the score for this problem
      int totalProblemTestCases =
          problem['testCases'].length; // Total test cases for this problem
      totalTestCases +=
          totalProblemTestCases; // Increment total test cases count

      // Safely get correct test cases for this problem
      int totalCorrect = correctTestCases[problemIndex]
              ?.where((value) => value == true)
              .length ??
          0;

      // Calculate problem-specific score
      double problemScoreEarned =
          (problemScore * totalCorrect) / totalProblemTestCases;

      totalScore += problemScoreEarned; // Add the score to the total
    });

    // Apply penalties for violations
    totalScore -= copyPasteViolations * widget.violations['copyPaste'];
    totalScore -= changeViewViolations * widget.violations['changeView'];
    if (totalScore < 0) totalScore = 0; // Ensure the score isn't negative

    // Generate explanation for violations
    String explanation = '';
    explanation += copyPasteViolations > 0
        ? '\nYou copied and pasted text $copyPasteViolations times.'
        : '';
    explanation += changeViewViolations > 0
        ? '\nYou left the exam view $changeViewViolations times.'
        : '';

    setState(() {
      allowPop = true; // Allow navigation away from the screen
    });

    // Show the results in a dialog
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'You got: ${totalScore.toStringAsFixed(2)} / $maxScore',
      text: explanation,
      onConfirmBtnTap: () {
        // Submit results to the Firestore service
        _firestoreService.submitExamAnswer(
          classCode: widget.classCode,
          isLab: true,
          examIndex: widget.examIndex,
          studentId: widget.studentId,
          score: totalScore,
          copyPasteViolations: copyPasteViolations,
          changeViewViolations: changeViewViolations,
          laboratoryAnswer: codeControllers
              .map((controller) => controller.text)
              .toList()
              .toString(),
        );

        Navigator.of(context).pop(); // Close the dialog
        goBackToClass(); // Navigate back to the class screen
      },
    );
  }

  void disableReload() {
    html.window.onBeforeUnload.listen((event) {
      // Prevent the reload
      event.preventDefault();
    });
  }

  @override
  var wantKeepAlive = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      changeViewViolations++;
    }
  }

  // List<Map<String, dynamic>> exams = [
  //   {
  //     'exam': 'Midterm',
  //     'examType': 'Laboratory',
  //     'duration': {
  //       'hours': 1,
  //       'minutes': 30,
  //     },
  //     'openSchedule': 'January 10, 2025 at 12:00:00 PM UTC+8',
  //     'closeSchedule': 'January 13, 2025 at 3:00:00 PM UTC+8',
  //     'content': [
  //       {
  //         'problemStatement':
  //             'Write a program that will display the sum of two numbers.',
  //         'constraints': 'The input will be two integers.',
  //         'score': 30,
  //         'examples': [
  //           {
  //             'input': '1, 2',
  //             'output': '3',
  //           },
  //         ],
  //         'testCases': [
  //           {
  //             'input': '10, 11',
  //             'output': '21',
  //           },
  //           {
  //             'input': '4, 5',
  //             'output': '9',
  //           },
  //           {
  //             'input': '101, 2',
  //             'output': '103',
  //           },
  //           {
  //             'input': '102, 2',
  //             'output': '104',
  //           },
  //         ],
  //       },
  //       {
  //         'problemStatement':
  //             'Write a program that will display the difference of two numbers.',
  //         'constraints': 'The input will be two integers.',
  //         'score': 20,
  //         'examples': [
  //           {
  //             'input': '17, 4',
  //             'output': '13',
  //           },
  //         ],
  //         'testCases': [
  //           {
  //             'input': '11, 4',
  //             'output': '7',
  //           },
  //           {
  //             'input': '28, 16',
  //             'output': '12',
  //           },
  //         ],
  //       },
  //       {
  //         'problemStatement':
  //             'Write a program that will display the difference of two numbers.',
  //         'constraints': 'The input will be two integers.',
  //         'score': 20,
  //         'examples': [
  //           {
  //             'input': '17, 4',
  //             'output': '13',
  //           },
  //         ],
  //         'testCases': [
  //           {
  //             'input': '11, 4',
  //             'output': '7',
  //           },
  //           {
  //             'input': '28, 16',
  //             'output': '12',
  //           },
  //         ],
  //       }
  //     ],
  //   },
  // ];

  // List to track previous code for each problem

  void scriptGenerator() {
    // Initialize the TabController
    tabController = TabController(
      length: widget.exam['content'].length,
      vsync: this,
    );

    // Initialize CodeControllers and previous code tracking
    codeControllers = widget.exam['content'].map<CodeController>((problem) {
      return CodeController(
        text: """
public class Main {
  public static void main(String[] args) {
    // Solution for: ${problem['problemStatement']}
  }
}
""",
        language: java,
      );
    }).toList();

    previousCodes =
        codeControllers.map((controller) => controller.text).toList();
  }

  @override
  void initState() {
    super.initState();
    disableReload();

    goToFullScreen();
    tabController =
        TabController(length: widget.exam['content'].length, vsync: this);

    codeEditorController.text = script;
    scriptGenerator();
    // ANTI CHEAT
    WidgetsBinding.instance.addObserver(this);
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
  int expandedIndex = 0;
  List<int> expandedIndices = [];

  @override
  Widget build(BuildContext context) {
    int selectedProblem = 0;

    void switchTab(int index) {
      tabController
          .animateTo(index); // Animate to the tab at the specified index
    }

    //to know what testCases display

    int hours = widget.exam['duration']['hours'] * 60;
    int totalMinutes = widget.exam['duration']['minutes'] + hours;

    super.build(context);

    return PopScope(
      canPop: allowPop,
      child: Scaffold(
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
                        Text(
                          '${widget.exam['exam']} ${widget.exam['examType']} Examination',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        const Gap(25),
                        Expanded(
                            child: ListView.builder(
                          itemCount: widget.exam['content']
                              .length, // Number of problems in the exam
                          itemBuilder: (context, problemIndex) {
                            var problem = widget.exam['content'][problemIndex];

                            return ExpansionTile(
                              title: Text(
                                'Problem ${problemIndex + 1}',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 19, 27, 99),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  selectedProblem =
                                      problemIndex; // Update selectedProblem based on tab index
                                  currentProblemChoice = problemIndex;
                                  switchTab(problemIndex);

                                  if (expanded) {
                                    // Add the index of the expanded tile to the list
                                    expandedIndices
                                        .clear(); // Clear the previously expanded indices
                                    expandedIndices.add(problemIndex);
                                  } else {
                                    // Remove the index of the collapsed tile from the list
                                    expandedIndices.remove(problemIndex);
                                  }
                                });
                              },
                              children: [
                                if (expandedIndices.contains(
                                    problemIndex)) // Only show content if the tile is expanded
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // PROBLEM STATEMENT
                                        const Text(
                                          'Problem Statement:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          problem['problemStatement'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 25),

                                        // CONSTRAINTS
                                        const Text(
                                          'Constraints:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          problem['constraints'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 25),

                                        // EXAMPLES
                                        const Text(
                                          'Examples:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),

                                        // INPUT AND OUTPUT
                                        ...problem['examples']
                                            .map<Widget>((example) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Input:'),
                                                Text(
                                                  example['input']
                                                      .replaceAll(', ', '\n'),
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const SizedBox(height: 5),
                                                const Text('Output:'),
                                                Text(
                                                  example['output'],
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        const SizedBox(
                                            height:
                                                20), // Space at the end of the group
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ))
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
                        tabs: List.generate(
                          widget.exam['content'].length,
                          (index) => Tab(text: 'Problem ${index + 1}'),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: List.generate(
                            widget.exam['content'].length, // Number of problems
                            (index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // CODE EDITOR
                                Expanded(
                                  child: CodeTheme(
                                    data: CodeThemeData(styles: vsTheme),
                                    child: SingleChildScrollView(
                                      child: CodeField(
                                        controller: codeControllers[
                                            index], // You may need separate controllers for each problem
                                        onChanged: (code) {
                                          if (code.length -
                                                  previousCodes[index].length >
                                              11) {
                                            copyPasteViolations++;
                                          }
                                          setState(() {
                                            previousCodes[index] = code;
                                          });
                                        },
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
                                        foregroundColor: WidgetStatePropertyAll(
                                            Colors.white),
                                      ),
                                      onPressed: () {
                                        checkSolution(widget.exam['content']
                                                    [currentProblemChoice]
                                                ['testCases']
                                            as List<
                                                dynamic>); // Use the current problem's test cases
                                        print(widget.exam['content']
                                                [currentProblemChoice]
                                            ['testCases']);
                                      },
                                      label: const Text('Check Solution'),
                                      icon:
                                          const Icon(Icons.play_arrow_rounded),
                                    ),
                                  ),
                                ),
                                const Gap(10),
                              ],
                            ),
                          ),
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
                        // TIME LEFT
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
                            onEnd: () => submitSolution(),
                          ),
                        ),
                        const Gap(25),
                        // TEST CASES
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.exam['content']
                                .length, // Number of problems in the exam
                            itemBuilder: (context, problemIndex) {
                              var problem =
                                  widget.exam['content'][problemIndex];

                              return Card(
                                child: ExpansionTile(
                                  title: Text(
                                    'Test Cases for Problem ${problemIndex + 1}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 19, 27, 99),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  collapsedBackgroundColor: Colors.white,
                                  textColor:
                                      const Color.fromARGB(255, 19, 27, 99),
                                  collapsedTextColor:
                                      const Color.fromARGB(255, 19, 27, 99),
                                  iconColor:
                                      const Color.fromARGB(255, 19, 27, 99),
                                  collapsedIconColor: Colors.white,
                                  children: [
                                    ListView.builder(
                                      shrinkWrap:
                                          true, // Ensures the ListView works inside ExpansionTile
                                      physics:
                                          const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                                      itemCount: problem['testCases'].length,
                                      itemBuilder: (context, testCaseIndex) {
                                        // Access correctTestCases for the current problem and test case
                                        bool isCorrect =
                                            correctTestCases[problemIndex]
                                                    ?[testCaseIndex] ??
                                                false;

                                        return Card(
                                          color: isCorrect
                                              ? Colors.green[800]
                                              : Colors.red[800],
                                          child: ListTile(
                                            textColor: Colors.white,
                                            title: Text(
                                                'Test Case ${testCaseIndex + 1}'),
                                            trailing: Icon(
                                              isCorrect
                                                  ? Icons.check_rounded
                                                  : Icons.close_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
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
                            onPressed: () {
                              var testCases =
                                  widget.exam['content'][0]['testCases'];
                              if (testCases != null) {
                                submitSolution();
                              } else {
                                print('Test cases are null');
                              }
                            },
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
      ),
    );
  }
}
