import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/auth/auth_checker.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:gap/gap.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:highlight/languages/java.dart';
import 'package:quickalert/quickalert.dart';
import 'package:intl/intl.dart'; // For date formatting

class StudentDailyChallenge extends StatefulWidget {
  const StudentDailyChallenge({super.key});

  @override
  State<StudentDailyChallenge> createState() => _StudentDailyChallengeState();
}

class _StudentDailyChallengeState extends State<StudentDailyChallenge>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // TAB ESSENTIALS
  late TabController tabController;
  Map<String, dynamic>? challengeData;

  // Future<void> _fetchData() async {
  //   try {
  //     final String documentId = DateFormat('dd-MM-yyyy').format(DateTime.now());
  //     // Fetch data from Firestore
  //     FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     DocumentSnapshot doc =
  //         await firestore.collection('dailyChallenge').doc(documentId).get();

  //     if (doc.exists) {
  //       setState(() {
  //         challengeData = doc.data() as Map<String, dynamic>;
  //       });
  //     } else {
  //       print('No document found for the given date.');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }
  // }

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

  Future<void> checkAndCreateDocument() async {
    // Get the current date in "dd-MM-yyyy" format
    final String documentId = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Reference to Firestore collection
    final docRef =
        FirebaseFirestore.instance.collection('dailyChallenge').doc(documentId);

    // Check if the document exists
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      print('Document already exists: $documentId');
    } else {
      print('Creating new document: $documentId');

      // Define the document fields
      Map<String, dynamic> data = await generateJavaProblem();

      // Create the document
      await docRef.set(data);
      print('New document created.');
    }
  }

  void main() async {
    await checkAndCreateDocument();
  }

  Future<Map<String, dynamic>> generateJavaProblem() async {
    Map<String, dynamic> explanation = {};

    final schema = Schema.object(properties: {
      'content': Schema.object(properties: {
        'constraints': Schema.string(
            description:
                'The constraints of the problem, such as input limits.'),
        'examples': Schema.array(
          items: Schema.object(properties: {
            'input': Schema.string(description: 'Input for the example.'),
            'output':
                Schema.string(description: 'Expected output for the example.'),
          }),
        ),
        'problemStatement': Schema.string(
            description:
                'The problem statement outlining what needs to be done.'),
        'testCases': Schema.array(
          items: Schema.object(properties: {
            'input': Schema.string(description: 'Test case input.'),
            'output': Schema.string(
                description: 'Expected output for the test case.'),
          }),
        ),
      }),
      'maxScore':
          Schema.integer(description: 'The maximum score for the problem.'),
      'finished': Schema.array(
          items: Schema.string(
              description:
                  'List of student IDs who have finished the problem.')),
    }, requiredProperties: [
      'content',
      'maxScore',
      'finished',
    ]);

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: "AIzaSyDaZQIH5Y91DlEJdIXKp7rQREG8fOCbh6s",
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    const prompt =
        "Create other Java problem formatted like this: \n'content': {\n'constraints': '1 < n < 10^9',\n'examples': [\n{'input': '123', 'output': '6'},\n],\n'problemStatement': 'Given an integer n, find the sum of its digits.',\n'testCases': [\n{'input': '789', 'output': '24'},\n{'input': '456', 'output': '15'},\n{'input': '567', 'output': '18'},\n],\n},\n'maxScore': 30,\n'finished': [], // List of student IDs who currently logged in\n};";

    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
      );

      await model.generateContent([Content.text(prompt)]).then((value) {
        final responseData = value.text;
        final parsedResponse = jsonDecode(responseData!);

        // Populate the explanation with the generated content
        explanation = parsedResponse;

        // POP THE LOADING
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
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

    return explanation;
  }

  Future<String> checkSolution(List<dynamic> testCases) async {
    String? explanation;
    print(testCases);
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
      apiKey: "AIzaSyDaZQIH5Y91DlEJdIXKp7rQREG8fOCbh6s",
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
      print(challengeData!['content']['testCases'].length);
      print('$explanation hellos');
      double initialScore = challengeData!['maxScore'] *
          (correctTestCases.where((value) => value == true).length /
              challengeData!['content']['testCases'].length);
      for (int i = 0; i < violations.length; i++) {
        initialScore -= violations[i];
      }
      if (initialScore < 0) initialScore = 0;
      print(initialScore);
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

    checkAndCreateDocument();

    // Fetch data and initialize correctTestCases
    _fetchData();

    // Initialize other components
    tabController = TabController(length: 1, vsync: this);
    _codeEditorController.text = script;

    // Anti-cheat setup
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _fetchData() async {
    try {
      // Fetch data from Firestore
      final String documentId = DateFormat('dd-MM-yyyy').format(DateTime.now());
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot doc =
          await firestore.collection('dailyChallenge').doc(documentId).get();

      if (doc.exists) {
        setState(() {
          challengeData = doc.data() as Map<String, dynamic>;
          correctTestCases = List.generate(
            challengeData!['content']['testCases'].length,
            (_) => false,
          );
          // Initialize correctTestCases after fetching challengeData
        });
      } else {
        print('No document found for the given date.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
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
      body: challengeData == null
          ? const Center(
              child: CircularProgressIndicator()) // Loading indicator
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PROBLEM STATEMENT + EXAMPLE
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, bottom: 10),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Gap(5),

                                  Text(
                                    challengeData!['content']
                                            ['problemStatement'] ??
                                        " ",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Gap(25),
                                  // CONSTRAINTS
                                  const Text(
                                    'Constraints:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Gap(5),
                                  Text(
                                    challengeData!['content']['constraints'] ??
                                        " ",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Gap(25),
                                  // EXAMPLE
                                  const Text(
                                    'Example:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Gap(5),
                                  // INPUT
                                  const Text('Input:'),
                                  Text(
                                    '${challengeData!['content']['examples'][0]['input']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Gap(5),
                                  // OUTPUT
                                  const Text('Output:'),
                                  Text(
                                    challengeData!['content']['examples'][0]
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
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                          ),
                                          onPressed: () => checkSolution(
                                              challengeData!['content']
                                                  ['testCases']),
                                          label: const Text('Check Solution'),
                                          icon: const Icon(
                                              Icons.play_arrow_rounded),
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
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 10),
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
                              challengeData!['content']['testCases'].length,
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
                                  foregroundColor: const WidgetStatePropertyAll(
                                      Colors.white),
                                ),
                                onPressed: () => submitSolution(
                                    challengeData!['content']['testCases']),
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
