import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

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
  // EXAM ESSENTIALS
  String exam = 'Midterm';
  String examType = 'Written';
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();
  DateTime? openTime;
  DateTime? closeTime;

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
              child: Padding(
                padding: const EdgeInsets.all(10),
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
                              setState(() {
                                examType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),

                    // OPEN AND CLOSE SCHEDULE
                    StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        Future<void> setDate({required bool isOpen}) async {
                          final now = DateTime.now();
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                isOpen ? openTime ?? now : closeTime ?? now,
                            firstDate: now,
                            lastDate:
                                DateTime(now.year + 1, now.month - 6, now.day),
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
                                        WidgetStatePropertyAll(Colors.white),
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
                                        WidgetStatePropertyAll(Colors.red[800]),
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

                    Row(
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
                              if (int.tryParse(value!) == null) {
                                return 'Please input a number';
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
                              if (int.tryParse(value!) == null) {
                                return 'Please input a number';
                              }

                              return null;
                            },
                          ),
                        ),
                        const Gap(10),

                        // MAX SCORE
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Max Score'),
                            ),
                            controller: minutesController,
                          ),
                        ),
                      ],
                    )
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
