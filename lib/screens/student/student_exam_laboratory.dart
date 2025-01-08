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
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin {
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

  // ANTI CHEAT
  int copyPasteViolations = 0;
  int changeViewViolations = 0;

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
    setState(() {
      allowPop = false;
    });

    return explanation ?? '';
  }

  void submitSolution(List<dynamic> testCases) {
    checkSolution(testCases).then((explanation) {
      double score = widget.exam['maxScore'] *
          (correctTestCases.where((value) => value == true).length /
              widget.exam['content']['testCases'].length);
      score -= copyPasteViolations * widget.violations['copyPaste'];
      score -= changeViewViolations * widget.violations['changeView'];
      if (score < 0) score = 0;

      setState(() {
        allowPop = true;
      });

      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.success,
        title: 'You got: $score',
        text:
            '$explanation${copyPasteViolations > 0 ? '\nYou copied and pasted text $copyPasteViolations times.' : ''}${changeViewViolations > 0 ? '\nYou left the exam view $changeViewViolations times.' : ''}',
        onConfirmBtnTap: () {
          _firestoreService.submitExamAnswer(
            classCode: widget.classCode,
            isLab: true,
            examIndex: widget.examIndex,
            studentId: widget.studentId,
            score: score,
            copyPasteViolations: copyPasteViolations,
            changeViewViolations: changeViewViolations,
            laboratoryAnswer: codeEditorController.fullText,
          );
          Navigator.of(context).pop();
          goBackToClass();
        },
      );
    });
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

  @override
  void initState() {
    super.initState();
    disableReload();

    goToFullScreen();
    tabController = TabController(length: 1, vsync: this);
    codeEditorController.text = script;

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
                                '${widget.exam['content']['examples'][0]['input'].replaceAll(', ', '\n')}',
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
                                        controller: codeEditorController,
                                        onChanged: (code) {
                                          if (code.length -
                                                  previousCode.length >
                                              11) {
                                            copyPasteViolations++;
                                          }
                                          setState(() {
                                            previousCode = code;
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
                                      onPressed: () => checkSolution(
                                          widget.exam['content']['testCases']),
                                      label: const Text('Check Solution'),
                                      icon:
                                          const Icon(Icons.play_arrow_rounded),
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
                            onEnd: () => submitSolution(
                                widget.exam['content']['testCases']),
                          ),
                        ),
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
      ),
    );
  }
}
