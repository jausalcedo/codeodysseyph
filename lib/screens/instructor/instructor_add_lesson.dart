import 'dart:typed_data';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class InstructorAddLessonScreen extends StatefulWidget {
  const InstructorAddLessonScreen({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<InstructorAddLessonScreen> createState() =>
      _InstructorAddLessonScreenState();
}

class _InstructorAddLessonScreenState extends State<InstructorAddLessonScreen> {
  final lessonTitleController = TextEditingController();

  String? fileName;
  Uint8List? fileBytes;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      // allowedExtensions: ['pdf', 'pptx', 'ppt'],
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        fileBytes = result.files.first.bytes!;
        fileName = result.files.first.name;
      });
    }
  }

  String activityType = 'Multiple Choice';

  // FORM KEYS
  final lessonTitleFormKey = GlobalKey<FormState>();
  final multipleChoiceFormKey = GlobalKey<FormState>();
  final codingProblemFormKey = GlobalKey<FormState>();

  // MULTIPLE CHOICE CONTROLLERS
  final questionController = TextEditingController();
  final choiceControllers = List.generate(4, (_) => TextEditingController());
  final correctAnswerController = TextEditingController();

  List<Map<String, dynamic>> questionList = [];

  void addQuestion() {
    if (!multipleChoiceFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      questionList.add({
        'question': questionController.text,
        'choices': [
          choiceControllers[0].text,
          choiceControllers[1].text,
          choiceControllers[2].text,
          choiceControllers[3].text,
        ],
        'correctAnswer': correctAnswerController.text,
      });

      questionController.clear();
      choiceControllers[0].clear();
      choiceControllers[1].clear();
      choiceControllers[2].clear();
      choiceControllers[3].clear();
      correctAnswerController.clear();
    });
  }

  // CODING PROBLEM CONTROLLERS
  final problemStatementController = TextEditingController();
  final testCasesController = TextEditingController();

  final firestoreService = CloudFirestoreService();

  void showBanner(String content) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void addLesson() async {
    if (!lessonTitleFormKey.currentState!.validate()) {
      return;
    }

    if (fileName == null) {
      showBanner('Please select a learning material file.');

      return;
    }

    if (activityType == 'Multiple Choice' && questionList.isEmpty) {
      showBanner('Please add a question.');

      return;
    }

    if (activityType == 'Coding Problem' &&
        !codingProblemFormKey.currentState!.validate()) {
      return;
    }

    final dynamic content;

    activityType == 'Multiple Choice'
        ? content = questionList
        : content = {
            'problemStatement': problemStatementController.text,
            'testCases': testCasesController.text,
          };

    QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Adding the lesson...');

    await firestoreService
        .addLesson(
      context,
      widget.courseId,
      lessonTitleController.text,
      fileName!,
      fileBytes!,
      activityType,
      content,
    )
        .then((_) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: InstructorAppbar(),
      ),
      body: Center(
        child: SizedBox(
          width: 1050,
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TITLE
                      const Text(
                        'Add New Lesson',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // SAVE BUTTON
                      ElevatedButton.icon(
                        onPressed: addLesson,
                        label: const Text(
                          'ADD LESSON',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        icon: const Icon(Icons.save_rounded),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.green[800]),
                          foregroundColor:
                              const WidgetStatePropertyAll(Colors.white),
                        ),
                      )
                    ],
                  ),
                  const Gap(20),

                  Form(
                    key: lessonTitleFormKey,
                    child: Row(
                      children: [
                        const Text(
                          'Lesson Title:',
                          style: TextStyle(fontSize: 20),
                        ),
                        const Gap(10),
                        Expanded(
                          child: TextFormField(
                            controller: lessonTitleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Required. Please enter lesson title.';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  const Gap(10),

                  // LEARNING MATERIAL
                  Row(
                    children: [
                      Text(
                        'Learning Material: ${fileName ?? 'None Selected'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Gap(20),
                      ElevatedButton.icon(
                        onPressed: pickFile,
                        label: Text(
                            fileName == null ? 'Select File' : 'Change File'),
                        icon: const Icon(Icons.attach_file_rounded),
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(primary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                      ),
                    ],
                  ),

                  // ACTIVITY TYPE DROPDOWN
                  Row(
                    children: [
                      const Text(
                        'Activity Type:',
                        style: TextStyle(fontSize: 18),
                      ),
                      const Gap(10),
                      DropdownButton<String>(
                        value: activityType,
                        items: ['Multiple Choice', 'Coding Problem']
                            .map((type) => DropdownMenuItem(
                                value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            activityType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const Gap(10),

                  if (activityType == 'Multiple Choice') ...[
                    // MULTIPLE CHOICE
                    Form(
                      key: multipleChoiceFormKey,
                      child: Row(
                        children: [
                          // QUESTIONS
                          SizedBox(
                            height: 405,
                            width: 510,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Question List:',
                                  style: TextStyle(fontSize: 20),
                                ),
                                questionList.isEmpty
                                    ? const Text(
                                        'Add your first question!',
                                      )
                                    : Flexible(
                                        fit: FlexFit.loose,
                                        child: ListView.builder(
                                          itemCount: questionList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Card(
                                              child: ListTile(
                                                title: Text(questionList[index]
                                                    ['question']),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const Gap(2),
                          // TEXTFIELDS
                          SizedBox(
                            height: 405,
                            width: 510,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Add a Question',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    TextButton.icon(
                                      onPressed: addQuestion,
                                      label: const Text('Add'),
                                      icon: const Icon(Icons.add_rounded),
                                      style: const ButtonStyle(
                                        backgroundColor:
                                            WidgetStatePropertyAll(primary),
                                        foregroundColor: WidgetStatePropertyAll(
                                            Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                const Gap(10),
                                Expanded(
                                  child: ListView(
                                    children: [
                                      TextFormField(
                                        controller: questionController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          label: Text('Question'),
                                        ),
                                        minLines: 1,
                                        maxLines: 2,
                                        validator: (value) {
                                          if (value == null ||
                                              value == '' ||
                                              value.isEmpty) {
                                            return 'Required. Please provide a question.';
                                          }
                                          return null;
                                        },
                                      ),
                                      ...List.generate(
                                        4,
                                        (index) => Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: TextFormField(
                                            controller:
                                                choiceControllers[index],
                                            decoration: InputDecoration(
                                              border:
                                                  const OutlineInputBorder(),
                                              label: Text(
                                                  'Option ${String.fromCharCode(index + 65)}'),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value == '' ||
                                                  value.isEmpty) {
                                                return 'Required. Please provide Option ${String.fromCharCode(index + 65)}';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      const Gap(10),
                                      TextFormField(
                                        controller: correctAnswerController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          label: Text('Correct Answer'),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value == '' ||
                                              value.isEmpty) {
                                            return 'Required. Please provide the correct answer.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ] else ...[
                    // CODING PROBLEM
                    Form(
                      key: codingProblemFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: problemStatementController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Problem Statement'),
                            ),
                            minLines: 1,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null ||
                                  value == '' ||
                                  value.isEmpty) {
                                return 'Required. Please provide the problem statement.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),
                          TextFormField(
                            controller: testCasesController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Test Cases'),
                            ),
                            minLines: 1,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null ||
                                  value == '' ||
                                  value.isEmpty) {
                                return 'Required. Please provide test case/s.';
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
