import 'dart:typed_data';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/instructor/instructor_activity.dart';
import 'package:codeodysseyph/screens/instructor/instructor_add_exam.dart';
import 'package:codeodysseyph/services/alert_service.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:disclosure/disclosure.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // TAB ESSENTIALS
  late TabController tabController;

  // SERVICES
  final _firestoreService = CloudFirestoreService();
  final _storageService = FirebaseStorageService();
  final _alertService = AlertService();

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

  // CLASS SETTINGS
  TextEditingController changeViewController = TextEditingController();
  TextEditingController copyPasteController = TextEditingController();

  void openClassSettings(String classCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Class Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: FutureBuilder(
            future: _firestoreService.getCourseClassDataFuture(
                'classes', classCode),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final classData = snapshot.data!.data();

              final changeView = classData!['violations']['changeView'];
              final copyPaste = classData['violations']['copyPaste'];

              changeViewController.text = changeView.toString();
              copyPasteController.text = copyPaste.toString();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Change View Violation'),
                      suffix: Text('points'),
                    ),
                    controller: changeViewController,
                  ),
                  const Gap(10),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Copy Paste Violation'),
                      suffix: Text('points'),
                    ),
                    controller: copyPasteController,
                  ),
                  const Gap(25),
                  TextButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(primary),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () {
                      if (changeViewController.text == changeView.toString() &&
                          copyPasteController.text == copyPaste.toString()) {
                        Navigator.of(context).pop();
                      } else {
                        saveViolations(classCode);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> saveViolations(String classCode) async {
    await _firestoreService
        .saveViolations(
      classCode: classCode,
      changeView: double.parse(changeViewController.text),
      copyPaste: double.parse(copyPasteController.text),
    )
        .then((_) {
      // POP MODAL
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      _alertService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        'Violation changes are saved successfully.',
      );
    });
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
  int? lessonIndexToBindActivity;
  DateTime? activityOpen;
  DateTime? activityClose;
  final maxScoreController = TextEditingController();
  final instructionsController = TextEditingController();
  List<Map<String, dynamic>> activityAttachments = [];

  // ADD ACTIVITY FORM KEYS
  final chooseLessonFormKey = GlobalKey<FormState>();
  final maxScoreFormKey = GlobalKey<FormState>();

  // MULTIPLE CHOICE ESSENTIALS
  final questionController = TextEditingController();
  final choiceControllers =
      List.generate(4, (index) => TextEditingController());
  final correctAnswerController = TextEditingController();
  List<Map<String, dynamic>> examQuestions = [];
  int? duplicateChoiceIndex;

  // CODING PROBLEM CONTROLLERS
  // List<Map<String, dynamic>> codingProblems = [];
  final problemStatementController = TextEditingController();
  final constraintsController = TextEditingController();
  List<Map<String, dynamic>> examExamples = [];
  List<Map<String, dynamic>> examTestCases = [];
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
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            Future<void> setDeadline({required bool isOpen}) async {
              final now = DateTime.now();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: activityClose ?? now,
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
                    isOpen
                        ? activityOpen = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          )
                        : activityClose = DateTime(
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

            void pickFile() async {
              Uint8List? attachmentBytes;
              String? attachmentFileName;

              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: [
                  'doc',
                  'docx',
                  'pdf',
                  'txt',
                  'md',
                  'ppt',
                  'pptx',
                  'xls',
                  'xlsx',
                  'csv',
                  'java',
                  'c',
                  'cpp',
                  'html',
                  'css',
                  'js',
                  'sql',
                  'php',
                  'json',
                  'xml',
                  'png',
                  'jpg',
                  'jpeg',
                ],
                type: FileType.custom,
              );

              if (result != null) {
                attachmentBytes = result.files.first.bytes!;
                attachmentFileName = result.files.first.name;

                QuickAlert.show(
                  // ignore: use_build_context_synchronously
                  context: context,
                  type: QuickAlertType.loading,
                );

                final attachmentPath = await _storageService.uploadFile(
                  'classes/files/',
                  attachmentFileName,
                  attachmentBytes,
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();

                setState(() {
                  activityAttachments.add({
                    'fileName': attachmentFileName,
                    'attachment': attachmentPath,
                  });
                });
              }
            }

            void removeAttachment(int attachmentIndex) async {
              await _storageService.deleteFile(
                  [activityAttachments[attachmentIndex]['attachment']]);
              setState(() {
                activityAttachments.removeAt(attachmentIndex);
              });
            }

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Activity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: activityAttachments.isNotEmpty
                        ? () => QuickAlert.show(
                              context: context,
                              type: QuickAlertType.warning,
                              title:
                                  'Please remove attachments before closing this modal.',
                            )
                        : () => QuickAlert.show(
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
                            ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LESSON
                    numberOfLessons != 0
                        ? Row(
                            children: [
                              Expanded(
                                child: Form(
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
                                ),
                              ),
                              const Gap(10),
                              SizedBox(
                                width: 150,
                                child: Form(
                                  key: maxScoreFormKey,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('Max Score'),
                                    ),
                                    controller: maxScoreController,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
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
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const Gap(10),
                    Row(
                      children: [
                        // OPEN SCHEDULE
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
                              onPressed: () => setDeadline(isOpen: true),
                              child: Text(activityOpen != null
                                  ? DateFormat.yMMMEd()
                                      .add_jm()
                                      .format(activityOpen!)
                                  : 'Set Open Schedule'),
                            ),
                          ),
                        ),
                        const Gap(10),

                        // CLOSE SCHEDULE
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
                              onPressed: () => setDeadline(isOpen: false),
                              child: Text(activityClose != null
                                  ? DateFormat.yMMMEd()
                                      .add_jm()
                                      .format(activityClose!)
                                  : 'Set Close Schedule'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    const Divider(),
                    const Gap(10),

                    const Text(
                      'Activity Instructions:',
                      style: TextStyle(fontSize: 20),
                    ),
                    const Gap(5),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Type instructions here...',
                      ),
                      minLines: 8,
                      maxLines: 8,
                      controller: instructionsController,
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attachments:',
                          style: TextStyle(fontSize: 20),
                        ),
                        TextButton.icon(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: pickFile,
                          label: const Text('Add'),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: activityAttachments.length,
                        itemBuilder: (context, attachmentIndex) {
                          final Map<String, dynamic> attachment =
                              activityAttachments[attachmentIndex];
                          return Card(
                            child: ListTile(
                              title: Text(attachment['fileName']),
                              trailing: IconButton(
                                onPressed: () => QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.warning,
                                  title: 'Remove attachment?',
                                  confirmBtnText: 'Yes',
                                  onConfirmBtnTap: () {
                                    Navigator.of(context).pop();
                                    removeAttachment(attachmentIndex);
                                  },
                                  cancelBtnText: 'No',
                                  showCancelBtn: true,
                                ),
                                icon: const Icon(Icons.delete_rounded),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.green[800]),
                      foregroundColor:
                          const WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: addActivity,
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Future<void> addActivity() async {
    if (!chooseLessonFormKey.currentState!.validate()) {
      return;
    }

    if (!maxScoreFormKey.currentState!.validate()) {
      return;
    }

    if (activityOpen == null || activityClose == null) {
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title:
            'Please set ${activityOpen == null ? 'Open Schedule' : 'Close Schedule'} for the Activity!',
      );
    }

    final newActivity = {
      'maxScore': int.parse(maxScoreController.text),
      'openSchedule': activityOpen,
      'closeSchedule': activityClose,
      'instructions': instructionsController.text,
      'attachments': activityAttachments,
    };

    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
      );

      await _firestoreService.addActivityToLesson(
        context: context,
        instructorId: widget.instructorId,
        classCode: widget.classCode,
        lessonIndex: lessonIndexToBindActivity!,
        newActivity: newActivity,
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success!",
        text: "Activity added successfully.",
      );
    } catch (error) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error: $error",
        text: "Failed to add activity. Please try again.",
      );
    }

    // await _firestoreService
    //     .addActivityToLesson(
    //   context: context,
    //   instructorId: widget.instructorId,
    //   classCode: widget.classCode,
    //   lessonIndex: lessonIndexToBindActivity!,
    //   newActivity: newActivity,
    // )
    //     .then((_) {
    //   // ignore: use_build_context_synchronously
    //   Navigator.of(context).pop();

    //   // DISPLAY SUCCESS MESSAGE
    //   QuickAlert.show(
    //     // ignore: use_build_context_synchronously
    //     context: context,
    //     type: QuickAlertType.success,
    //     title:
    //         'Successfully added an activity under Lesson ${lessonIndexToBindActivity! + 1}',
    //     onConfirmBtnTap: () {
    //       // POP SUCCESS
    //       Navigator.of(context).pop();
    //       // POP ADD ACTIVITY MODAL
    //       Navigator.of(context).pop();
    //     },
    //   );
    // });
  }

  int? currentlyOpenLesson;

  Future<void> deleteActivity(int activityIndex) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title:
          'Confirm Delete Lesson ${currentlyOpenLesson! + 1} - Activity ${activityIndex + 1}?',
      text: 'This will also delete all student scores for the activity.',
      confirmBtnText: 'Delete',
      onConfirmBtnTap: () async {
        // DISMISS CONFIRMATION
        Navigator.of(context).pop();

        // SHOW LOADING
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
        );

        await _firestoreService.deleteActivityFromLesson(
          context: context,
          classCode: widget.classCode,
          lessonIndex: currentlyOpenLesson!,
          activityIndex: activityIndex,
        );
      },
      showCancelBtn: true,
    );
  }

  void clearActivityFields() {
    setState(() {
      lessonIndexToBindActivity = null;
      activityOpen = null;
      activityClose = null;
      maxScoreController.clear();
      instructionsController.clear();
      activityAttachments = [];
    });
  }

  void openEditActivityDetailsModal(
    int lessonIndex,
    int activityIndex,
    Map<String, dynamic> activity,
  ) {
    final activityMaxScoreController = TextEditingController();
    activityMaxScoreController.text = activity['maxScore'].toString();

    DateTime activityOpenSchedule = activity['openSchedule'].toDate();
    DateTime activityCloseSchedule = activity['closeSchedule'].toDate();

    final Map<String, dynamic> submissions = activity['submissions'];
    final List<dynamic> studentIdsSubmission = submissions.keys.toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lesson ${currentlyOpenLesson! + 1} - Activity ${activityIndex + 1}',
            ),
            IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 750,
          child: ListView(
            children: [
              const Text(
                'Edit Details',
                style: TextStyle(fontSize: 16),
              ),
              const Gap(10),
              StatefulBuilder(
                builder: (BuildContext context, setState) {
                  Future<void> setDate({required bool isOpen}) async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          isOpen ? activityOpenSchedule : activityCloseSchedule,
                      firstDate: activityOpenSchedule,
                      lastDate: DateTime(
                        isOpen
                            ? activityOpenSchedule.year + 1
                            : activityCloseSchedule.year + 1,
                        isOpen
                            ? activityOpenSchedule.month - 6
                            : activityCloseSchedule.month - 6,
                        isOpen
                            ? activityOpenSchedule.day
                            : activityCloseSchedule.day,
                      ),
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
                              ? activityOpenSchedule = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                )
                              : activityCloseSchedule = DateTime(
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

                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Max Score'),
                          ),
                          controller: activityMaxScoreController,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(primary),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: () => setDate(isOpen: true),
                            child: Text(
                                'Open Schedule:\n${DateFormat.yMMMEd().add_jm().format(activityOpenSchedule)}'),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.red[800]),
                              foregroundColor:
                                  const WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: () => setDate(isOpen: false),
                            child: Text(
                                'Close Schedule:\n${DateFormat.yMMMEd().add_jm().format(activityCloseSchedule)}'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Gap(10),
              Center(
                child: TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(primary),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () {
                    if (activityMaxScoreController.text ==
                            activity['maxScore'].toString() &&
                        activityOpenSchedule ==
                            activity['openSchedule'].toDate() &&
                        activityCloseSchedule ==
                            activity['closeSchedule'].toDate()) {
                      Navigator.of(context).pop();
                    } else {
                      activity['maxScore'] =
                          int.parse(activityMaxScoreController.text);
                      activity['openSchedule'] = activityOpenSchedule;
                      activity['closeSchedule'] = activityCloseSchedule;
                      saveActivityEdits(activityIndex, activity);
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
              const Gap(25),
              const Text(
                'Student Submissions:',
                style: TextStyle(fontSize: 16),
              ),
              FutureBuilder(
                future: getSortedStudents(
                    studentIdsSubmission: studentIdsSubmission),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                      'No submissions as of now...',
                      style: TextStyle(fontSize: 18),
                    ));
                  }

                  final List students = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];

                      return Card(
                        child: ListTile(
                          title: Text(
                              '${student['lastName']}, ${student['firstName']}'),
                          onTap: () => openCheckActivityModal(
                              classCode: widget.classCode,
                              lessonIndex: lessonIndex,
                              activityIndex: activityIndex,
                              studentId: student['studentId'],
                              studentName:
                                  '${student['firstName']} ${student['lastName']}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveActivityEdits(
    int activityIndex,
    dynamic activity,
  ) async {
    QuickAlert.show(context: context, type: QuickAlertType.loading);

    await _firestoreService
        .editActivityDetails(
      classCode: widget.classCode,
      lessonIndex: currentlyOpenLesson!,
      activityIndex: activityIndex,
      activity: activity,
    )
        .then((_) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      _alertService.showBanner(context,
          'Successfully edited Lesson ${currentlyOpenLesson! + 1} - Activity ${activityIndex + 1}');
    });
  }

  // CHECK ACTIVITY ESSENTIALS
  final submissionScoreController = TextEditingController();
  final submissionFormKey = TextEditingController();

  Future<void> downloadFile(String learningMaterialPath) async {
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

  // CHECK ACTIVITY
  void openCheckActivityModal({
    required String classCode,
    required int lessonIndex,
    required int activityIndex,
    required String studentId,
    required String studentName,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'Lesson ${lessonIndex + 1} - Activity ${activityIndex + 1} Submission'),
            IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 800,
          child: FutureBuilder(
            future: _firestoreService.getCourseClassDataFuture(
                'classes', classCode),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
              }

              final classData = snapshot.data!.data();

              final dynamic lessons = classData!['lessons'] ?? [];
              final Map<String, dynamic> lesson = lessons[lessonIndex];
              final List<dynamic> activities = lesson['activities'] ?? [];
              final Map<String, dynamic> activity = activities[activityIndex];
              final viewActivityAttachments = activity['attachments'] ?? [];
              final Map<String, dynamic> submissions = activity['submissions'];
              final Map<String, dynamic> studentSubmission =
                  submissions[studentId];

              if (studentSubmission.containsKey('score')) {
                submissionScoreController.text =
                    studentSubmission['score'].toString();
              }

              final dynamic studentAttachments =
                  studentSubmission['attachments'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: TextField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                label: const Text('Score'),
                                suffix: Text(
                                    '/${activity['maxScore'].toString()} points'),
                              ),
                              controller: submissionScoreController,
                            ),
                          ),
                          const Gap(10),
                          TextButton(
                            onPressed: () async {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.loading,
                              );
                              await _firestoreService.scoreActivity(
                                activityIndex: activityIndex,
                                classCode: widget.classCode,
                                lessonIndex: lessonIndex,
                                score: double.parse(
                                    submissionScoreController.text),
                                studentId: studentId,
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save'),
                          )
                        ],
                      ),
                    ],
                  ),
                  // INSTRUCTIONS + POINTS
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${activity['instructions']} ${viewActivityAttachments.isEmpty ? '' : 'Refer to the ${!(viewActivityAttachments.length > 1) ? 'attachment' : 'attachments'} below:'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  viewActivityAttachments.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewActivityAttachments.length,
                          itemBuilder: (context, index) {
                            final activityAttachment =
                                viewActivityAttachments[index];
                            return Card(
                              child: ListTile(
                                title: Text(activityAttachment['fileName']),
                                trailing: IconButton(
                                  onPressed: () => downloadFile(
                                      activityAttachment['attachment']),
                                  icon: Icon(
                                    Icons.download_rounded,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  const Gap(10),
                  const Text(
                    'Student\'s Work',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: studentAttachments.length,
                    itemBuilder: (BuildContext context, int index) {
                      final attachment = studentAttachments[index];
                      return Card(
                        child: ListTile(
                          title: Text(attachment['fileName']),
                          trailing: IconButton(
                            onPressed: () =>
                                downloadFile(attachment['attachment']),
                            icon: Icon(
                              Icons.download_rounded,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
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
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();
  final questionFormKey = GlobalKey<FormState>();
  final problemStatementFormKey = GlobalKey<FormState>();
  final constraintsFormKey = GlobalKey<FormState>();
  final inputOutputFormKey = GlobalKey<FormState>();

  void goToAddExamScreen(String instructorId, String classCode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorAddExamScreen(
          instructorId: instructorId,
          classCode: classCode,
        ),
      ),
    );
  }

  Future<void> addExamToClass() async {
    // VALIDATE SCORE
    if (!maxScoreFormKey.currentState!.validate()) {
      return;
    }

    // VALIDATE OPEN AND CLOSE TIME
    if (openTime == null || closeTime == null) {
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text:
            'Please set the ${openTime == null ? 'Open Schedule' : 'Close Schedule'} of the exam.',
      );
    }

    // VALIDATE DURATION
    if (hoursController.text.isEmpty && minutesController.text.isEmpty) {
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please set the duration of the exam.',
      );
    }

    dynamic examContent;

    if (examType == 'Written') {
      if (examQuestions.isEmpty) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please add at least one question.',
        );
      }
      examContent = examQuestions;
    } else {
      if (examExamples.isEmpty) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please add at least one example.',
        );
      }
      if (examTestCases.isEmpty) {
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
        'examples': examExamples,
        'testCases': examTestCases,
      };
    }

    final newExam = {
      'exam': exam,
      'examType': examType,
      'openSchedule': openTime,
      'closeSchedule': closeTime,
      'duration': {
        'hours':
            hoursController.text.isEmpty ? 0 : int.parse(hoursController.text),
        'minutes': minutesController.text.isEmpty
            ? 0
            : int.parse(minutesController.text),
      },
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

  void clearExamFields() {
    setState(() {
      exam = 'Midterm';
      examType = 'Written';
      openTime = null;
      closeTime = null;
      maxScoreController.clear();

      clearMultipleChoiceFields();
      examQuestions = [];

      clearCodingProblemFields();
      examExamples = [];
      examTestCases = [];
      // codingProblems = [];
    });
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

  void showEditExamModal(int examIndex, Map<String, dynamic> exam) {
    final maxScore = TextEditingController();
    final durationHours = TextEditingController();
    final durationMinutes = TextEditingController();

    maxScore.text = exam['maxScore'].toString();
    durationHours.text = exam['duration']['hours'].toString();
    durationMinutes.text = exam['duration']['minutes'].toString();

    DateTime examOpen = exam['openSchedule'].toDate();
    DateTime examClose = exam['closeSchedule'].toDate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Edit ${exam['exam']} ${exam['examType']} Exam Details'),
            IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 750,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // MAX SCORE
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Max Score'),
                      ),
                      controller: maxScore,
                    ),
                  ),
                  const Gap(10),

                  // HOURS
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Duration (Hours)'),
                      ),
                      controller: durationHours,
                    ),
                  ),
                  const Gap(10),

                  // MINUTES
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Duration(Minutes)'),
                      ),
                      controller: durationMinutes,
                    ),
                  ),
                ],
              ),
              const Gap(10),

              // OPEN AND CLOSE
              StatefulBuilder(
                builder: (context, setState) {
                  Future<void> setDate({required bool isOpen}) async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: isOpen ? examOpen : examClose,
                      firstDate: examOpen,
                      lastDate: DateTime(
                        isOpen ? examOpen.year + 1 : examClose.year + 1,
                        isOpen ? examOpen.month - 6 : examClose.month - 6,
                        isOpen ? examOpen.day : examClose.day,
                      ),
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
                              ? examOpen = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                )
                              : examClose = DateTime(
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

                  return Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(primary),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: () => setDate(isOpen: true),
                            child: Text(
                                'Open Schedule:\n${DateFormat.yMMMEd().add_jm().format(examOpen)}'),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.red[800]),
                              foregroundColor:
                                  const WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: () => setDate(isOpen: false),
                            child: Text(
                                'Close Schedule:\n${DateFormat.yMMMEd().add_jm().format(examClose)}'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Gap(25),

              // SAVE CHANGES
              TextButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(primary),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                onPressed: () {
                  if (maxScore.text == exam['maxScore'].toString() &&
                      durationHours.text ==
                          exam['duration']['hours'].toString() &&
                      durationMinutes.text ==
                          exam['duration']['minutes'].toString() &&
                      examOpen == exam['openSchedule'].toDate() &&
                      examClose == exam['closeSchedule'].toDate()) {
                    Navigator.of(context).pop();
                  } else {
                    exam['maxScore'] = maxScore.text != ''
                        ? int.parse(maxScore.text)
                        : exam['maxScore'];
                    exam['duration']['hours'] = durationHours.text != ''
                        ? int.parse(durationHours.text)
                        : exam['duration']['hours'];
                    exam['duration']['minutes'] = durationMinutes.text != ''
                        ? int.parse(durationMinutes.text)
                        : exam['duration']['minutes'];
                    exam['openSchedule'] = examOpen;
                    exam['closeSchedule'] = examClose;
                    saveExamEdits(examIndex, exam);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveExamEdits(int examIndex, dynamic exam) async {
    QuickAlert.show(context: context, type: QuickAlertType.loading);

    await _firestoreService
        .editExamDetails(
      classCode: widget.classCode,
      examIndex: examIndex,
      exam: exam,
    )
        .then((_) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      _alertService.showBanner(context,
          '${exam['exam']} ${exam['examType']} Exam Details Successfully Edited');
    });
  }

  void deleteExam(dynamic exam, int examIndex) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Confirm Delete ${exam['exam']} ${exam['examType']} Exam?',
      text: 'This will also delete all student scores.',
      confirmBtnText: 'Delete',
      onConfirmBtnTap: () async {
        // DISMISS CONFIRMATION
        Navigator.of(context).pop();

        // SHOW LOADING
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
        );

        await _firestoreService.deleteExamFromClass(
          context: context,
          classCode: widget.classCode,
          exam: exam,
          examIndex: examIndex,
        );
      },
      showCancelBtn: true,
    );
  }

  // STUDENT PERFORMANCE ESSENTIALS
  late Future<List<Map<String, dynamic>>> studentsList;

  void loadStudents() {
    setState(() {
      studentsList = getSortedStudents();
    });
  }

  Future<List<Map<String, dynamic>>> getSortedStudents(
      {List<dynamic>? studentIdsSubmission}) async {
    final classData = await _firestoreService.getCourseClassDataFuture(
        'classes', widget.classCode);

    if (!classData.exists) return [];

    List<dynamic> studentIds =
        studentIdsSubmission ?? (classData.data()?['students'] ?? []);

    if (studentIds.isEmpty) return [];

    List<Map<String, dynamic>> students = [];

    for (String studentId in studentIds) {
      final userDoc = await _firestoreService.getUserData(userId: studentId);

      if (userDoc.exists) {
        final userData = userDoc.data();

        students.add({
          'studentId': userDoc.id,
          'firstName': userData!['firstName'],
          'lastName': userData['lastName'],
        });
      }
    }

    students.sort((a, b) {
      return a['lastName']
          .toString()
          .toLowerCase()
          .compareTo(b['lastName'].toString().toLowerCase());
    });

    return students;
  }

  void openConfirmRemoveStudent(String studentId, String studentName) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Remove $studentName from class?',
      onConfirmBtnTap: () => removeStudent(studentId),
    );
  }

  Future<void> removeStudent(String studentId) async {
    QuickAlert.show(context: context, type: QuickAlertType.loading);

    await _firestoreService
        .removeStudent(classCode: widget.classCode, studentId: studentId)
        .then((_) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      loadStudents();
    });
  }

  late TabController studentPerformanceTabController;

  void openIndividualPerformance(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 1080,
          child: FutureBuilder(
            future: _firestoreService.getCourseClassDataFuture(
                'classes', widget.classCode),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                    child:
                        Text('Error fetching student data: ${snapshot.error}'));
              }

              final classData = snapshot.data!.data();

              final List lessons = classData?['lessons'] ?? [];
              bool hasActivities = lessons
                  .any((lesson) => (lesson['activities'] ?? []).isNotEmpty);

              final List exams = classData?['exams'] ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${student['lastName']}, ${student['firstName']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  TabBar(
                    controller: studentPerformanceTabController,
                    tabs: const [
                      Tab(text: 'Course Work'),
                      Tab(text: 'Assessments'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: studentPerformanceTabController,
                      children: [
                        // COURSE WORK
                        !hasActivities
                            ? const Center(
                                child: Text(
                                  'No activities assigned yet.',
                                  style: TextStyle(fontSize: 20),
                                ),
                              )
                            : ListView.builder(
                                itemCount: lessons.length,
                                itemBuilder: (context, lessonIndex) {
                                  final lesson = lessons[lessonIndex];

                                  final List activities =
                                      lesson?['activities'] ?? [];

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: activities.length,
                                    itemBuilder: (context, activityIndex) {
                                      final activity =
                                          activities[activityIndex];

                                      String? score;

                                      final Map<String, dynamic> submissions =
                                          activity['submissions'] ?? {};
                                      if (submissions
                                          .containsKey(student['studentId'])) {
                                        score =
                                            'Score: ${activity['submissions'][student['studentId']]['score']}/${activity['maxScore']}';
                                        if (!submissions[student['studentId']]
                                            .containsKey('score')) {
                                          score =
                                              'Submitted. Waiting for evaluation.';
                                        }
                                      }

                                      return Card(
                                        child: ListTile(
                                          title: Text(
                                              'Lesson ${lessonIndex + 1} - Activity ${activityIndex + 1}'),
                                          trailing: Text(
                                            score ?? 'Not yet submitted.',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                        // ASSESSMENTS
                        exams.isEmpty
                            ? const Center(
                                child: Text(
                                  'No exams assigned yet.',
                                  style: TextStyle(fontSize: 20),
                                ),
                              )
                            : ListView.builder(
                                itemCount: exams.length,
                                itemBuilder: (context, examIndex) {
                                  final exam = exams[examIndex];

                                  String? score;

                                  final Map<String, dynamic> submissions =
                                      exam['submissions'] ?? {};

                                  if (submissions
                                      .containsKey(student['studentId'])) {
                                    score = exam['submissions']
                                            [student['studentId']]['score']
                                        .toString();
                                  }

                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                          '${exam['exam']} ${exam['examType']} Exam'),
                                      trailing: Text(
                                        score == null
                                            ? 'Not yet taken.'
                                            : "Score: $score/${exam['maxScore']}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchStudentScoresWithDynamicHeaders(
      List<Map<String, dynamic>> students) async {
    try {
      final classSnapshot = await _firestoreService.getCourseClassDataFuture(
          'classes', widget.classCode);

      if (!classSnapshot.exists) {
        throw Exception('Class with code ${widget.classCode} does not exist.');
      }

      Map<String, dynamic> classData =
          classSnapshot.data() as Map<String, dynamic>;

      List lessons = classData['lessons'] ?? [];
      List exams = classData['exams'] ?? [];

      // HEADERS
      List<String> activityHeaders = [];
      List<String> examHeaders = [];
      Map<String, String> activityHeaderMapping = {};
      Map<String, int> examHeaderMapping = {};

      // GENERATE ACTIVITY HEADERS
      for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
        List activities = lessons[lessonIndex]['activities'] ?? [];

        for (int activityIndex = 0;
            activityIndex < activities.length;
            activityIndex++) {
          String header = 'L${lessonIndex + 1}A${activityIndex + 1}';
          activityHeaders.add(header);
          activityHeaderMapping[header] = '$lessonIndex-$activityIndex';
        }
      }

      // GENERATE EXAM HEADERS
      for (int examIndex = 0; examIndex < exams.length; examIndex++) {
        String header = 'E${examIndex + 1}';
        examHeaders.add(header);
        examHeaderMapping[header] = examIndex;
      }

      // PREPARE SCORES
      List<Map<String, dynamic>> studentScores = students.map((student) {
        String studentId = student['studentId'];
        String firstName = student['firstName'];
        String lastName = student['lastName'];

        // INITIALIZE ROW DATA FOR STUDENTS
        Map<String, dynamic> scores = {
          'studentId': studentId,
          'firstName': firstName,
          'lastName': lastName,
        };

        // FETCH ACTIVITY SCORES
        activityHeaderMapping.forEach((header, mapping) {
          List<String> indices = mapping.split('-');
          int lessonIndex = int.parse(indices[0]);
          int activityIndex = int.parse(indices[1]);
          var activity = lessons[lessonIndex]['activities'][activityIndex];
          var submissions = activity['submissions'] ?? {};
          scores[header] =
              submissions[studentId]?['score']?.toString() ?? 'N/A';
        });

        // FETCH EXAM SCORES
        examHeaderMapping.forEach((header, index) {
          var exam = exams[index];
          var submissions = exam['submissions'] ?? {};
          scores[header] =
              submissions[studentId]?['score']?.toString() ?? 'N/A';
        });

        return scores;
      }).toList();

      return {
        'headers': ['lastName', 'firstName'] + activityHeaders + examHeaders,
        'data': studentScores,
      };
    } catch (e) {
      print('Error fetching student scores: $e');
      rethrow;
    }
  }

  Future<Excel> createDynamicExcel(
    List<String> headers,
    List<Map<String, dynamic>> studentScores,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // WRITE HEADERS
    for (int i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i].toUpperCase());
    }

    // WRITE SCORES FOR EACH STUDENT
    for (int rowIndex = 0; rowIndex < studentScores.length; rowIndex++) {
      Map<String, dynamic> student = studentScores[rowIndex];

      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        String header = headers[colIndex];
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: colIndex, rowIndex: rowIndex + 1))
                .value =
            TextCellValue(
                student[header] != null ? student[header].toString() : 'N/A');
      }
    }

    return excel;
  }

  void downloadExcelFile({
    Excel? excel,
    String? fileName,
  }) {
    final List<int>? bytes = excel!.encode();
    if (bytes == null) return;

    final Uint8List uint8list = Uint8List.fromList(bytes);
    final blob = html.Blob([uint8list]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  void exportDynamicScoresToExcel(List<Map<String, dynamic>> students) async {
    loadStudents();
    try {
      // FETCH STUDENT SCORES AND HEADERS
      Map<String, dynamic> scoresData =
          await fetchStudentScoresWithDynamicHeaders(students);

      List<String> headers = scoresData['headers'];
      List<Map<String, dynamic>> studentScores = scoresData['data'];

      // CREATE EXCEL FILE
      Excel excel = await createDynamicExcel(headers, studentScores);

      String className = widget.courseCodeYearBlock.replaceAll('-', '');
      className = className.replaceAll(' ', '');

      // DOWNLOAD EXCEL FILE
      downloadExcelFile(
        excel: excel,
        fileName: 'StudentScores_$className.xlsx',
      );
    } catch (e) {
      print('Error exporting scores: $e');
    }
  }

  // ANNOUNCEMENT ESSENTIALS
  final announcementTitleController = TextEditingController();
  final announcementMessageController = TextEditingController();
  final announcementFormKey = GlobalKey<FormState>();
  final announcementsScrollController = ScrollController();

  void openAddAnnouncementModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add a New Announcement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                // CLOSE THE ADD NEW ANNOUNCEMENT MODAL
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
          child: Form(
            key: announcementFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TITLE
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Title (Optional)'),
                  ),
                  controller: announcementTitleController,
                ),
                const Gap(10),

                // MESSAGE
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Message'),
                  ),
                  minLines: 5,
                  maxLines: 10,
                  controller: announcementMessageController,
                  validator: (value) {
                    if (value!.isEmpty || value.trim() == '') {
                      return 'Required. Please type a message.';
                    }

                    return null;
                  },
                ),
                const Gap(25),

                // SEND BUTTON
                SizedBox(
                  width: 150,
                  height: 35,
                  child: TextButton.icon(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(primary),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: sendAnnouncement,
                    label: const Text('Send'),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendAnnouncement() async {
    if (!announcementFormKey.currentState!.validate()) {
      return;
    }

    QuickAlert.show(context: context, type: QuickAlertType.loading);

    await _firestoreService
        .getUserData(userId: widget.instructorId)
        .then((fetchedData) async {
      final instructorData = fetchedData.data();

      await _firestoreService
          .addAnnouncement(
              classCode: widget.classCode,
              title: announcementTitleController.text,
              message: announcementMessageController.text,
              instructorName:
                  '${instructorData!['firstName']} ${instructorData['lastName']}')
          .then((_) {
        _scrollToBottom();
      });
    });

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  Future<void> deleteAnnouncement(
      String classCode, String announcementId) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Are you sure you want to delete this announcement?',
      onConfirmBtnTap: () async {
        Navigator.of(context).pop();

        QuickAlert.show(context: context, type: QuickAlertType.loading);

        await _firestoreService.deleteAnnouncement(
          context: context,
          classCode: classCode,
          announcementId: announcementId,
        );
      },
      showCancelBtn: true,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (announcementsScrollController.hasClients) {
        announcementsScrollController.animateTo(
          announcementsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    // 4 tabs - Course Work, Assessments, Student Performance, Announcements

    studentPerformanceTabController = TabController(length: 2, vsync: this);
    // 2 tabs - Course Work, Assessments

    tabController.addListener(() {
      if (tabController.index == tabController.previousIndex) return;

      if (tabController.index == 3) {
        _scrollToBottom();
      }
    });

    loadStudents();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Column(
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
                            const Gap(25),
                            IconButton(
                              onPressed: () =>
                                  openClassSettings(widget.classCode),
                              icon: const Icon(Icons.settings_rounded),
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
                                    'Lessons',
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
                                                onToggle: (value) {
                                                  if (value == false) {
                                                    currentlyOpenLesson =
                                                        lessonIndex;
                                                  } else {
                                                    currentlyOpenLesson = null;
                                                  }
                                                },
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
                                                                          activityIndex) {
                                                                    final DateTime
                                                                        openSchedule =
                                                                        activities[activityIndex]['openSchedule']
                                                                            .toDate();

                                                                    final DateTime
                                                                        closeSchedule =
                                                                        activities[activityIndex]['closeSchedule']
                                                                            .toDate();

                                                                    final activity =
                                                                        activities[
                                                                            activityIndex];

                                                                    return Card(
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            'Activity ${activityIndex + 1} (${activity['maxScore']} points)'),
                                                                        trailing:
                                                                            SizedBox(
                                                                          width:
                                                                              450,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                'Open From: ${DateFormat.yMMMEd().add_jm().format(openSchedule)}\nUntil: ${DateFormat.yMMMEd().add_jm().format(closeSchedule)}',
                                                                                textAlign: TextAlign.end,
                                                                              ),
                                                                              const Gap(25),
                                                                              IconButton(
                                                                                onPressed: () => deleteActivity(activityIndex),
                                                                                icon: const Icon(Icons.delete_rounded),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        onTap: () =>
                                                                            openEditActivityDetailsModal(
                                                                          lessonIndex,
                                                                          activityIndex,
                                                                          activity,
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
                              // ADD BUTTON
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

                                      // ADD EXAM
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
                                          onPressed: () => goToAddExamScreen(
                                            widget.instructorId,
                                            widget.classCode,
                                          ),
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
                              // EXAM LIST
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
                                      classData['exams'] ?? [];

                                  return Expanded(
                                    child: examList.isEmpty
                                        ? const Column(
                                            children: [
                                              Center(
                                                child: Text(
                                                  'No exams yet.',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ),
                                            ],
                                          )
                                        : ListView.builder(
                                            itemCount: examList.length,
                                            itemBuilder: (context, examIndex) {
                                              final exam = examList[examIndex];

                                              return Card(
                                                child: ListTile(
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
                                                          'Open From: ${DateFormat.yMMMEd().add_jm().format(exam['openSchedule'].toDate())}\nUntil: ${DateFormat.yMMMEd().add_jm().format(exam['closeSchedule'].toDate())}',
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
                                                        ),
                                                        const Gap(25),
                                                        IconButton(
                                                          onPressed: () =>
                                                              deleteExam(exam,
                                                                  examIndex),
                                                          icon: const Icon(
                                                            Icons
                                                                .delete_rounded,
                                                            color: Colors.red,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () =>
                                                      showEditExamModal(
                                                    examIndex,
                                                    exam,
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
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: FutureBuilder(
                            future: getSortedStudents(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text(
                                  'No students found.',
                                  style: TextStyle(fontSize: 18),
                                ));
                              }

                              final students = snapshot.data!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Students',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.green[800]),
                                              foregroundColor:
                                                  const WidgetStatePropertyAll(
                                                      Colors.white),
                                            ),
                                            onPressed: () =>
                                                exportDynamicScoresToExcel(
                                                    students),
                                            label: const Text('Export Scores'),
                                            icon: const Icon(
                                                Icons.save_alt_rounded),
                                          ),
                                          IconButton(
                                            onPressed: loadStudents,
                                            icon: const Icon(
                                                Icons.refresh_rounded),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: students.length,
                                      itemBuilder: (context, index) {
                                        final student = students[index];
                                        return Card(
                                          child: ListTile(
                                            onTap: () =>
                                                openIndividualPerformance(
                                                    student),
                                            title: Text(
                                              '${student['lastName']}, ${student['firstName']}',
                                            ),
                                            // subtitle: Text(
                                            //     'Account ID: ${student['studentId']}'),
                                            trailing: IconButton(
                                              onPressed: () =>
                                                  openConfirmRemoveStudent(
                                                      student['studentId'],
                                                      '${student['firstName']} ${student['lastName']}'),
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // ANNOUNCEMENTS
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(primary),
                                  foregroundColor:
                                      WidgetStatePropertyAll(Colors.white),
                                ),
                                onPressed: openAddAnnouncementModal,
                                label: const Text('New Announcement'),
                                icon: const Icon(Icons.add_rounded),
                              ),
                              const Gap(10),
                              StreamBuilder(
                                stream: _firestoreService.getAnnouncements(
                                    classCode: widget.classCode),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No announcements as of now...',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    );
                                  }

                                  WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => _scrollToBottom());

                                  return Expanded(
                                    child: ListView(
                                      controller: announcementsScrollController,
                                      children: snapshot.data!.docs
                                          .map<Widget>((doc) {
                                        Map<String, dynamic> data =
                                            doc.data() as Map<String, dynamic>;

                                        DateTime dateTime =
                                            data['timestamp'].toDate();

                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 5),
                                          alignment: Alignment.centerLeft,
                                          child: Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 20,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // ANNOUNCEMENT TITLE
                                                      Text(
                                                        data['title'] != ''
                                                            ? data['title']
                                                            : 'Announcement',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                      // DELETE BUTTON
                                                      IconButton(
                                                        onPressed: () =>
                                                            deleteAnnouncement(
                                                          widget.classCode,
                                                          doc.id,
                                                        ),
                                                        icon: const Icon(
                                                            Icons.delete),
                                                        color: Colors.red,
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(),
                                                  // MESSAGE
                                                  Text(
                                                    data['message'],
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const Gap(5),
                                                  // INSTRUCTOR NAME AND DATE TIME SENT
                                                  Text(
                                                    'by ${data['instructorName']}\n${DateFormat.yMMMMEEEEd().add_jm().format(dateTime)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(), // Convert to a List<Widget>
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
