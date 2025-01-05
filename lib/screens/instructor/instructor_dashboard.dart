import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/components/instructor/instructor_createClassSectionTitle.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/screens/instructor/instructor_class.dart';
import 'package:codeodysseyph/components/instructor/instructor_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/alert_service.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

// ignore: must_be_immutable
class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key, required this.instructorId});

  final String instructorId;

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  // CREATE CLASS DATA
  String? selectedCourse;
  String? selectedYear;
  String? selectedBlock;
  int selectedAcademicYear = DateTime.now().year;
  String selectedSemester = 'First Semester';

  // SERVICES
  final _firestoreService = CloudFirestoreService();
  final _alertService = AlertService();

  // FORM KEYS
  final addClassFormKey = GlobalKey<FormState>();
  final acadYearSemFormKey = GlobalKey<FormState>();

  void showAddClass() {
    final currentYear = DateTime.now().year;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
                onPressed: () {
                  clearFields();
                  Navigator.of(context).pop();
                },
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
                            future: _firestoreService
                                .getCoursesFuture(widget.instructorId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final courses = snapshot.data!.docs;

                              return DropdownButtonFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text('Course'),
                                ),
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
                                },
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
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    label: Text('Year'),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: ['1st', '2nd', '3rd', '4th']
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
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    label: Text('Block'),
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

                  // SELECT ACADEMIC YEAR AND SEMESTER
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
                            sectionTitle: 'Set Academic Year and Semester',
                          ),
                          const Gap(10),
                          Form(
                            key: acadYearSemFormKey,
                            child: Row(
                              children: [
                                // ACADEMIC YEAR
                                Expanded(
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('Academic Year'),
                                    ),
                                    value: selectedAcademicYear,
                                    items: [
                                      currentYear - 1,
                                      currentYear,
                                      currentYear + 1,
                                      currentYear + 2,
                                      currentYear + 3,
                                    ]
                                        .map(
                                          (year) => DropdownMenuItem(
                                            value: year,
                                            child: Text('$year - ${year + 1}'),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAcademicYear = value!;
                                      });
                                    },
                                  ),
                                ),
                                const Gap(10),
                                // SEMESTER
                                Expanded(
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('Semester'),
                                    ),
                                    value: selectedSemester,
                                    items: ['First Semester', 'Second Semester']
                                        .map(
                                          (semester) => DropdownMenuItem(
                                            value: semester,
                                            child: Text(semester),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSemester = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
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
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> createClass() async {
    if (!addClassFormKey.currentState!.validate()) {
      return;
    }

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    final courseData = await _firestoreService.getCourseClassDataFuture(
        'courses', selectedCourse!);
    final courseCode = courseData['courseCode'];

    // CHECK IF THERE IS ALREADY A CLASS IN CURRENT ACADYEAR AND SEM OF THAT COURSE
    final noDuplicate = await _firestoreService.noDuplicateClass(
      courseCode: courseCode,
      year: selectedYear!,
      block: selectedBlock!,
      academicYear: selectedAcademicYear,
      semester: selectedSemester,
    );

    if (!noDuplicate) {
      // POP THE LOADING
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      return QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Error!',
        text:
            'You already have an existing class for $courseCode\nfor the $selectedSemester of the Academic Year $selectedAcademicYear - ${selectedAcademicYear + 1}.',
        confirmBtnText: 'Okay',
        // ignore: use_build_context_synchronously
        onConfirmBtnTap: Navigator.of(context).pop,
      );
    }

    await _firestoreService
        .createClass(
      // ignore: use_build_context_synchronously
      context: context,
      courseId: selectedCourse!,
      instructorId: widget.instructorId,
      year: selectedYear!,
      block: selectedBlock!,
      academicYear: selectedAcademicYear,
      semester: selectedSemester,
    )
        .then((_) {
      clearFields();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    });
  }

  void clearFields() {
    selectedCourse = null;
    selectedYear = null;
    selectedBlock = null;
    selectedAcademicYear = DateTime.now().year;
    selectedSemester = 'First Semester';
  }

  void openConfirmDeleteClass(String classCode, String className) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Confirm Delete $className?',
      onConfirmBtnTap: () => deleteClass(classCode, className),
      showCancelBtn: true,
    );
  }

  Future<void> deleteClass(String classCode, String className) async {
    QuickAlert.show(context: context, type: QuickAlertType.loading);

    _firestoreService.deleteClass(classCode: classCode).then((_) {
      // DISMISS LOADING
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // DISMISS CONFIRM
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      _alertService.showBanner(context, '$className Successfully Deleted');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: InstructorDrawer(userId: widget.instructorId),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Study Area",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: showAddClass,
                          label: const Text(
                            'Add New Class',
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
                        stream: _firestoreService
                            .getInstructorClassesStream(widget.instructorId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final classes = snapshot.data!.docs;

                          if (classes.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      'No classes available. Click the button above to add one!'),
                                ],
                              ),
                            );
                          } else {
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
                                // CLASS DATA
                                final courseCode = classes[index]['courseCode'];
                                final year = classes[index]['year'][0];
                                final block = classes[index]['block'];
                                final academicYear =
                                    classes[index]['academicYear'];
                                final semester = classes[index]['semester'];

                                String courseTitle = courseList
                                    .firstWhere(
                                        (element) => element.code == courseCode)
                                    .title;

                                // Default card design for other items
                                return Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InstructorClassScreen(
                                            instructorId: widget.instructorId,
                                            classCode: classes[index].id,
                                            courseCodeYearBlock:
                                                '$courseCode - IT $year$block',
                                            courseTitle: courseTitle,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 19, 27, 99),
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
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
                                                    '$courseCode - IT $year$block',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: IconButton(
                                                  onPressed: () =>
                                                      openConfirmDeleteClass(
                                                          classes[index].id,
                                                          '$courseCode IT-$year$block'),
                                                  icon: const Icon(
                                                    Icons.delete_rounded,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.black,
                                                  ),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ),
                                              Image.asset(
                                                "assets/images/java-logo.png",
                                                fit: BoxFit.contain,
                                                height: 75,
                                              )
                                            ],
                                          ),

                                          // SEMESTER AND ACADEMIC YEAR
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: Text(
                                                  '$semester A.Y. $academicYear - ${academicYear + 1}'),
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
                        },
                      ),
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
