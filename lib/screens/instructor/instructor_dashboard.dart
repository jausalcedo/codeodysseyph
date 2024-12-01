import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/components/instructor/instructor_createClassSectionTitle.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/screens/instructor/instructor_class.dart';
import 'package:codeodysseyph/components/instructor/instructor_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

// ignore: must_be_immutable
class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key, required this.userId});

  final String userId;

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  String? selectedCourse;
  String? selectedYear;
  String? selectedBlock;
  DateTime? startDate;
  DateTime? endDate;

  // FIRESTORE SERVICE
  final firestoreService = CloudFirestoreService();

  // FORM KEY
  final addClassFormKey = GlobalKey<FormState>();

  void showAddClass() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.only(top: 20, bottom: 0),
          // ALERT DIALOG TITLE
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // INVINCIBLE WIDGET
              const Gap(50),

              // ALERT DIALOG TITLE
              const Text(
                'Create Class',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              // CLOSE BUTTON
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          // CREATE CLASS STEPS
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 35, 15),
              child: Form(
                key: addClassFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SELECT COURSE
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: primary,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 800,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const CreateClassSectionTitle(
                              number: '1',
                              sectionTitle: 'Select Course',
                            ),
                            const Gap(10),
                            FutureBuilder(
                              future:
                                  firestoreService.getCourses(widget.userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final courses = snapshot.data!.docs;

                                return DropdownButtonFormField(
                                  items: courses.map(
                                    (course) {
                                      final courseCode = course['courseCode'];
                                      final courseTitle = courseList
                                          .firstWhere(
                                            (element) =>
                                                element.code == courseCode,
                                          )
                                          .title;

                                      return DropdownMenuItem(
                                        value: course.id,
                                        child: Text(
                                            '$courseCode - $courseTitle v${course['version']}'),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (selectedValue) {
                                    selectedCourse = selectedValue!;
                                    print(selectedCourse);
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text('Select Course'),
                                  ),
                                  validator: (value) {
                                    if (value == '' || value == null) {
                                      return 'Required. Please select a course outline.';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(20),

                    // SELECT YEAR AND BLOCK
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: primary,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 800,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CreateClassSectionTitle(
                              number: '2',
                              sectionTitle: 'Select Year and Block',
                            ),
                            const Gap(10),
                            Row(
                              children: [
                                // SELECT YEAR
                                Flexible(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Select Year',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: ['1', '2', '3', '4']
                                        .map((year) => DropdownMenuItem(
                                              value: year,
                                              child: Text(year),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedYear = value;
                                        });
                                      }
                                      print('YEAR: ${selectedYear ?? 'Wala'}');
                                    },
                                    validator: (value) {
                                      if (value == '' || value == null) {
                                        return 'Required. Please select year.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const Gap(10),
                                // SELECT BLOCK
                                Flexible(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Select Block',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: ['A', 'B', 'C', 'D', 'E']
                                        .map((block) => DropdownMenuItem(
                                              value: block,
                                              child: Text(block),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedBlock = value;
                                        });
                                      }
                                      print(
                                          'BLOCK: ${selectedBlock ?? 'Wala'}');
                                    },
                                    validator: (value) {
                                      if (value == '' || value == null) {
                                        return 'Required. Please select a block.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(20),

                    // SELECT START AND END DATE
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: primary,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 800,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CreateClassSectionTitle(
                              number: '3',
                              sectionTitle: 'Set Start and End Date',
                            ),
                            const Gap(10),
                            StatefulBuilder(
                              builder: (context, setState) {
                                Future<void> selectDate(
                                    {required bool isStartDate}) async {
                                  final now = DateTime.now();
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: now,
                                    firstDate: DateTime(now.year),
                                    lastDate: DateTime(now.year + 1, 12, 31),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      if (isStartDate) {
                                        startDate = pickedDate;
                                      } else {
                                        endDate = pickedDate;
                                      }
                                    });
                                  }
                                }

                                return Row(
                                  children: [
                                    // SELECT START DATE
                                    Flexible(
                                      child: SizedBox(
                                        height: 50,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              selectDate(isStartDate: true),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.green[800]),
                                            foregroundColor:
                                                const WidgetStatePropertyAll(
                                                    Colors.white),
                                          ),
                                          label: Text(
                                            startDate != null
                                                ? 'Start: ${DateFormat.yMMMMd().format(startDate!)}'
                                                : 'Set Start Date',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          icon: const Icon(
                                              Icons.calendar_today_rounded),
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    // SELECT END DATE
                                    Flexible(
                                      child: SizedBox(
                                        height: 50,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              selectDate(isStartDate: false),
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.red),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                          ),
                                          label: Text(
                                            endDate != null
                                                ? 'End: ${DateFormat.yMMMMd().format(endDate!)}'
                                                : 'Set End Date',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          icon: const Icon(
                                              Icons.calendar_month_rounded),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: createClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'Finalize',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Future<void> createClass() async {
    if (!addClassFormKey.currentState!.validate()) {
      return;
    }

    if (startDate == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error: Please set the start date.',
        confirmBtnText: 'Okay',
        onConfirmBtnTap: Navigator.of(context).pop,
      );

      return;
    }

    if (endDate == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error: Please set the end date.',
        confirmBtnText: 'Okay',
        onConfirmBtnTap: Navigator.of(context).pop,
      );

      return;
    }

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    await firestoreService.createClass(
      context,
      selectedCourse!,
      widget.userId,
      selectedYear!,
      selectedBlock!,
      startDate!,
      endDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: InstructorDrawer(userId: widget.userId),
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: InstructorAppbar(),
      ),
      body: Center(
        child: SizedBox(
          width: 1050,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Active Classes",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: showAddClass,
                          label: const Text(
                            'ADD NEW CLASS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          icon: const Icon(Icons.add),
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: StreamBuilder(
                          stream: firestoreService
                              .getInstructorClasses(widget.userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final classes = snapshot.data!.docs;

                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20.0,
                                mainAxisSpacing: 20.0,
                                childAspectRatio: 3 / 2,
                              ),
                              itemCount: classes.length,
                              itemBuilder: (context, index) {
                                // Default card design for other items
                                return FutureBuilder(
                                  future: firestoreService.getCourseData(
                                      classes[index]['courseId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircleAvatar());
                                    }

                                    final courseData = snapshot.data!.data();

                                    final courseCode =
                                        courseData!['courseCode'];

                                    final courseTitle = courseList
                                        .firstWhere((element) =>
                                            element.code == courseCode)
                                        .title;

                                    return Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  InstructorClassScreen(
                                                classCode: classes[index].id,
                                                courseCodeYearBlock:
                                                    '$courseCode - IT ${classes[index]['year']}${classes[index]['block']}',
                                                courseTitle: courseTitle,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            side: const BorderSide(
                                              color: Color.fromARGB(
                                                  255, 19, 27, 99),
                                              width: 4,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // COURSE CODE + PROGRAM-YEAR-BLOCK
                                              Container(
                                                width: 225,
                                                height: 50,
                                                decoration: const BoxDecoration(
                                                  color: primary,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(15),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '$courseCode - IT ${classes[index]['year']}${classes[index]['block']}',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // COURSE TITLE + JAVA ICON
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 155,
                                                    child: Text(
                                                      courseTitle,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.black,
                                                      ),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                  Image.asset(
                                                    "assets/images/java-logo.png",
                                                    fit: BoxFit.contain,
                                                    height: 75,
                                                  )
                                                ],
                                              ),

                                              // INVISIBLE WIDGET TO CENTER THE COURSE TITLE
                                              const Gap(25),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }),
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
