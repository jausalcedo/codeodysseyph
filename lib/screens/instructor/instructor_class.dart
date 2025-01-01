import 'dart:typed_data';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/instructor/instructor_activity.dart';
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
    required this.instructorId,
    required this.classCode,
    required this.courseCodeYearBlock,
    required this.courseTitle,
  });

  final String instructorId;
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
  final problemStatementFormKey = GlobalKey<FormState>();
  final constraintsFormKey = GlobalKey<FormState>();
  final inputOutputFormKey = GlobalKey<FormState>();

  // MULTIPLE CHOICE ESSENTIALS
  final questionController = TextEditingController();
  final choiceControllers =
      List.generate(4, (index) => TextEditingController());
  final correctAnswerController = TextEditingController();
  List<Map<String, dynamic>> questions = [];
  int? duplicateChoiceIndex;

  // CODING PROBLEM CONTROLLERS
  final problemStatementController = TextEditingController();
  final constraintsController = TextEditingController();
  List<Map<String, dynamic>> examples = [];
  List<Map<String, dynamic>> testCases = [];
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
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    title: 'Are you sure?',
                    text: 'Any unsaved data will be lost.',
                    confirmBtnText: 'Yes',
                    onConfirmBtnTap: () {
                      // CLEAR ALL FIELDS
                      clearActivityFields();
                      // CLOSE THE ALERT
                      Navigator.of(context).pop();
                      // CLOSE THE ADD ACTIVTIY MODAL
                      Navigator.of(context).pop();
                    },
                    showCancelBtn: true,
                    cancelBtnText: 'Go Back',
                    onCancelBtnTap: Navigator.of(context).pop,
                  );
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
                    firstDate: now,
                    lastDate: DateTime(now.year + 1, now.month - 6, now.day),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        deadline = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                }

                return ListView(
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
                                  ? DateFormat.yMMMEd()
                                      .add_jm()
                                      .format(deadline!)
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

                                if (int.tryParse(value) == null) {
                                  return 'Please input a number';
                                }

                                if (int.parse(value) <= 0) {
                                  return 'Please enter a non-negative and non-zero score';
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
                            height: 365,
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                void addQuestion() {
                                  if (!questionFormKey.currentState!
                                      .validate()) {
                                    return;
                                  }

                                  if (!chooseLessonFormKey.currentState!
                                      .validate()) {
                                    return;
                                  }

                                  final choices = [
                                    choiceControllers[0].text,
                                    choiceControllers[1].text,
                                    choiceControllers[2].text,
                                    choiceControllers[3].text,
                                  ];

                                  duplicateChoiceIndex =
                                      areChoicesUnique(choices);

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
                                    questions.add({
                                      'question': questionController.text,
                                      'choices': choices,
                                      'correctAnswer':
                                          correctAnswerController.text,
                                    });
                                    clearMultipleChoiceFields();
                                  });
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Question List:'),
                                          questions.isNotEmpty
                                              ? Expanded(
                                                  child: ListView.builder(
                                                    itemCount: questions.length,
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Card(
                                                      child: ListTile(
                                                        title: Tooltip(
                                                          message:
                                                              questions[index]
                                                                  ['question'],
                                                          child: Text(
                                                            questions[index]
                                                                ['question'],
                                                            style:
                                                                const TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        subtitle: Tooltip(
                                                          message: questions[
                                                                  index]
                                                              ['correctAnswer'],
                                                          child: Text(
                                                            'Correct Answer: ${questions[index]['correctAnswer']}',
                                                            style:
                                                                const TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
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
                                                          value
                                                              .trim()
                                                              .isEmpty) {
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
                                                      label: Text(
                                                          'Correct Answer'),
                                                    ),
                                                    controller:
                                                        correctAnswerController,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty) {
                                                        return 'Required. Please provide the correct answer.';
                                                      }

                                                      if (choiceControllers
                                                          .every(
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
                                                  WidgetStatePropertyAll(
                                                      primary),
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
                                );
                              },
                            ),
                          )
                        : SizedBox(
                            width: 750,
                            height: 365,
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                void addToExamples() {
                                  if (!inputOutputFormKey.currentState!
                                      .validate()) {
                                    return;
                                  }
                                  setState(() {
                                    examples.add({
                                      'input': inputController.text,
                                      'output': outputController.text,
                                    });
                                  });
                                  clearInputOutputControllers();
                                }

                                void addToTestCases() {
                                  if (!inputOutputFormKey.currentState!
                                      .validate()) {
                                    return;
                                  }
                                  setState(() {
                                    testCases.add({
                                      'input': inputController.text,
                                      'output': outputController.text,
                                    });
                                  });
                                  clearInputOutputControllers();
                                }

                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 315,
                                      child: ListView(
                                        children: [
                                          // PROBLEM STATEMENT
                                          Form(
                                            key: problemStatementFormKey,
                                            child: TextFormField(
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                label:
                                                    Text('Problem Statement'),
                                              ),
                                              minLines: 1,
                                              maxLines: 2,
                                              controller:
                                                  problemStatementController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Required. Please provide the problem statement.';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const Gap(10),

                                          // CONSTRAINTS
                                          Form(
                                            key: constraintsFormKey,
                                            child: TextFormField(
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                label: Text('Constraints'),
                                              ),
                                              minLines: 1,
                                              maxLines: 2,
                                              controller: constraintsController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Required. Please provide the constraints.';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const Gap(10),

                                          // EXAMPLES AND TEST CASES
                                          SizedBox(
                                            height: 140,
                                            child: Row(
                                              children: [
                                                // EXAMPLES
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text('Examples:'),
                                                      examples.isNotEmpty
                                                          ? Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                itemCount:
                                                                    examples
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                            index) =>
                                                                        Card(
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                        'Input: ${examples[index]['input']}'),
                                                                    subtitle: Text(
                                                                        'Output: ${examples[index]['output']}'),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : const Text(
                                                              'No examples yet.'),
                                                    ],
                                                  ),
                                                ),

                                                // TEST CASES
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text('Test Cases:'),
                                                      testCases.isNotEmpty
                                                          ? Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                itemCount:
                                                                    testCases
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                            index) =>
                                                                        Card(
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                        'Input: ${testCases[index]['input']}'),
                                                                    subtitle: Text(
                                                                        'Output: ${testCases[index]['output']}'),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : const Text(
                                                              'No test cases yet.'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Gap(10),

                                          Form(
                                            key: inputOutputFormKey,
                                            child: Row(
                                              children: [
                                                // INPUT
                                                Expanded(
                                                  child: TextFormField(
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      label: Text('Input'),
                                                    ),
                                                    controller: inputController,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty) {
                                                        return 'Required. Please provide an input.';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const Gap(10),

                                                // OUTPUT
                                                Expanded(
                                                  child: TextFormField(
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      label: Text('Output'),
                                                    ),
                                                    controller:
                                                        outputController,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty) {
                                                        return 'Required. Please provide an output.';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const Gap(10),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const Gap(10),
                                    MenuAnchor(
                                      alignmentOffset: const Offset(-100, 0),
                                      builder: (context, controller, child) {
                                        return ElevatedButton.icon(
                                          style: const ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      primary),
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
                                );
                              },
                            ),
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
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please set a deadline for the activity.',
      );
    }

    dynamic activityContent;

    if (activityType == 'Multiple Choice') {
      if (questions.isEmpty) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please add at least one question.',
        );
      }
      activityContent = questions;
    } else {
      if (examples.isEmpty) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please add at least one example.',
        );
      }
      if (testCases.isEmpty) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please add at least one test case.',
        );
      }
      activityContent = {
        'problemStatement': problemStatementController.text,
        'constraints': constraintsController.text,
        'examples': examples,
        'testCases': testCases,
      };
    }

    final newActivity = {
      'title': lessonTitleController.text,
      'activityType': activityType,
      'deadline': deadline,
      'maxScore': int.parse(maxScoreController.text),
      'content': activityContent,
    };

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    await _firestoreService
        .addActivityToLesson(
      context: context,
      instructorId: widget.instructorId,
      classCode: widget.classCode,
      lessonIndex: lessonIndexToBindActivity!,
      newActivity: newActivity,
    )
        .then((_) {
      clearActivityFields();
    });
  }

  void clearActivityFields() {
    activityTitleController.clear();
    activityType = 'Multiple Choice';
    lessonIndexToBindActivity = null;
    deadline = null;
    maxScoreController.clear();

    clearMultipleChoiceFields();
    questions = [];

    clearCodingProblemFields();
    examples = [];
    testCases = [];
  }

  void clearMultipleChoiceFields() {
    questionController.clear();
    for (int i = 0; i < choiceControllers.length; i++) {
      choiceControllers[i].clear();
    }
    correctAnswerController.clear();
    duplicateChoiceIndex = null;
  }

  void clearCodingProblemFields() {
    problemStatementController.clear();
    constraintsController.clear();
  }

  void clearInputOutputControllers() {
    inputController.clear();
    outputController.clear();
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

  // NAVIGATION OPERATIONS
  void openInstructorActivityScreen(
      String userId, dynamic activity, String lessonTitle, int activityNumber) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorActivityScreen(
          instructorId: userId,
          activity: activity,
          lessonTitle: lessonTitle,
          activityNumber: activityNumber,
        ),
      ),
    );
  }

  // ASSESSMENT FUNCTIONS
  void openAddQuizModal() {
    // TO DO
  }

  // EXAM ESSENTIALS
  String exam = 'Midterm';
  String examType = 'Written';
  DateTime? openTime;
  DateTime? closeTime;
  int durationMinutes = 30;

  void openAddExamModal() {
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add an Examination',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.warning,
                  title: 'Are you sure?',
                  text: 'Any unsaved data will be lost.',
                  confirmBtnText: 'Yes',
                  onConfirmBtnTap: () {
                    // CLEAR ALL FIELDS
                    clearActivityFields();
                    // CLOSE THE ALERT
                    Navigator.of(context).pop();
                    // CLOSE THE ADD ACTIVTIY MODAL
                    Navigator.of(context).pop();
                  },
                  showCancelBtn: true,
                  cancelBtnText: 'Go Back',
                  onCancelBtnTap: Navigator.of(context).pop,
                );
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
              Future<void> setDate({required bool isOpen}) async {
                final now = DateTime.now();
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: deadline ?? now,
                  firstDate: now,
                  lastDate: DateTime(now.year + 1, now.month - 6, now.day),
                );

                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    // ignore: use_build_context_synchronously
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      isOpen == true
                          ? openTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            )
                          : closeTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                    });
                  }
                }
              }

              return ListView(
                children: [
                  Row(
                    children: [
                      // TITLE
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Exam'),
                          ),
                          value: exam,
                          items: ['Midterm', 'Final']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              exam = value!;
                            });
                          },
                        ),
                      ),
                      const Gap(10),

                      // EXAM TYPE
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Exam Type'),
                          ),
                          value: examType,
                          items: ['Written', 'Laboratory']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              examType = value!;
                            });
                          },
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
                                return 'Set the max score students can get.';
                              }

                              if (int.tryParse(value) == null) {
                                return 'Please input a number';
                              }

                              if (int.parse(value) <= 0) {
                                return 'Score must be greater than 0';
                              }

                              return null;
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      // EXAM OPEN
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(primary),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: () => setDate(isOpen: true),
                            child: Text(openTime != null
                                ? 'Open Schedule:\n${DateFormat.yMMMEd().add_jm().format(openTime!)}'
                                : 'Set Open Schedule'),
                          ),
                        ),
                      ),
                      const Gap(10),

                      // EXAM CLOSE
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.red[800]),
                              foregroundColor:
                                  const WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: () => setDate(isOpen: false),
                            child: Text(closeTime != null
                                ? 'Close Schedule:\n${DateFormat.yMMMEd().add_jm().format(closeTime!)}'
                                : 'Set Close Schedule'),
                          ),
                        ),
                      ),
                      const Gap(10),

                      // DURATION
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Duration'),
                          ),
                          value: durationMinutes,
                          items: List.generate(7, (index) => 30 + index * 15)
                              .map((duration) => DropdownMenuItem(
                                    value: duration,
                                    child: Text(
                                        '${duration >= 60 ? '${duration ~/ 60} hour${duration > 60 ? 's' : ''}' : ''} ${duration % 60 > 0 ? '${duration % 60} mins' : ''}'
                                            .trim()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              durationMinutes = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  const Divider(),
                  const Gap(10),

                  // FIELDS FOR EACH EXAM TYPE
                  examType == 'Written'
                      ? SizedBox(
                          width: 750,
                          height: 365,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              void addQuestion() {
                                if (!questionFormKey.currentState!.validate()) {
                                  return;
                                }

                                final choices = [
                                  choiceControllers[0].text,
                                  choiceControllers[1].text,
                                  choiceControllers[2].text,
                                  choiceControllers[3].text,
                                ];

                                duplicateChoiceIndex =
                                    areChoicesUnique(choices);

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
                                  questions.add({
                                    'question': questionController.text,
                                    'choices': choices,
                                    'correctAnswer':
                                        correctAnswerController.text,
                                  });
                                  clearMultipleChoiceFields();
                                });
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Question List:'),
                                        questions.isNotEmpty
                                            ? Expanded(
                                                child: ListView.builder(
                                                  itemCount: questions.length,
                                                  itemBuilder:
                                                      (context, index) => Card(
                                                    child: ListTile(
                                                      title: Tooltip(
                                                        message:
                                                            questions[index]
                                                                ['question'],
                                                        child: Text(
                                                          questions[index]
                                                              ['question'],
                                                          style:
                                                              const TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      subtitle: Tooltip(
                                                        message: questions[
                                                                index]
                                                            ['correctAnswer'],
                                                        child: Text(
                                                          'Correct Answer: ${questions[index]['correctAnswer']}',
                                                          style:
                                                              const TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
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
                              );
                            },
                          ),
                        )
                      : SizedBox(
                          width: 750,
                          height: 365,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              void addToExamples() {
                                if (!inputOutputFormKey.currentState!
                                    .validate()) {
                                  return;
                                }
                                setState(() {
                                  examples.add({
                                    'input': inputController.text,
                                    'output': outputController.text,
                                  });
                                });
                                clearInputOutputControllers();
                              }

                              void addToTestCases() {
                                if (!inputOutputFormKey.currentState!
                                    .validate()) {
                                  return;
                                }
                                setState(() {
                                  testCases.add({
                                    'input': inputController.text,
                                    'output': outputController.text,
                                  });
                                });
                                clearInputOutputControllers();
                              }

                              return Column(
                                children: [
                                  SizedBox(
                                    height: 315,
                                    child: ListView(
                                      children: [
                                        // PROBLEM STATEMENT
                                        Form(
                                          key: problemStatementFormKey,
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('Problem Statement'),
                                            ),
                                            minLines: 1,
                                            maxLines: 2,
                                            controller:
                                                problemStatementController,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Required. Please provide the problem statement.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const Gap(10),

                                        // CONSTRAINTS
                                        Form(
                                          key: constraintsFormKey,
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('Constraints'),
                                            ),
                                            minLines: 1,
                                            maxLines: 2,
                                            controller: constraintsController,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Required. Please provide the constraints.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const Gap(10),

                                        // EXAMPLES AND TEST CASES
                                        SizedBox(
                                          height: 140,
                                          child: Row(
                                            children: [
                                              // EXAMPLES
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Examples:'),
                                                    examples.isNotEmpty
                                                        ? Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  examples
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                          index) =>
                                                                      Card(
                                                                child: ListTile(
                                                                  title: Text(
                                                                      'Input: ${examples[index]['input']}'),
                                                                  subtitle: Text(
                                                                      'Output: ${examples[index]['output']}'),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : const Text(
                                                            'No examples yet.'),
                                                  ],
                                                ),
                                              ),

                                              // TEST CASES
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Test Cases:'),
                                                    testCases.isNotEmpty
                                                        ? Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  testCases
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                          index) =>
                                                                      Card(
                                                                child: ListTile(
                                                                  title: Text(
                                                                      'Input: ${testCases[index]['input']}'),
                                                                  subtitle: Text(
                                                                      'Output: ${testCases[index]['output']}'),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : const Text(
                                                            'No test cases yet.'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(10),

                                        Form(
                                          key: inputOutputFormKey,
                                          child: Row(
                                            children: [
                                              // INPUT
                                              Expanded(
                                                child: TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    label: Text('Input'),
                                                  ),
                                                  controller: inputController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return 'Required. Please provide an input.';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const Gap(10),

                                              // OUTPUT
                                              Expanded(
                                                child: TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    label: Text('Output'),
                                                  ),
                                                  controller: outputController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return 'Required. Please provide an output.';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const Gap(10),
                                            ],
                                          ),
                                        )
                                      ],
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
                              );
                            },
                          ),
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
              onPressed: addExamToClass,
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addExamToClass() async {
    if (!maxScoreFormKey.currentState!.validate()) {
      return;
    }

    if (openTime == null || closeTime == null) {
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text:
            'Please set the ${openTime == null ? 'Open Time' : 'Close Time'} of the exam.',
      );
    }

    dynamic examContent;

    if (examType == 'Written') {
      if (questions.isEmpty) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please add at least one question.',
        );
      }
      examContent = questions;
    } else {
      if (examples.isEmpty) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please add at least one example.',
        );
      }
      if (testCases.isEmpty) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please add at least one test case.',
        );
      }
      examContent = {
        'problemStatement': problemStatementController.text,
        'constraints': constraintsController.text,
        'examples': examples,
        'testCases': testCases,
      };
    }

    final newExam = {
      'exam': exam,
      'examType': examType,
      'openTime': openTime,
      'closeTime': closeTime,
      'durationMinutes': durationMinutes,
      'maxScore': double.parse(maxScoreController.text),
      'content': examContent,
    };

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    await _firestoreService
        .addExamToClass(
      context: context,
      instructorId: widget.instructorId,
      classCode: widget.classCode,
      newExam: newExam,
    )
        .then((_) {
      clearActivityFields();
    });
  }

  void clearExamFields() {
    exam = 'Midterm';
    examType = 'Written';
    openTime = null;
    closeTime = null;
    maxScoreController.clear();

    clearMultipleChoiceFields();
    questions = [];

    clearCodingProblemFields();
    examples = [];
    testCases = [];
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
        child: InstructorAppbar(userId: widget.instructorId),
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
                      Tab(text: 'Assessments'),
                      Tab(text: 'Student Performance'),
                      Tab(text: 'Announcements'),
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
                                            (lessonIndex) {
                                              final List<dynamic> activities =
                                                  lessonList[lessonIndex]
                                                          ['activities'] ??
                                                      [];

                                              final List<dynamic>
                                                  additionalResources =
                                                  lessonList[lessonIndex][
                                                          'additionalResources'] ??
                                                      [];

                                              return Disclosure(
                                                key: ValueKey(
                                                    'lesson-$lessonIndex'),
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
                                                      'Lesson ${lessonIndex + 1}: ${lessonList[lessonIndex]['title']}',
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
                                                              'Learning Material: ${lessonList[lessonIndex]['title']}.pdf',
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
                                                                              lessonIndex]
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
                                                                          index) {
                                                                    final DateTime
                                                                        deadline =
                                                                        activities[index]['deadline']
                                                                            .toDate();

                                                                    return Card(
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            'Activity ${index + 1} ${activities[index]['title'] != '' ? ':${activities[index]['title']}' : ''} (${activities[index]['maxScore']} points)'),
                                                                        subtitle:
                                                                            Text('Type: ${activities[index]['activityType']}'),
                                                                        trailing:
                                                                            SizedBox(
                                                                          width:
                                                                              250,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                'Deadline:\n${DateFormat.yMMMEd().add_jm().format(deadline)}',
                                                                                style: const TextStyle(fontSize: 14),
                                                                              ),
                                                                              const IconButton(
                                                                                onPressed: null,
                                                                                icon: Icon(Icons.delete_rounded),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        onTap: () =>
                                                                            openInstructorActivityScreen(
                                                                          widget
                                                                              .instructorId,
                                                                          activities[
                                                                              index],
                                                                          'Lesson ${lessonIndex + 1}: ${lessonList[index]['title']}',
                                                                          index +
                                                                              1,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                        const Gap(5),

                                                        // ADDITIONAL RESOURCES
                                                        const Text(
                                                          'Additional Resources:',
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

                        // ASSESSMENTS
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // QUIZZES
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                                      // ADD QUIZ
                                      // SizedBox(
                                      //   width: double.infinity,
                                      //   child: TextButton.icon(
                                      //     style: const ButtonStyle(
                                      //       backgroundColor:
                                      //           WidgetStatePropertyAll(
                                      //               secondary),
                                      //       foregroundColor:
                                      //           WidgetStatePropertyAll(
                                      //               Colors.white),
                                      //       shape: WidgetStatePropertyAll(
                                      //           ContinuousRectangleBorder()),
                                      //     ),
                                      //     onPressed: openAddQuizModal,
                                      //     label: const Text('New Quiz'),
                                      //     icon: const Icon(
                                      //         Icons.library_books_rounded),
                                      //   ),
                                      // ),

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
                                          onPressed: openAddExamModal,
                                          label: const Text('New Examination'),
                                          icon: const Icon(Icons
                                              .drive_file_rename_outline_rounded),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // QUIZ LIST
                              // Expanded(
                              //   child: ListView(
                              //     children: [
                              //       Card(
                              //         color: primary,
                              //         child: ListTile(
                              //           textColor: Colors.white,
                              //           title: const Text(
                              //             'Midterm Quiz 1',
                              //             style: TextStyle(
                              //                 fontWeight: FontWeight.bold),
                              //           ),
                              //           subtitle: const Text(
                              //               'Exam Type: Multiple Choice'),
                              //           trailing: SizedBox(
                              //             width: 350,
                              //             child: Row(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.center,
                              //               children: [
                              //                 const Text(
                              //                     'Deadline\nThu, December 12, 2024 11:59 PM'),
                              //                 const Gap(25),
                              //                 // Text('Score\n50/50')
                              //                 SizedBox(
                              //                   width: 85,
                              //                   child: TextField(
                              //                     decoration:
                              //                         const InputDecoration(
                              //                       border:
                              //                           OutlineInputBorder(),
                              //                       label: Text(
                              //                         'Score',
                              //                         style: TextStyle(
                              //                             color: Colors.white),
                              //                       ),
                              //                       floatingLabelAlignment:
                              //                           FloatingLabelAlignment
                              //                               .center,
                              //                     ),
                              //                     controller:
                              //                         TextEditingController
                              //                             .fromValue(
                              //                       const TextEditingValue(
                              //                           text: '100/100'),
                              //                     ),
                              //                     style: const TextStyle(
                              //                         color: Colors.white),
                              //                     readOnly: true,
                              //                   ),
                              //                 )
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              const Text(
                                'Examinations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              StreamBuilder(
                                stream: _firestoreService
                                    .getClassDataStream(widget.classCode),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final classData = snapshot.data!.data();

                                  final List<dynamic> examList =
                                      classData['exams'];

                                  return Expanded(
                                    child: examList.isEmpty
                                        ? const Column(
                                            children: [Text('No exams yet.')],
                                          )
                                        : ListView.builder(
                                            itemCount: examList.length,
                                            itemBuilder: (context, examIndex) {
                                              final exam = examList[examIndex];

                                              return Card(
                                                child: ListTile(
                                                  // textColor: Colors.white,
                                                  title: Text(
                                                    '${exam['exam']} ${exam['examType']} Examination',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  subtitle: Text(
                                                      'Exam Type: ${exam['examType'] == 'Written' ? 'Multiple Choice' : 'Coding Problem'}'),
                                                  trailing: SizedBox(
                                                    width: 450,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          'Open From: ${DateFormat.yMMMEd().add_jm().format(exam['openTime'].toDate())}\nUntil: ${DateFormat.yMMMEd().add_jm().format(exam['closeTime'].toDate())}',
                                                          textAlign:
                                                              TextAlign.end,
                                                        ),
                                                        const Gap(25),
                                                        SizedBox(
                                                          width: 100,
                                                          child: TextField(
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              label: Text(
                                                                'Max Score',
                                                              ),
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                            ),
                                                            controller:
                                                                TextEditingController
                                                                    .fromValue(
                                                              TextEditingValue(
                                                                  text: exam[
                                                                          'maxScore']
                                                                      .toString()),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            readOnly: true,
                                                          ),
                                                        )
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
