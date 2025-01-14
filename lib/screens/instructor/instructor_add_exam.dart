import 'dart:typed_data';

import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class InstructorAddExamScreen extends StatefulWidget {
  const InstructorAddExamScreen({
    super.key,
    required this.instructorId,
    required this.classCode,
  });

  final String instructorId;
  final String classCode;

  @override
  State<InstructorAddExamScreen> createState() =>
      _InstructorAddExamScreenState();
}

class _InstructorAddExamScreenState extends State<InstructorAddExamScreen> {
  // SERVICES
  final _firestoreService = CloudFirestoreService();
  final _storageService = FirebaseStorageService();

  // EXAM ESSENTIALS
  final durationFormKey = GlobalKey<FormState>();

  String exam = 'Midterm';
  String examType = 'Written';
  DateTime? openTime;
  DateTime? closeTime;
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();
  int totalPoints = 0;
  final maxScoreController = TextEditingController();

  Map<String, dynamic> writtenItems = {
    'Multiple Choice': [],
    'True or False': [],
    'Identification': [],
    'Fill in the Blanks': [],
    'Short Answer': [],
    'Long Answer': [],
  };

  List<Map<String, dynamic>> labItems = [];

  // WRITTEN MODALS

  void openAddMultipleChoiceModal() async {
    showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final choiceFormKey = GlobalKey<FormState>();

        final questionController = TextEditingController();

        List<Map<String, dynamic>> itemAttachments = [];
        String? fileName;
        Uint8List? fileBytes;

        final List<TextEditingController> choiceControllers = [
          TextEditingController(),
        ];

        String? correctAnswer;

        final pointsController = TextEditingController();

        void addToMultipleChoiceItems() {
          if (!formKey.currentState!.validate()) {
            return;
          }

          setState(() {
            writtenItems['Multiple Choice']!.add({
              'question': questionController.text,
              'attachments': itemAttachments,
              'choices': choiceControllers
                  .map((controller) => controller.text)
                  .toList(),
              'answer': correctAnswer,
              'points': int.parse(pointsController.text),
            });

            totalPoints += int.parse(pointsController.text);

            maxScoreController.text = totalPoints.toString();
          });

          Navigator.of(context).pop();
        }

        return StatefulBuilder(
          builder: (context, setState) {
            void pickFile() async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: ['jpg', 'jpeg', 'png'],
                type: FileType.custom,
              );

              if (result != null) {
                fileBytes = result.files.first.bytes!;
                fileName = result.files.first.name;

                QuickAlert.show(
                  // ignore: use_build_context_synchronously
                  context: context,
                  type: QuickAlertType.loading,
                );

                final attachmentPath = await _storageService.uploadFile(
                  'classes/files/',
                  fileName!,
                  fileBytes!,
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();

                setState(() {
                  itemAttachments.add({
                    'fileName': fileName,
                    'attachment': attachmentPath,
                  });

                  fileName = null;
                  fileBytes = null;
                });
              }
            }

            void removeAttachment(int index) {
              _storageService
                  .deleteFile([itemAttachments[index]['attachment']]).then((_) {
                setState(() {
                  itemAttachments.removeAt(index);
                });
              });
            }

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Multiple Choice'),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => itemAttachments.isEmpty
                        ? Navigator.of(context).pop()
                        : QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Discard Changes?',
                            text:
                                'This will remove all exam items you have added. Are you sure you want to proceed?',
                            confirmBtnText: 'Yes',
                            onConfirmBtnTap: () {
                              _storageService.deleteFile(
                                itemAttachments
                                    .map((attachment) =>
                                        attachment['attachment'])
                                    .toList(),
                              );

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            showCancelBtn: true,
                            onCancelBtnTap: () => Navigator.of(context).pop,
                          ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // QUESTION
                        TextFormField(
                          controller: questionController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Question'),
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Please input a question';
                            }

                            return null;
                          },
                        ),
                        const Gap(10),

                        // ATTACHMENTS
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: itemAttachments.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<String>(
                              future: _storageService.storageRef
                                  .child(itemAttachments[index]['attachment'])
                                  .getDownloadURL(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const ListTile(
                                    title: Text('Loading...'),
                                  );
                                } else if (snapshot.hasError) {
                                  return const Icon(Icons.error);
                                } else if (snapshot.hasData) {
                                  return ListTile(
                                    title: Text(
                                        itemAttachments[index]['fileName']),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                        'Attachment Preview'),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.close_rounded),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                    ),
                                                  ],
                                                ),
                                                content: Image.network(
                                                    snapshot.data!),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.warning,
                                            title: 'Delete Attachment?',
                                            text:
                                                'Are you sure you want to delete this attachment?',
                                            confirmBtnText: 'Yes',
                                            onConfirmBtnTap: () {
                                              removeAttachment(index);
                                              Navigator.of(context).pop();
                                            },
                                            showCancelBtn: true,
                                            onCancelBtnTap:
                                                Navigator.of(context).pop,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Icon(Icons.error);
                                }
                              },
                            );
                          },
                        ),
                        itemAttachments.isNotEmpty
                            ? const Gap(10)
                            : const SizedBox(),

                        // ATTACH IMAGE BUTTON
                        TextButton.icon(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: pickFile,
                          label: const Text('Attach Image'),
                          icon: const Icon(Icons.image_rounded),
                        ),
                        const Gap(10),

                        // CHOICES
                        Form(
                          key: choiceFormKey,
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              ...List.generate(choiceControllers.length,
                                  (index) {
                                return Column(
                                  children: [
                                    TextFormField(
                                      controller: choiceControllers[index],
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        label: Text(
                                            'Choice ${String.fromCharCode(65 + index)}'),
                                        suffixIcon: index == 0
                                            ? null
                                            : IconButton(
                                                onPressed: () => setState(() {
                                                  choiceControllers
                                                      .removeAt(index);
                                                }),
                                                icon: const Icon(
                                                    Icons.remove_rounded),
                                              ),
                                      ),
                                      onChanged: (value) {
                                        if (!choiceFormKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                      },
                                      validator: (value) {
                                        if (value!.trim().isEmpty) {
                                          return 'Please input a choice';
                                        }
                                        if (choiceControllers
                                                .where((controller) =>
                                                    controller.text.trim() ==
                                                    value.trim())
                                                .length >
                                            1) {
                                          return 'Choices must be unique';
                                        }
                                        return null;
                                      },
                                    ),
                                    const Gap(10),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),

                        // ADD CHOICE BUTTON
                        TextButton.icon(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: () => setState(() {
                            choiceControllers.add(TextEditingController());
                          }),
                          label: const Text('Add Choice'),
                          icon: const Icon(Icons.add_rounded),
                        ),
                        const Gap(10),

                        // CORRECT ANSWER
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Correct Answer'),
                          ),
                          value: correctAnswer,
                          items: List.generate(
                            choiceControllers.length,
                            (index) => DropdownMenuItem(
                              value: String.fromCharCode(65 + index),
                              child: Text(String.fromCharCode(65 + index)),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              correctAnswer = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a correct answer';
                            }

                            return null;
                          },
                        ),
                        const Gap(10),

                        // POINTS
                        TextFormField(
                          controller: pointsController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Points'),
                          ),
                          validator: (value) {
                            if (int.tryParse(value!) == null) {
                              return 'Please input a number';
                            }

                            return null;
                          },
                        ),
                        const Gap(10),

                        // ADD ITEM BUTTON
                        Center(
                          child: ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(primary),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: addToMultipleChoiceItems,
                            child: const Text('Add to Written Exam Items'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openAddTrueOrFalseModal() async {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();

        final questionController = TextEditingController();

        List<Map<String, dynamic>> itemAttachments = [];
        String? fileName;
        Uint8List? fileBytes;

        String correctAnswer = 'True';

        final pointsController = TextEditingController();

        void addToTrueOrFalseItems() {
          if (!formKey.currentState!.validate()) {
            return;
          }

          setState(() {
            writtenItems['True or False']!.add({
              'question': questionController.text,
              'attachments': itemAttachments,
              'answer': correctAnswer,
              'points': int.parse(pointsController.text),
            });

            totalPoints += int.parse(pointsController.text);

            maxScoreController.text = totalPoints.toString();
          });

          Navigator.of(context).pop();
        }

        return StatefulBuilder(
          builder: (context, setState) {
            void pickFile() async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: ['jpg', 'jpeg', 'png'],
                type: FileType.custom,
              );

              if (result != null) {
                fileBytes = result.files.first.bytes!;
                fileName = result.files.first.name;

                QuickAlert.show(
                  // ignore: use_build_context_synchronously
                  context: context,
                  type: QuickAlertType.loading,
                );

                final attachmentPath = await _storageService.uploadFile(
                  'classes/files/',
                  fileName!,
                  fileBytes!,
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();

                setState(() {
                  itemAttachments.add({
                    'fileName': fileName,
                    'attachment': attachmentPath,
                  });

                  fileName = null;
                  fileBytes = null;
                });
              }
            }

            void removeAttachment(int index) {
              _storageService
                  .deleteFile([itemAttachments[index]['attachment']]).then((_) {
                setState(() {
                  itemAttachments.removeAt(index);
                });
              });
            }

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add True or False'),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => itemAttachments.isEmpty
                        ? Navigator.of(context).pop()
                        : QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Discard Changes?',
                            text:
                                'This will remove all exam items you have added. Are you sure you want to proceed?',
                            confirmBtnText: 'Yes',
                            onConfirmBtnTap: () {
                              _storageService.deleteFile(
                                itemAttachments
                                    .map((attachment) =>
                                        attachment['attachment'])
                                    .toList(),
                              );

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            showCancelBtn: true,
                            onCancelBtnTap: () => Navigator.of(context).pop,
                          ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // QUESTION
                      TextFormField(
                        controller: questionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Question'),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Please input a question';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ATTACHMENTS
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemAttachments.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<String>(
                            future: _storageService.storageRef
                                .child(itemAttachments[index]['attachment'])
                                .getDownloadURL(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else if (snapshot.hasData) {
                                return ListTile(
                                  title:
                                      Text(itemAttachments[index]['fileName']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                      'Attachment Preview'),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.close_rounded),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ],
                                              ),
                                              content:
                                                  Image.network(snapshot.data!),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: 'Delete Attachment?',
                                          text:
                                              'Are you sure you want to delete this attachment?',
                                          confirmBtnText: 'Yes',
                                          onConfirmBtnTap: () {
                                            removeAttachment(index);
                                            Navigator.of(context).pop();
                                          },
                                          showCancelBtn: true,
                                          onCancelBtnTap:
                                              Navigator.of(context).pop,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return const Icon(Icons.error);
                              }
                            },
                          );
                        },
                      ),
                      itemAttachments.isNotEmpty
                          ? const Gap(10)
                          : const SizedBox(),

                      // ATTACH IMAGE BUTTON
                      TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(primary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: pickFile,
                        label: const Text('Attach Image'),
                        icon: const Icon(Icons.image_rounded),
                      ),
                      const Gap(10),

                      // CORRECT ANSWER
                      DropdownButtonFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Correct Answer'),
                        ),
                        value: correctAnswer,
                        items: const [
                          DropdownMenuItem(
                            value: 'True',
                            child: Text('True'),
                          ),
                          DropdownMenuItem(
                            value: 'False',
                            child: Text('False'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            correctAnswer = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a correct answer';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // POINTS
                      TextFormField(
                        controller: pointsController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Points'),
                        ),
                        validator: (value) {
                          if (int.tryParse(value!) == null) {
                            return 'Please input a number';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ADD ITEM BUTTON
                      Center(
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: addToTrueOrFalseItems,
                          child: const Text('Add to Written Exam Items'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openAddIdentificationModal() async {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();

        final questionController = TextEditingController();

        List<Map<String, dynamic>> itemAttachments = [];
        String? fileName;
        Uint8List? fileBytes;

        final answerController = TextEditingController();

        final pointsController = TextEditingController();

        void addToIdentificationItems() {
          if (!formKey.currentState!.validate()) {
            return;
          }

          setState(() {
            writtenItems['Identification']!.add({
              'question': questionController.text,
              'attachments': itemAttachments,
              'answer': answerController.text,
              'points': int.parse(pointsController.text),
            });

            totalPoints += int.parse(pointsController.text);

            maxScoreController.text = totalPoints.toString();
          });

          Navigator.of(context).pop();
        }

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            void pickFile() async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: ['jpg', 'jpeg', 'png'],
                type: FileType.custom,
              );

              if (result != null) {
                fileBytes = result.files.first.bytes!;
                fileName = result.files.first.name;

                QuickAlert.show(
                  // ignore: use_build_context_synchronously
                  context: context,
                  type: QuickAlertType.loading,
                );

                final attachmentPath = await _storageService.uploadFile(
                  'classes/files/',
                  fileName!,
                  fileBytes!,
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();

                setState(() {
                  itemAttachments.add({
                    'fileName': fileName,
                    'attachment': attachmentPath,
                  });

                  fileName = null;
                  fileBytes = null;
                });
              }
            }

            void removeAttachment(int index) {
              _storageService
                  .deleteFile([itemAttachments[index]['attachment']]).then((_) {
                setState(() {
                  itemAttachments.removeAt(index);
                });
              });
            }

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Identification'),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => itemAttachments.isEmpty
                        ? Navigator.of(context).pop()
                        : QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Discard Changes?',
                            text:
                                'This will remove all exam items you have added. Are you sure you want to proceed?',
                            confirmBtnText: 'Yes',
                            onConfirmBtnTap: () {
                              _storageService.deleteFile(
                                itemAttachments
                                    .map((attachment) =>
                                        attachment['attachment'])
                                    .toList(),
                              );

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            showCancelBtn: true,
                            onCancelBtnTap: () => Navigator.of(context).pop,
                          ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // QUESTION
                      TextFormField(
                        controller: questionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Question'),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Please input a question';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ATTACHMENTS
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemAttachments.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<String>(
                            future: _storageService.storageRef
                                .child(itemAttachments[index]['attachment'])
                                .getDownloadURL(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else if (snapshot.hasData) {
                                return ListTile(
                                  title:
                                      Text(itemAttachments[index]['fileName']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // PREVIEW ATTACHMENT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                      'Attachment Preview'),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.close_rounded),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ],
                                              ),
                                              content:
                                                  Image.network(snapshot.data!),
                                            ),
                                          );
                                        },
                                      ),

                                      // DELETE ATTACHMENT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: 'Delete Attachment?',
                                          text:
                                              'Are you sure you want to delete this attachment?',
                                          confirmBtnText: 'Yes',
                                          onConfirmBtnTap: () =>
                                              removeAttachment(index),
                                          showCancelBtn: true,
                                          onCancelBtnTap: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return const Icon(Icons.error);
                              }
                            },
                          );
                        },
                      ),
                      itemAttachments.isNotEmpty
                          ? const Gap(10)
                          : const SizedBox(),

                      // ATTACH IMAGE BUTTON
                      TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(primary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: pickFile,
                        label: const Text('Attach Image'),
                        icon: const Icon(Icons.image_rounded),
                      ),
                      const Gap(10),

                      // ANSWER
                      TextFormField(
                        controller: answerController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Answer'),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Please input an answer';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // POINTS
                      TextFormField(
                        controller: pointsController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Points'),
                        ),
                        validator: (value) {
                          if (int.tryParse(value!) == null) {
                            return 'Please input a number';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ADD ITEM BUTTON
                      Center(
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: addToIdentificationItems,
                          child: const Text('Add to Written Exam Items'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openAddFillInTheBlanksModal() async {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final answersFormKey = GlobalKey<FormState>();

        final questionController = TextEditingController();

        List<Map<String, dynamic>> itemAttachments = [];
        String? fileName;
        Uint8List? fileBytes;

        final List<TextEditingController> answerControllers = [
          TextEditingController(),
        ];

        final pointsController = TextEditingController();

        void addToFillInTheBlanksItems() {
          if (!formKey.currentState!.validate()) {
            return;
          }

          setState(() {
            writtenItems['Fill in the Blanks']!.add({
              'question': questionController.text,
              'attachments': itemAttachments,
              'answers': answerControllers
                  .map((controller) => controller.text)
                  .toList(),
              'points': int.parse(pointsController.text),
            });

            totalPoints += int.parse(pointsController.text);

            maxScoreController.text = totalPoints.toString();
          });

          Navigator.of(context).pop();
        }

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            void pickFile() async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: ['jpg', 'jpeg', 'png'],
                type: FileType.custom,
              );

              if (result != null) {
                fileBytes = result.files.first.bytes!;
                fileName = result.files.first.name;

                QuickAlert.show(
                  // ignore: use_build_context_synchronously
                  context: context,
                  type: QuickAlertType.loading,
                );

                final attachmentPath = await _storageService.uploadFile(
                  'classes/files/',
                  fileName!,
                  fileBytes!,
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();

                setState(() {
                  itemAttachments.add({
                    'fileName': fileName,
                    'attachment': attachmentPath,
                  });

                  fileName = null;
                  fileBytes = null;
                });
              }
            }

            void removeAttachment(int index) {
              _storageService
                  .deleteFile([itemAttachments[index]['attachment']]).then((_) {
                setState(() {
                  itemAttachments.removeAt(index);
                });
              });
            }

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Fill in the Blanks'),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => itemAttachments.isEmpty
                        ? Navigator.of(context).pop()
                        : QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Discard Changes?',
                            text:
                                'This will remove all exam items you have added. Are you sure you want to proceed?',
                            confirmBtnText: 'Yes',
                            onConfirmBtnTap: () {
                              _storageService.deleteFile(
                                itemAttachments
                                    .map((attachment) =>
                                        attachment['attachment'])
                                    .toList(),
                              );

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            showCancelBtn: true,
                            onCancelBtnTap: () => Navigator.of(context).pop,
                          ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // QUESTION
                      TextFormField(
                        controller: questionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Question'),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Please input a question';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ATTACHMENTS
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemAttachments.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<String>(
                            future: _storageService.storageRef
                                .child(itemAttachments[index]['attachment'])
                                .getDownloadURL(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else if (snapshot.hasData) {
                                return ListTile(
                                  title:
                                      Text(itemAttachments[index]['fileName']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // PREVIEW ATTACHMENT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                      'Attachment Preview'),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.close_rounded),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ],
                                              ),
                                              content:
                                                  Image.network(snapshot.data!),
                                            ),
                                          );
                                        },
                                      ),
                                      // DELETE ATTACHMENT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: 'Delete Attachment?',
                                          text:
                                              'Are you sure you want to delete this attachment?',
                                          confirmBtnText: 'Yes',
                                          onConfirmBtnTap: () =>
                                              removeAttachment(index),
                                          showCancelBtn: true,
                                          onCancelBtnTap: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return const Icon(Icons.error);
                              }
                            },
                          );
                        },
                      ),
                      itemAttachments.isNotEmpty
                          ? const Gap(10)
                          : const SizedBox(),

                      // ATTACH IMAGE BUTTON
                      TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(primary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: pickFile,
                        label: const Text('Attach Image'),
                        icon: const Icon(Icons.image_rounded),
                      ),
                      const Gap(10),

                      // ANSWERS
                      Form(
                        key: answersFormKey,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ...List.generate(answerControllers.length, (index) {
                              return Column(
                                children: [
                                  TextFormField(
                                    controller: answerControllers[index],
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      label: Text('Answer ${index + 1}'),
                                      suffixIcon: index == 0
                                          ? null
                                          : IconButton(
                                              onPressed: () => setState(() {
                                                answerControllers
                                                    .removeAt(index);
                                              }),
                                              icon: const Icon(
                                                  Icons.remove_rounded),
                                            ),
                                    ),
                                    onChanged: (value) {
                                      if (!answersFormKey.currentState!
                                          .validate()) {
                                        return;
                                      }
                                    },
                                    validator: (value) {
                                      if (value!.trim().isEmpty) {
                                        return 'Please input an answer';
                                      }
                                      if (answerControllers
                                              .where((controller) =>
                                                  controller.text.trim() ==
                                                  value.trim())
                                              .length >
                                          1) {
                                        return 'Answers must be unique';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Gap(10),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      // ADD ANSWER BUTTON
                      TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(primary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: () => setState(() {
                          answerControllers.add(TextEditingController());
                        }),
                        label: const Text('Add Answer'),
                        icon: const Icon(Icons.add_rounded),
                      ),
                      const Gap(10),

                      // POINTS
                      TextFormField(
                        controller: pointsController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Points'),
                        ),
                        validator: (value) {
                          if (int.tryParse(value!) == null) {
                            return 'Please input a number';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ADD ITEM BUTTON
                      Center(
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: addToFillInTheBlanksItems,
                          child: const Text('Add to Written Exam Items'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openAddShortAnswerModal() async {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();

        final questionController = TextEditingController();

        List<Map<String, dynamic>> itemAttachments = [];
        String? fileName;
        Uint8List? fileBytes;

        final pointsController = TextEditingController();

        void addToShortAnswerItems() {
          if (!formKey.currentState!.validate()) {
            return;
          }

          setState(() {
            writtenItems['Short Answer']!.add({
              'question': questionController.text,
              'attachments': itemAttachments,
              'points': int.parse(pointsController.text),
            });

            totalPoints += int.parse(pointsController.text);

            maxScoreController.text = totalPoints.toString();
          });

          Navigator.of(context).pop();
        }

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            void pickFile() async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: ['jpg', 'jpeg', 'png'],
                type: FileType.custom,
              );

              if (result != null) {
                fileBytes = result.files.first.bytes!;
                fileName = result.files.first.name;

                QuickAlert.show(
                  // ignore: use_build_context_synchronously
                  context: context,
                  type: QuickAlertType.loading,
                );

                final attachmentPath = await _storageService.uploadFile(
                  'classes/files/',
                  fileName!,
                  fileBytes!,
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();

                setState(() {
                  itemAttachments.add({
                    'fileName': fileName,
                    'attachment': attachmentPath,
                  });

                  fileName = null;
                  fileBytes = null;
                });
              }
            }

            void removeAttachment(int index) {
              _storageService
                  .deleteFile([itemAttachments[index]['attachment']]).then((_) {
                setState(() {
                  itemAttachments.removeAt(index);
                });
              });
            }

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Short Answer'),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => itemAttachments.isEmpty
                        ? Navigator.of(context).pop()
                        : QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Discard Changes?',
                            text:
                                'This will remove all exam items you have added. Are you sure you want to proceed?',
                            confirmBtnText: 'Yes',
                            onConfirmBtnTap: () {
                              _storageService.deleteFile(
                                itemAttachments
                                    .map((attachment) =>
                                        attachment['attachment'])
                                    .toList(),
                              );

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            showCancelBtn: true,
                            onCancelBtnTap: () => Navigator.of(context).pop,
                          ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // QUESTION
                      TextFormField(
                        controller: questionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Question'),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Please input a question';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ATTACHMENTS
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemAttachments.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<String>(
                            future: _storageService.storageRef
                                .child(itemAttachments[index]['attachment'])
                                .getDownloadURL(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else if (snapshot.hasData) {
                                return ListTile(
                                  title:
                                      Text(itemAttachments[index]['fileName']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // PREVIEW ATTACHMENT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                      'Attachment Preview'),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.close_rounded),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ],
                                              ),
                                              content:
                                                  Image.network(snapshot.data!),
                                            ),
                                          );
                                        },
                                      ),
                                      // DELETE ATTACHMENT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: 'Delete Attachment?',
                                          text:
                                              'Are you sure you want to delete this attachment?',
                                          confirmBtnText: 'Yes',
                                          onConfirmBtnTap: () =>
                                              removeAttachment(index),
                                          showCancelBtn: true,
                                          onCancelBtnTap: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return const Icon(Icons.error);
                              }
                            },
                          );
                        },
                      ),
                      itemAttachments.isNotEmpty
                          ? const Gap(10)
                          : const SizedBox(),

                      // ATTACH IMAGE BUTTON
                      TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(primary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: pickFile,
                        label: const Text('Attach Image'),
                        icon: const Icon(Icons.image_rounded),
                      ),
                      const Gap(10),

                      // POINTS
                      TextFormField(
                        controller: pointsController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Points'),
                        ),
                        validator: (value) {
                          if (int.tryParse(value!) == null) {
                            return 'Please input a number';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ADD ITEM BUTTON
                      Center(
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: addToShortAnswerItems,
                          child: const Text('Add to Written Exam Items'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openAddLongAnswerModal() async {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();

        final questionController = TextEditingController();

        List<Map<String, dynamic>> itemAttachments = [];
        String? fileName;
        Uint8List? fileBytes;

        final pointsController = TextEditingController();

        void addToLongAnswerItems() {
          if (!formKey.currentState!.validate()) {
            return;
          }

          setState(() {
            writtenItems['Long Answer']!.add({
              'question': questionController.text,
              'attachments': itemAttachments,
              'points': int.parse(pointsController.text),
            });

            totalPoints += int.parse(pointsController.text);

            maxScoreController.text = totalPoints.toString();
          });

          Navigator.of(context).pop();
        }

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            void pickFile() async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: ['jpg', 'jpeg', 'png'],
                type: FileType.custom,
              );

              if (result != null) {
                fileBytes = result.files.first.bytes!;
                fileName = result.files.first.name;

                QuickAlert.show(
                  // ignore: use_build_context_synchronously
                  context: context,
                  type: QuickAlertType.loading,
                );

                final attachmentPath = await _storageService.uploadFile(
                  'classes/files/',
                  fileName!,
                  fileBytes!,
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();

                setState(() {
                  itemAttachments.add({
                    'fileName': fileName,
                    'attachment': attachmentPath,
                  });

                  fileName = null;
                  fileBytes = null;
                });
              }
            }

            void removeAttachment(int index) {
              _storageService
                  .deleteFile([itemAttachments[index]['attachment']]).then((_) {
                setState(() {
                  itemAttachments.removeAt(index);
                });
              });
            }

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Long Answer'),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => itemAttachments.isEmpty
                        ? Navigator.of(context).pop()
                        : QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Discard Changes?',
                            text:
                                'This will remove all exam items you have added. Are you sure you want to proceed?',
                            confirmBtnText: 'Yes',
                            onConfirmBtnTap: () {
                              _storageService.deleteFile(
                                itemAttachments
                                    .map((attachment) =>
                                        attachment['attachment'])
                                    .toList(),
                              );

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            showCancelBtn: true,
                            onCancelBtnTap: () => Navigator.of(context).pop,
                          ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // QUESTION
                      TextFormField(
                        controller: questionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Question'),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Please input a question';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ATTACHMENTS
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemAttachments.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<String>(
                            future: _storageService.storageRef
                                .child(itemAttachments[index]['attachment'])
                                .getDownloadURL(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else if (snapshot.hasData) {
                                return ListTile(
                                  title:
                                      Text(itemAttachments[index]['fileName']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // PREVIEW ATTACHMENT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                      'Attachment Preview'),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.close_rounded),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ],
                                              ),
                                              content:
                                                  Image.network(snapshot.data!),
                                            ),
                                          );
                                        },
                                      ),
                                      // DELETE ATTACHMENT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: 'Delete Attachment?',
                                          text:
                                              'Are you sure you want to delete this attachment?',
                                          confirmBtnText: 'Yes',
                                          onConfirmBtnTap: () =>
                                              removeAttachment(index),
                                          showCancelBtn: true,
                                          onCancelBtnTap: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return const Icon(Icons.error);
                              }
                            },
                          );
                        },
                      ),
                      itemAttachments.isNotEmpty
                          ? const Gap(10)
                          : const SizedBox(),

                      // ATTACH IMAGE BUTTON
                      TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(primary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: pickFile,
                        label: const Text('Attach Image'),
                        icon: const Icon(Icons.image_rounded),
                      ),
                      const Gap(10),

                      // POINTS
                      TextFormField(
                        controller: pointsController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Points'),
                        ),
                        validator: (value) {
                          if (int.tryParse(value!) == null) {
                            return 'Please input a number';
                          }

                          return null;
                        },
                      ),
                      const Gap(10),

                      // ADD ITEM BUTTON
                      Center(
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: addToLongAnswerItems,
                          child: const Text('Add to Written Exam Items'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // LABORATORY MODALS

  void openAddLaboratoryItemModal() async {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();

        final problemStatementController = TextEditingController();
        final constraintsController = TextEditingController();

        List<Map<String, dynamic>> examples = [];
        List<Map<String, dynamic>> testCases = [];

        final pointsController = TextEditingController();

        return Form(
          key: formKey,
          child: AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Laboratory Item'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 75,
                      child: TextFormField(
                        controller: pointsController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Points'),
                        ),
                        validator: (value) {
                          if (int.tryParse(value!) == null) {
                            return 'Please input a number';
                          }

                          return null;
                        },
                      ),
                    ),
                    const Gap(5),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => examples.isEmpty && testCases.isEmpty
                          ? Navigator.of(context).pop()
                          : QuickAlert.show(
                              context: context,
                              type: QuickAlertType.warning,
                              title: 'Discard Changes?',
                              text:
                                  'This will remove all examples and test cases you have added. Are you sure you want to proceed?',
                              confirmBtnText: 'Yes',
                              onConfirmBtnTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              showCancelBtn: true,
                              onCancelBtnTap: () => Navigator.of(context).pop(),
                            ),
                    ),
                  ],
                ),
              ],
            ),
            content: SizedBox(
              width: 750,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PROBLEM STATEMENT
                  TextFormField(
                    controller: problemStatementController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Problem Statement'),
                    ),
                    minLines: 1,
                    maxLines: 3,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Please input a problem statement';
                      }

                      return null;
                    },
                  ),
                  const Gap(10),

                  // CONSTRAINTS
                  TextFormField(
                    controller: constraintsController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Constraints'),
                    ),
                    minLines: 1,
                    maxLines: 3,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Please input constraints';
                      }

                      return null;
                    },
                  ),
                  const Gap(10),

                  StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      void openAddExampleTestCaseModal(bool isExample) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final exampleTestCaseFormKey =
                                GlobalKey<FormState>();

                            final inputController = TextEditingController();
                            final outputController = TextEditingController();

                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(isExample
                                      ? 'Add Example'
                                      : 'Add Test Case'),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                              content: SizedBox(
                                width: 500,
                                child: Form(
                                  key: exampleTestCaseFormKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // INPUT
                                      TextFormField(
                                        controller: inputController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          label: Text('Input'),
                                        ),
                                        validator: (value) {
                                          if (value!.trim().isEmpty) {
                                            return 'Please input an input';
                                          }

                                          return null;
                                        },
                                      ),
                                      const Gap(10),

                                      // OUTPUT
                                      TextFormField(
                                        controller: outputController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          label: Text('Output'),
                                        ),
                                        validator: (value) {
                                          if (value!.trim().isEmpty) {
                                            return 'Please input an output';
                                          }

                                          return null;
                                        },
                                      ),
                                      const Gap(10),

                                      // ADD ITEM BUTTON
                                      Center(
                                        child: ElevatedButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(primary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                          ),
                                          onPressed: () {
                                            if (!exampleTestCaseFormKey
                                                .currentState!
                                                .validate()) {
                                              return;
                                            }

                                            setState(() {
                                              if (isExample) {
                                                examples.add({
                                                  'input': inputController.text,
                                                  'output':
                                                      outputController.text,
                                                });
                                              } else {
                                                testCases.add({
                                                  'input': inputController.text,
                                                  'output':
                                                      outputController.text,
                                                });
                                              }
                                            });

                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Add'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return Expanded(
                        child: Row(
                          children: [
                            // EXAMPLES
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Examples',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      // ADD EXAMPLE BUTTON
                                      Center(
                                        child: ElevatedButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(primary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                          ),
                                          onPressed: () =>
                                              openAddExampleTestCaseModal(true),
                                          child: const Text('Add Example'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: examples.length,
                                      itemBuilder: (context, index) => ListTile(
                                        leading: CircleAvatar(
                                          child: Text('${index + 1}'),
                                        ),
                                        title: Text(
                                            'Input: ${examples[index]['input']}'),
                                        subtitle: Text(
                                            'Output: ${examples[index]['output']}'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => setState(() {
                                            examples.removeAt(index);
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(10),

                            // TEST CASES
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Test Cases',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      // ADD TEST CASE BUTTON
                                      Center(
                                        child: ElevatedButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(primary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                          ),
                                          onPressed: () =>
                                              openAddExampleTestCaseModal(
                                                  false),
                                          child: const Text('Add Test Case'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: testCases.length,
                                      itemBuilder: (context, index) => ListTile(
                                        leading: CircleAvatar(
                                          child: Text('${index + 1}'),
                                        ),
                                        title: Text(
                                            'Input: ${testCases[index]['input']}'),
                                        subtitle: Text(
                                            'Output: ${testCases[index]['output']}'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => setState(() {
                                            testCases.removeAt(index);
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Gap(10),

                  // ADD ITEM BUTTON
                  Center(
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(primary),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        setState(() {
                          labItems.add({
                            'problemStatement': problemStatementController.text,
                            'constraints': constraintsController.text,
                            'examples': examples,
                            'testCases': testCases,
                            'points': int.parse(pointsController.text),
                          });

                          totalPoints += int.parse(pointsController.text);

                          maxScoreController.text = totalPoints.toString();
                        });

                        Navigator.of(context).pop();
                      },
                      child: const Text('Add to Laboratory Exam Items'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // REMOVE ITEM
  void removeItem(String? itemType, int index) {
    setState(() {
      if (itemType == null) {
        _storageService.deleteFile([labItems[index]['attachments']]);
        totalPoints -= labItems[index]['points'] as int;
        maxScoreController.text = totalPoints.toString();
        labItems.removeAt(index);
      } else {
        _storageService.deleteFile(
          writtenItems[itemType]![index]['attachments']
              .map((attachment) => attachment['attachment'])
              .toList(),
        );
        totalPoints -= writtenItems[itemType]![index]['points'] as int;
        maxScoreController.text = totalPoints.toString();
        writtenItems[itemType]!.removeAt(index);
      }
    });
  }

  // ADD EXAM TO CLASS
  void addExamToClass() {
    if (openTime == null || closeTime == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Invalid Schedule',
        text: 'Please input a valid schedule',
      );

      return;
    }

    if (!durationFormKey.currentState!.validate()) {
      return;
    }

    if (labItems.isEmpty &&
        writtenItems.values.every((element) => element.isEmpty)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'No Items Added',
        text: 'Please add at least one exam item',
      );

      return;
    }

    final newExam = {
      'exam': exam,
      'examType': examType,
      'openSchedule': openTime,
      'closeSchedule': closeTime,
      'duration': {
        'hours': hoursController.text.trim().isNotEmpty
            ? int.parse(hoursController.text)
            : 0,
        'minutes': minutesController.text.trim().isNotEmpty
            ? int.parse(minutesController.text)
            : 0,
      },
      'maxScore': int.parse(maxScoreController.text),
      'content': examType == 'Written' ? writtenItems : labItems,
    };

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    _firestoreService.addExamToClass(
      context: context,
      instructorId: widget.instructorId,
      classCode: widget.classCode,
      newExam: newExam,
    );
  }

  // NAVIGATE BACK TO CLASS SCREEN
  void goBackToClass() {
    if (labItems.isNotEmpty ||
        !writtenItems.values.every((element) => element.isEmpty)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Discard Changes?',
        text:
            'This will remove all exam items you have added. Are you sure you want to proceed?',
        confirmBtnText: 'Yes',
        onConfirmBtnTap: () {
          if (labItems.isNotEmpty) {
            _storageService.deleteFile(
              labItems.map((item) => item['attachment']).toList(),
            );

            labItems.clear();
          }

          for (var items in writtenItems.values) {
            items.forEach((item) {
              _storageService.deleteFile(
                item['attachments']
                    .map((attachment) => attachment['attachment'])
                    .toList(),
              );
            });

            items.clear();
          }

          setState(() {});

          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    maxScoreController.text = totalPoints.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: InstructorAppbar(
            userId: widget.instructorId, goBackToClass: goBackToClass),
      ),
      drawer: IconButton(
        onPressed: goBackToClass,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      body: Center(
        child: SizedBox(
          width: 1080,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          // SCREEN TITLE
                          const Text(
                            'Add New Exam',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const Gap(10),

                          Row(
                            children: [
                              // EXAM
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
                                    if (value == 'Laboratory' &&
                                        writtenItems.values
                                            .any((items) => items.isNotEmpty)) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.warning,
                                        title: 'Discard Written Items?',
                                        text:
                                            'This will remove all written exam items you have added.',
                                        confirmBtnText: 'Yes',
                                        onConfirmBtnTap: () {
                                          for (var items
                                              in writtenItems.values) {
                                            items.forEach((item) {
                                              _storageService.deleteFile(
                                                item['attachments']
                                                    .map((attachment) =>
                                                        attachment[
                                                            'attachment'])
                                                    .toList(),
                                              );
                                            });

                                            items.clear();
                                          }

                                          setState(() {
                                            examType = value!;
                                          });
                                        },
                                      );
                                    } else if (value == 'Written' &&
                                        labItems.isNotEmpty) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.warning,
                                        title: 'Discard Laboratory Items?',
                                        text:
                                            'This will remove all laboratory exam items you have added.',
                                        confirmBtnText: 'Yes',
                                        onConfirmBtnTap: () {
                                          _storageService.deleteFile(
                                            labItems
                                                .map((item) =>
                                                    item['attachment'])
                                                .toList(),
                                          );

                                          labItems.clear();

                                          setState(() {
                                            examType = value!;
                                          });
                                        },
                                      );
                                    } else {
                                      setState(() {
                                        examType = value!;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Gap(10),

                          // OPEN AND CLOSE SCHEDULE
                          StatefulBuilder(
                            builder: (BuildContext context, setState) {
                              Future<void> setDate(
                                  {required bool isOpen}) async {
                                final now = DateTime.now();
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: isOpen
                                      ? openTime ?? now
                                      : closeTime ?? now,
                                  firstDate: now,
                                  lastDate: DateTime(
                                      now.year + 1, now.month - 6, now.day),
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

                              return Row(
                                children: [
                                  // EXAM OPEN SCHEDULE
                                  Expanded(
                                    child: SizedBox(
                                      height: 45,
                                      child: ElevatedButton(
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(primary),
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.white),
                                        ),
                                        onPressed: () => setDate(isOpen: true),
                                        child: Text(openTime != null
                                            ? 'Open Schedule: ${DateFormat.yMMMEd().add_jm().format(openTime!)}'
                                            : 'Set Open Schedule'),
                                      ),
                                    ),
                                  ),
                                  const Gap(10),

                                  // EXAM CLOSE SCHEDULE
                                  Expanded(
                                    child: SizedBox(
                                      height: 45,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.red[800]),
                                          foregroundColor:
                                              const WidgetStatePropertyAll(
                                                  Colors.white),
                                        ),
                                        onPressed: () => setDate(isOpen: false),
                                        child: Text(closeTime != null
                                            ? 'Close Schedule: ${DateFormat.yMMMEd().add_jm().format(closeTime!)}'
                                            : 'Set Close Schedule'),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const Gap(10),

                          Form(
                            key: durationFormKey,
                            child: Row(
                              children: [
                                // HOURS
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('Duration (Hours)'),
                                    ),
                                    controller: hoursController,
                                    validator: (value) {
                                      if (value!.isNotEmpty &&
                                          int.tryParse(value) == null) {
                                        return 'Please input a valid duration.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const Gap(10),

                                // MINUTES
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('Duration (Minutes)'),
                                    ),
                                    controller: minutesController,
                                    validator: (value) {
                                      if (hoursController.text.trim().isEmpty &&
                                          int.tryParse(value!) == null) {
                                        return 'Please input a valid duration.';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                                const Gap(10),

                                // MAX SCORE
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('Max Score'),
                                      suffix: Text('pts'),
                                    ),
                                    controller: maxScoreController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          const Gap(10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ITEMS TITLE
                              const Text(
                                'Items',
                                style: TextStyle(fontSize: 20),
                              ),

                              // ADD ITEM BUTTON
                              examType == 'Written'
                                  ? MenuAnchor(
                                      alignmentOffset: const Offset(-30, 0),
                                      builder: (context, controller, child) {
                                        return SizedBox(
                                          width: 136.5,
                                          child: TextButton.icon(
                                            style: const ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      primary),
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.white),
                                            ),
                                            onPressed: () {
                                              if (controller.isOpen) {
                                                controller.close();
                                              } else {
                                                controller.open();
                                              }
                                            },
                                            label: const Text('Add Item'),
                                            icon: const Icon(Icons.add_rounded),
                                          ),
                                        );
                                      },
                                      menuChildren: [
                                        // MULTIPLE CHOICE
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
                                            onPressed:
                                                openAddMultipleChoiceModal,
                                            child: const Text(
                                                'Add Multiple Choice'),
                                          ),
                                        ),

                                        // TRUE OR FALSE
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
                                            onPressed: openAddTrueOrFalseModal,
                                            child: const Text('True or False'),
                                          ),
                                        ),

                                        // IDENTIFICATION
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
                                            onPressed:
                                                openAddIdentificationModal,
                                            child: const Text('Identification'),
                                          ),
                                        ),

                                        // FILL IN THE BLANKS
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
                                            onPressed:
                                                openAddFillInTheBlanksModal,
                                            child: const Text(
                                                'Fill in the Blanks'),
                                          ),
                                        ),

                                        // SHORT ANSWER
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
                                            onPressed: openAddShortAnswerModal,
                                            child: const Text('Short Answer'),
                                          ),
                                        ),

                                        // LONG ANSWER
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
                                            onPressed: openAddLongAnswerModal,
                                            child: const Text('Long Answer'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      width: 136.5,
                                      child: TextButton.icon(
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(primary),
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.white),
                                        ),
                                        onPressed: openAddLaboratoryItemModal,
                                        label: const Text('Add Item'),
                                        icon: const Icon(Icons.add_rounded),
                                      ),
                                    ),
                            ],
                          ),
                          const Gap(10),

                          // ITEM LIST
                          examType == 'Written'
                              ? writtenItems.isEmpty
                                  ? const Center(
                                      child: Text('No items added yet'),
                                    )
                                  : writtenItems.values
                                          .every((element) => element.isEmpty)
                                      ? const Center(
                                          child: Text('No items added yet'),
                                        )
                                      : ListView.builder(
                                          // IF THERE ARE ANY ITEMS ADDED
                                          shrinkWrap: true,
                                          itemCount: writtenItems.length,
                                          itemBuilder: (context, index) {
                                            final key = writtenItems.keys
                                                .elementAt(index);
                                            final items = writtenItems[key]!;
                                            if (items.isEmpty) {
                                              return const SizedBox.shrink();
                                            }
                                            return ExpansionTile(
                                              title: Text(
                                                  '$key (${items.length})'),
                                              children: [
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: items.length,
                                                  itemBuilder:
                                                      (context, itemIndex) {
                                                    return Card(
                                                      child: ListTile(
                                                        title: Text(
                                                            items[itemIndex]
                                                                ['question']),
                                                        subtitle: Text(
                                                            'Points: ${items[itemIndex]['points']}'),
                                                        trailing: IconButton(
                                                          icon: const Icon(
                                                              Icons.delete),
                                                          onPressed: () =>
                                                              removeItem(
                                                            key,
                                                            itemIndex,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        )
                              : labItems.isEmpty
                                  ? const Center(
                                      child: Text('No items added yet'),
                                    )
                                  : ListView.builder(
                                      // IF THERE ARE ANY ITEMS ADDED
                                      shrinkWrap: true,
                                      itemCount: labItems.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(labItems[index]
                                              ['problemStatement']),
                                          subtitle: Text(
                                              'Points: ${labItems[index]['points']}'),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () =>
                                                removeItem(null, index),
                                          ),
                                        );
                                      },
                                    ),
                        ],
                      ),
                    ),

                    // ADD EXAM BUTTON
                    SizedBox(
                      height: 40,
                      width: 150,
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(primary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: addExamToClass,
                        child: const Text(
                          'Add Exam',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
