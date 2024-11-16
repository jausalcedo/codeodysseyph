import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/screens/instructor/module_viewer.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ActivityQuestionnaire extends StatefulWidget {
  final String activityName;
  const ActivityQuestionnaire({super.key, required this.activityName});

  @override
  State<ActivityQuestionnaire> createState() =>
      _InstructorClassPerformanceState();
}

class _InstructorClassPerformanceState extends State<ActivityQuestionnaire>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> questions = [
    {
      'questionText':
          "What is the correct way to define the main method in a Java program?",
      'options': [
        "public static main(String[] args)",
        "public void main(String args[])",
        "public static void main(String[] args)",
        "public static void main(String args)"
      ],
      'correctAnswerIndex': 2,
    },
    {
      'questionText': "Which keyword is used to define a class in Java?",
      'options': ["function", "class", "define", "object"],
      'correctAnswerIndex': 1,
    },
    {
      'questionText':
          "What is the correct file extension for Java source files?",
      'options': [".class", ".java", ".js", ".txt"],
      'correctAnswerIndex': 1,
    },
  ];

  // Track the selected answer for each question
  List<int?> selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    selectedAnswers = List<int?>.filled(questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 218, 218),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Module 1",
              style: TextStyle(fontSize: 14),
            ),
            Text(
              widget.activityName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 130,
              height: 80,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: const Column(
                children: [
                  Text(
                    "Item 1",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "30 Points",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 19, 27, 99)),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${question['questionText']}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(question['options'].length,
                              (optionIndex) {
                            return RadioListTile<int>(
                              value: optionIndex,
                              groupValue: selectedAnswers[index],
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[index] = optionIndex;
                                });
                              },
                              title: Text(question['options'][optionIndex]),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 300,
              height: 80,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Item Navigation",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 19, 27, 99)),
                      ),
                      Column(
                        children: [
                          Text("Time Elapsed"),
                          Text(
                            "00:04:20",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitQuiz,
          child: const Text('Finish Attempt'),
        ),
      ),
    );
  }

  void _submitQuiz() {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctAnswerIndex']) {
        score += 5; // assuming each question is worth 5 points
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('Your score is $score / ${questions.length * 5}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
