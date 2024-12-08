import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/components/student/student_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/screens/student/student_class.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({
    super.key,
    required this.studentId,
  });

  final String studentId;

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  // SERVICES
  final _firestoreService = CloudFirestoreService();

  // JOIN CLASS ESSENTIALS
  final classCodeController = TextEditingController();

  // FORM KEYS
  final joinClassFormKey = GlobalKey<FormState>();

  // JOIN CLASS MODAL
  void showJoinClassModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // CLOSE BUTTON
            IconButton(
              onPressed: () {
                // CLEAR THE CLASS CODE CONTROLLER FIRST
                classCodeController.clear();
                // POP THE MODAL
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          height: 325,
          width: 600,
          child: Form(
            key: joinClassFormKey,
            child: Column(
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 150,
                  color: secondary,
                ),
                const Text(
                  'Want to join a class?',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 19, 27, 99),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(10),
                const Text(
                  "Enter the class code given to you by your instructor.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const Gap(25),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Class Code'),
                    ),
                    controller: classCodeController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a Class Code.';
                      }
                      return null;
                    },
                  ),
                ),
                // const Gap(25),
              ],
            ),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(primary),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  )),
              onPressed: () => joinClass(classCodeController.text),
              child: const Text(
                'Join',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> joinClass(String classCode) async {
    // VALIDATE CLASS CODE
    if (!joinClassFormKey.currentState!.validate()) {
      return;
    }

    // SHOW LOADING
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    // JOIN CLASS
    await _firestoreService.joinClass(
      context,
      classCodeController.text,
      widget.studentId,
    );

    // CLEAR CLASS CODE FIELD
    classCodeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: StudentAppbar(),
      ),
      drawer: StudentDrawer(studentId: widget.studentId),
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
                          onPressed: showJoinClassModal,
                          label: const Text(
                            'Join a Class',
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
                            .getStudentClasses(widget.studentId),
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
                                              StudentClassScreen(
                                            studentId: widget.studentId,
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
                                          Container(
                                            width: 225,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              color: primary,
                                              borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(15),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '$courseCode - IT $year$block',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
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
