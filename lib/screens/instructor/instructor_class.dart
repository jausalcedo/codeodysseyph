import 'dart:typed_data';

import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:disclosure/disclosure.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class InstructorClassScreen extends StatefulWidget {
  const InstructorClassScreen({
    super.key,
    required this.userId,
    required this.classCode,
    required this.courseCodeYearBlock,
    required this.courseTitle,
  });

  final String userId;
  final String classCode;
  final String courseCodeYearBlock;
  final String courseTitle;

  @override
  State<InstructorClassScreen> createState() => _InstructorClassScreenState();
}

class _InstructorClassScreenState extends State<InstructorClassScreen>
    with SingleTickerProviderStateMixin {
  // TAB ESSENTIALS
  late TabController tabController;

  // SERVICES
  final _firestoreService = CloudFirestoreService();
  final _storageService = FirebaseStorageService();

  // OPERATIONS
  Future<void> downloadLearningMaterial(String learningMaterialPath) async {
    final downloadUrl = await _storageService.storageRef
        .child(learningMaterialPath)
        .getDownloadURL();
    if (!await launchUrl(Uri.parse(downloadUrl))) {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text:
            'There was a problem downloading the learning material. Please try again in a few minutes...',
        confirmBtnText: 'Okay',
        // ignore: use_build_context_synchronously
        onCancelBtnTap: Navigator.of(context).pop,
      );
    }
  }

  // LESSON CONTROLLERS
  final lessonTitleController = TextEditingController();
  final addBeforeIndexController = TextEditingController();

  // ADD LESSON ESSENTIALS
  String? fileName;
  Uint8List? fileBytes;
  int? numberOfLessons;
  String addWhere = 'Add to Last';

  // LESSON FORM KEYS
  final lessonFormKey = GlobalKey<FormState>();
  final addBeforeLessonFormKey = GlobalKey<FormState>();

  void openAddLessonModal() {
    // SHOW MODAL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add New Lesson',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StatefulBuilder(
              builder: (context, setState) => Row(
                children: [
                  // ADD TO WHERE
                  numberOfLessons != 0
                      ? SizedBox(
                          width: 140,
                          child: DropdownButtonFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            value: addWhere,
                            items: ['Add to Last', 'Add Before']
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                addWhere = value!;
                              });
                            },
                          ),
                        )
                      : const SizedBox(),
                  const Gap(5),
                  // IF ADD BEFORE, SHOW INDEX INPUT
                  addWhere == 'Add Before'
                      ? Form(
                          key: addBeforeLessonFormKey,
                          child: SizedBox(
                            width: 115,
                            child: TextFormField(
                              controller: addBeforeIndexController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Before Lesson'),
                              ),
                              textAlign: TextAlign.center,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required.';
                                }

                                if (int.parse(value) <= 0 ||
                                    int.parse(value) > numberOfLessons!) {
                                  return 'Invalid input.';
                                }
                                return null;
                              },
                            ),
                          ),
                        )
                      : const SizedBox(),
                  const Gap(10),
                  // CLOSE MODAL BUTTON
                  IconButton(
                    onPressed: () {
                      // CLEAR ALL FIELDS
                      clearLessonFields();
                      // CLOSE THE MODAL
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                    style: const ButtonStyle(
                      foregroundColor: WidgetStatePropertyAll(Colors.red),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        content: SizedBox(
          width: 750,
          height: 350,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: StatefulBuilder(
              builder: (context, setState) {
                void pickFile() async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
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

                return ListView(
                  children: [
                    Form(
                      key: lessonFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE
                          const Text(
                            'Title:',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            controller: lessonTitleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter lesson title',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required. Please enter lesson title.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),

                          // LEARNING MATERIAL
                          const Text(
                            'Learning Material:',
                            style: TextStyle(fontSize: 20),
                          ),

                          // FILE NAME
                          Text(
                            fileName ?? 'None Selected',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Gap(10),

                          // SELECT FILE BUTTON
                          ElevatedButton.icon(
                            onPressed: pickFile,
                            label: Text(
                              fileName == null ? 'Select File' : 'Change File',
                            ),
                            icon: const Icon(Icons.attach_file_rounded),
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(primary),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          // ADD BUTTON
          Center(
            child: TextButton.icon(
              onPressed: addLesson,
              label: const Text(
                'Add',
                style: TextStyle(fontSize: 18),
              ),
              icon: const Icon(Icons.add),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green[800]),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addLesson() async {
    if (!lessonFormKey.currentState!.validate()) {
      return;
    }

    if (addWhere == 'Add Before') {
      if (!addBeforeLessonFormKey.currentState!.validate()) {
        return;
      }
    }

    if (fileName == null) {
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please select a learning material.',
        onConfirmBtnTap: Navigator.of(context).pop,
      );
    }

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    await _firestoreService
        .addLesson(
      context: context,
      collection: 'classes',
      documentId: widget.classCode,
      fileName: fileName!,
      fileBytes: fileBytes!,
      lessonTitle: lessonTitleController.text,
      insertAtIndex: addWhere == 'Add Before'
          ? int.parse(addBeforeIndexController.text) - 1
          : null,
    )
        .then((_) {
      clearLessonFields();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    });
  }

  void clearLessonFields() {
    lessonTitleController.clear();
    addBeforeIndexController.clear();
    fileName = null;
    fileBytes = null;
  }

  // ADD ACTIVITY ESSENTIALS
  final activityTitleController = TextEditingController();
  String activityType = 'Multiple Choice';
  int? lessonIndexToBindActivity;
  DateTime? deadline;
  final maxScoreController = TextEditingController();

  // ADD ACTIVITY FORM KEYS
  final chooseLessonFormKey = GlobalKey<FormState>();
  final maxScoreFormKey = GlobalKey<FormState>();
  final questionFormKey = GlobalKey<FormState>();

  // MULTIPLE CHOICE ESSENTIALS
  final questionController = TextEditingController();
  final choiceControllers =
      List.generate(4, (index) => TextEditingController());
  final correctAnswerController = TextEditingController();
  List<Map<String, dynamic>> questionList = [];
  int? duplicateChoiceIndex;

  // CODING PROBLEM CONTROLLERS
  final problemStatementController = TextEditingController();
  final constraintsController = TextEditingController();
  final List<Map<String, dynamic>> examples = [];
  final List<Map<String, dynamic>> testCases = [];
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  String? lessonTag;

  Future<void> openAddActivityModal() async {
    // FETCH RAW CLASS DATA
    await _firestoreService
        .getCourseClassDataFuture('classes', widget.classCode)
        .then((futureClassData) {
      final Map<String, dynamic> classData = futureClassData.data()!;
      final List<dynamic> lessonList = classData['lessons'];
      final numberOfLessons = lessonList.length;

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Activity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  // CLEAR ALL FIELDS
                  clearActivityFields();
                  // CLOSE THE MODAL
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close_rounded),
                style: const ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.red),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 750,
            height: 590,
            child: StatefulBuilder(
              builder: (BuildContext context, setState) {
                Future<void> setDeadline() async {
                  final now = DateTime.now();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: deadline ?? now,
                    firstDate: DateTime(now.year),
                    lastDate: DateTime(now.year + 1),
                  );

                  if (deadline != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        deadline = DateTime(
                          pickedDate!.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }

                  if (pickedDate != null && pickedDate != deadline) {
                    setState(() {
                      deadline = pickedDate;
                    });
                  }
                }

                void addQuestion() {
                  if (!questionFormKey.currentState!.validate()) {
                    return;
                  }

                  if (!chooseLessonFormKey.currentState!.validate()) {
                    return;
                  }

                  final choices = [
                    choiceControllers[0].text,
                    choiceControllers[1].text,
                    choiceControllers[2].text,
                    choiceControllers[3].text,
                  ];

                  duplicateChoiceIndex = areChoicesUnique(choices);

                  if (duplicateChoiceIndex != null) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Error',
                      text:
                          'Duplicate choice value: ${choiceControllers[duplicateChoiceIndex!].text}. Please make sure that all choices are unique.',
                    );
                    return;
                  }

                  setState(() {
                    questionList.add({
                      'question': questionController.text,
                      'choices': choices,
                      'correctAnswer': correctAnswerController.text,
                    });
                    clearMultipleChoiceFields();
                  });
                }

                void addToExamples() {
                  // TO DO
                }

                void addToTestCases() {
                  // TO DO
                }

                return Column(
                  children: [
                    // LESSON
                    numberOfLessons != 0
                        ? Form(
                            key: chooseLessonFormKey,
                            child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Lesson'),
                              ),
                              items: List.generate(
                                lessonList.length,
                                (index) => DropdownMenuItem(
                                  value: index,
                                  child: Text(lessonList[index]['title']),
                                ),
                              ),
                              onChanged: (value) {
                                lessonIndexToBindActivity = value;
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Required. Please choose a lesson.';
                                }
                                return null;
                              },
                            ),
                          )
                        : const SizedBox(),
                    const Gap(10),
                    Row(
                      children: [
                        // TITLE
                        Expanded(
                          child: TextFormField(
                            controller: activityTitleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Title (Optional)'),
                            ),
                          ),
                        ),
                        const Gap(10),

                        // ACTIVITY TYPE
                        Expanded(
                          child: DropdownButtonFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Activity Type'),
                            ),
                            value: activityType,
                            items: ['Multiple Choice', 'Coding Problem']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                activityType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        // DEADLINE
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(primary),
                                foregroundColor:
                                    WidgetStatePropertyAll(Colors.white),
                              ),
                              onPressed: setDeadline,
                              child: Text(deadline != null
                                  ? DateFormat.yMMMEd().format(deadline!)
                                  : 'Set Deadline'),
                            ),
                          ),
                        ),
                        const Gap(10),

                        // MAX SCORE
                        Expanded(
                          child: Form(
                            key: maxScoreFormKey,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Max Score'),
                              ),
                              controller: maxScoreController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required. Please set the max score students can get.';
                                }
                                return null;
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    const Gap(10),
                    const Divider(),
                    const Gap(10),

                    // FIELDS FOR EACH ACTIVITY TYPE
                    activityType == 'Multiple Choice'
                        ? SizedBox(
                            width: 750,
                            height: 370,
                            child: StatefulBuilder(
                              builder: (context, setState) => Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Question List:'),
                                        questionList.isNotEmpty == true
                                            ? Expanded(
                                                child: ListView.builder(
                                                  itemCount:
                                                      questionList.length,
                                                  itemBuilder:
                                                      (context, index) => Card(
                                                    child: ListTile(
                                                      title: Text(
                                                        questionList[index]
                                                            ['question'],
                                                        style: const TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'Choices: ${questionList[index]['choices'][0]}, ${questionList[index]['choices'][1]}, ${questionList[index]['choices'][2]}, ${questionList[index]['choices'][3]}',
                                                        style: const TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const Text(
                                                'No questions yet. Add your first question now!'),
                                      ],
                                    ),
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Form(
                                          key: questionFormKey,
                                          child: Expanded(
                                            child: ListView(
                                              children: [
                                                // QUESTION
                                                TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    label: Text('Question'),
                                                  ),
                                                  controller:
                                                      questionController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return 'Required. Please provide a question.';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const Gap(10),

                                                // CHOICES
                                                ...List.generate(
                                                  choiceControllers.length,
                                                  (index) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: TextFormField(
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            const OutlineInputBorder(),
                                                        label: Text(
                                                            'Choice ${String.fromCharCode(index + 65)}'),
                                                      ),
                                                      controller:
                                                          choiceControllers[
                                                              index],
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value
                                                                .trim()
                                                                .isEmpty) {
                                                          return 'Required. Choice ${String.fromCharCode(index + 65)} cannot be empty.';
                                                        }

                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const Gap(5),

                                                // CORRECT ANSWER
                                                TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    label:
                                                        Text('Correct Answer'),
                                                  ),
                                                  controller:
                                                      correctAnswerController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return 'Required. Please provide the correct answer.';
                                                    }

                                                    if (choiceControllers.every(
                                                      (controller) =>
                                                          controller.text !=
                                                          value,
                                                    )) {
                                                      return 'Please input a value from the choices.';
                                                    }

                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Gap(10),
                                        ElevatedButton.icon(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(primary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                          ),
                                          onPressed: addQuestion,
                                          label: const Text('Add Question'),
                                          icon: const Icon(Icons.add_rounded),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView(
                            children: [
                              // PROBLEM STATEMENT
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text('Problem Statement'),
                                ),
                                maxLines: 3,
                                controller: problemStatementController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required. Please provide the problem statement.';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(10),

                              // CONSTRAINTS
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text('Constraints'),
                                ),
                                maxLines: 3,
                                controller: constraintsController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required. Please provide the constraints.';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(10),

                              // EXAMPLES AND TEST CASES
                              Expanded(
                                child: Row(
                                  children: [
                                    // EXAMPLES
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: examples.length,
                                        itemBuilder: (context, index) =>
                                            const Card(
                                          child: ListTile(
                                            title: Text('Input : Output'),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // TEST CASES
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: testCases.length,
                                        itemBuilder: (context, index) =>
                                            const Card(
                                          child: ListTile(
                                            title: Text('Input : Output'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  // INPUT
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        label: Text('Input'),
                                      ),
                                      controller: inputController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required. Please an input.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const Gap(10),

                                  // OUTPUT
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        label: Text('Output'),
                                      ),
                                      controller: outputController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required. Please an output.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const Gap(10),

                                  MenuAnchor(
                                    alignmentOffset: const Offset(-100, 0),
                                    builder: (context, controller, child) {
                                      return ElevatedButton.icon(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(primary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white)),
                                        onPressed: () {
                                          if (controller.isOpen) {
                                            controller.close();
                                          } else {
                                            controller.open();
                                          }
                                        },
                                        label: const Text('Add'),
                                        icon: const Icon(Icons.add_rounded),
                                      );
                                    },
                                    menuChildren: [
                                      // TO EXAMPLES
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    secondary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            shape: WidgetStatePropertyAll(
                                                ContinuousRectangleBorder()),
                                          ),
                                          onPressed: addToExamples,
                                          child: const Text('to Examples'),
                                        ),
                                      ),
                                      // TO TEST CASES
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    secondary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            shape: WidgetStatePropertyAll(
                                                ContinuousRectangleBorder()),
                                          ),
                                          onPressed: addToTestCases,
                                          child: const Text('to Test Cases'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          )
                  ],
                );
              },
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green[800]),
                  foregroundColor: const WidgetStatePropertyAll(Colors.white),
                ),
                onPressed: addActivity,
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  int? areChoicesUnique(List<String> choices) {
    final Map<String, int> seenStrings = {};
    for (int i = 0; i < choices.length; i++) {
      if (seenStrings.containsKey(choices[i])) {
        // Return the index of the duplicate
        return i;
      } else {
        // Store the string and its index
        seenStrings[choices[i]] = i;
      }
    }
    return null;
  }

  Future<void> addActivity() async {
    if (!chooseLessonFormKey.currentState!.validate()) {
      return;
    }

    if (!maxScoreFormKey.currentState!.validate()) {
      return;
    }

    if (deadline == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please set a deadline for the activity.',
      );
    }
  }

  // // MULTIPLE CHOICE ESSENTIALS
  // final questionController = TextEditingController();
  // final choiceControllers =
  //     List.generate(4, (index) => TextEditingController());
  // final correctAnswerController = TextEditingController();
  // List<Map<String, dynamic>> questionList = [];
  // int? duplicateChoiceIndex;

  void clearActivityFields() {
    activityTitleController.clear();
    activityType = 'Multiple Choice';
    lessonIndexToBindActivity = null;
    deadline = null;
    maxScoreController.clear();

    clearMultipleChoiceFields();
  }

  void clearMultipleChoiceFields() {
    questionController.clear();
    for (int i = 0; i < choiceControllers.length; i++) {
      choiceControllers[i].clear();
    }
    correctAnswerController.clear();
    questionList = [];
    duplicateChoiceIndex = null;
  }

  void openAddAdditionalResourceModal() {
    // TO DO
  }

  Future<void> deleteLesson(Map<String, dynamic> lesson) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Confirm Delete?\n${lesson['title']}',
      text: 'This action cannot be undone.',
      confirmBtnText: 'Delete',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        // DISMISS CONFIRM BUTTON
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        // SHOW LOADING
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
        );

        await _firestoreService
            .deleteLesson(context, 'classes', widget.classCode, lesson)
            .then((_) {
          // DISMISS LOADING MODAL
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        });
      },
      showCancelBtn: true,
      cancelBtnText: 'Cancel',
      onCancelBtnTap: Navigator.of(context).pop,
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this); // 4 tabs
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: InstructorAppbar(userId: widget.userId),
      ),
      body: Center(
        child: SizedBox(
          width: 1080,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // COURSE CODE YEAR BLOCK
                          Container(
                            width: 225,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 19, 27, 99),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.courseCodeYearBlock,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Gap(10),
                          // JAVA LOGO
                          Image.asset(
                            "assets/images/java-logo.png",
                            width: 50,
                            height: 50,
                          ),
                          // COURSE TITLE
                          Text(
                            widget.courseTitle,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 19, 27, 99),
                            ),
                          ),
                        ],
                      ),
                      // CLASS CODE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.classCode,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: primary,
                              ),
                            ),
                            const Text(
                              'Class Code',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  TabBar(
                    controller: tabController,
                    tabs: const [
                      Tab(text: 'Course Work'),
                      Tab(text: 'Examinations'),
                      Tab(text: 'Student Performance'),
                      Tab(text: 'Annoucements'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        // COURSE WORK
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Lessons:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  MenuAnchor(
                                    alignmentOffset: const Offset(-100, 0),
                                    builder: (context, controller, child) {
                                      return ElevatedButton.icon(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(primary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white)),
                                        onPressed: () {
                                          if (controller.isOpen) {
                                            controller.close();
                                          } else {
                                            controller.open();
                                          }
                                        },
                                        label: const Text('Add'),
                                        icon: const Icon(Icons.add_rounded),
                                      );
                                    },
                                    menuChildren: [
                                      // ADD LESSON
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    secondary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            shape: WidgetStatePropertyAll(
                                                ContinuousRectangleBorder()),
                                          ),
                                          onPressed: openAddLessonModal,
                                          label: const Text('New Lesson'),
                                          icon: const Icon(
                                              Icons.library_books_rounded),
                                        ),
                                      ),
                                      // ADD ACTIVITY
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    secondary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            shape: WidgetStatePropertyAll(
                                                ContinuousRectangleBorder()),
                                          ),
                                          onPressed: openAddActivityModal,
                                          label: const Text('New Activity'),
                                          icon: const Icon(Icons
                                              .drive_file_rename_outline_rounded),
                                        ),
                                      ),
                                      // ADD ADDITIONAL RESOURCES
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    secondary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            shape: WidgetStatePropertyAll(
                                                ContinuousRectangleBorder()),
                                          ),
                                          onPressed:
                                              openAddAdditionalResourceModal,
                                          label:
                                              const Text('Additional Resource'),
                                          icon: const Icon(
                                              Icons.attach_file_rounded),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(5),

                              // LESSON LIST
                              Expanded(
                                child: ListView(
                                  children: [
                                    StreamBuilder(
                                      stream: _firestoreService
                                          .getClassDataStream(widget.classCode),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final classData = snapshot.data!.data();

                                        final lessonList =
                                            classData!['lessons'];
                                        numberOfLessons = lessonList.length;

                                        return DisclosureGroup(
                                          multiple: false,
                                          clearable: true,
                                          // insets: const EdgeInsets.all(15),
                                          children: List<Widget>.generate(
                                            lessonList.length,
                                            (index) {
                                              final List<dynamic> activities =
                                                  lessonList[index]
                                                          ['activities'] ??
                                                      [];

                                              final List<dynamic>
                                                  additionalResources =
                                                  lessonList[index][
                                                          'additionalResources'] ??
                                                      [];

                                              return Disclosure(
                                                key: ValueKey('lesson-$index'),
                                                wrapper: (state, child) {
                                                  return Card.outlined(
                                                    color: primary,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        color: Colors.black26,
                                                        width: state.closed
                                                            ? 1
                                                            : 2,
                                                      ),
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                header: DisclosureButton(
                                                  child: ListTile(
                                                    title: Text(
                                                      'Lesson ${index + 1}: ${lessonList[index]['title']}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    trailing:
                                                        const DisclosureIcon(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                divider:
                                                    const Divider(height: 1),
                                                child: Container(
                                                  color: Colors.white,
                                                  width: double.infinity,
                                                  // CONTENT HEIGHT
                                                  height: 400,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // LEARNING MATERIAL
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Learning Material: ${lessonList[index]['title']}.pdf',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    WidgetStatePropertyAll(
                                                                        Colors.green[
                                                                            800]),
                                                                foregroundColor:
                                                                    const WidgetStatePropertyAll(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                              onPressed: () =>
                                                                  downloadLearningMaterial(
                                                                      lessonList[
                                                                              index]
                                                                          [
                                                                          'learningMaterial']),
                                                              child: const Row(
                                                                children: [
                                                                  Text(
                                                                      'Download'),
                                                                  Icon(Icons
                                                                      .download_rounded)
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        // ACTIVITIES
                                                        const Text(
                                                          'Activities:',
                                                          // style: TextStyle(
                                                          //   fontSize: 20,
                                                          // ),
                                                        ),
                                                        activities.isEmpty
                                                            ? const Text(
                                                                'No activities yet.')
                                                            : SizedBox(
                                                                height: 145,
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      activities
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          Card(
                                                                    child:
                                                                        ListTile(
                                                                      title: Text(
                                                                          'Activity ${index + 1} - ${activities[index]['activityTitle']}'),
                                                                      subtitle:
                                                                          Text(
                                                                              'Type: ${activities[index]['activityType']}'),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                        const Gap(5),

                                                        // ADDITIONAL RESOURCES
                                                        const Text(
                                                          'Additional Resources:',
                                                          // style: TextStyle(
                                                          //   fontSize: 20,
                                                          // ),
                                                        ),
                                                        additionalResources
                                                                .isEmpty
                                                            ? const Text(
                                                                'Empty.')
                                                            : SizedBox(
                                                                height: 145,
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      additionalResources
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          Card(
                                                                    child:
                                                                        ListTile(
                                                                      title: Text(
                                                                          additionalResources[index]
                                                                              [
                                                                              'resourceName']),
                                                                      subtitle:
                                                                          Text(
                                                                              'Type: ${additionalResources[index]['resourceTitle']}'),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // EXAMINATIONS
                        const Placeholder(),
                        // STUDENT PERFORMANCE
                        const Placeholder(),
                        // ANNOUNCEMENTS
                        const Placeholder(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
