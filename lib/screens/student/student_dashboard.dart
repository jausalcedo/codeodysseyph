import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/components/student/student_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/screens/student/student_class.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  // AUTH SERVICE
  final authService = AuthService();

  final classCodeController = TextEditingController();

  void showJoinClassModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.only(top: 15, bottom: 0),
          // ALERT DIALOG TITLE
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 19, 27, 99),
                ),
              ),

              // CLOSE BUTTON
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          content: const Padding(
            padding: EdgeInsets.fromLTRB(35, 0, 35, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school,
                  size: 150,
                  color: Color(0xFF4A76F7),
                ),
                Text(
                  "Want to join a class?",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 19, 27, 99),
                      fontWeight: FontWeight.w800),
                ),
                Text(
                  "Enter the class code given to you by your instructor.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            Column(
              children: [
                TextField(
                  controller: classCodeController,
                  decoration: const InputDecoration(
                    label: Text('Class Code'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const Gap(10),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await firestoreService.joinClass(
                        context,
                        classCodeController.text,
                        widget.userId,
                      );

                      setState(() {
                        classCodeController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A76F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      'Join class',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        );
      },
    );
  }

  // FIRESTORE SERVICE
  final firestoreService = CloudFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: StudentDrawer(userId: widget.userId),
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: StudentAppbar(),
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
                          "Classes",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: showJoinClassModal,
                          label: const Text(
                            'JOIN CLASS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          icon: const Icon(Icons.add),
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: firestoreService.getStudentClasses(widget.userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final classes = snapshot.data!.docs;

                      if (classes.isEmpty) {
                        return const Center(
                          child: Text(
                              'You haven\'t joined any class yet. Click the button above to join one!'),
                        );
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 20.0,
                              mainAxisSpacing: 20.0,
                              childAspectRatio: 3 / 2,
                            ),
                            itemCount: classes.length,
                            itemBuilder: (context, index) {
                              // OPEN CLASS
                              return FutureBuilder(
                                future:
                                    firestoreService.getCourseClassDataFuture(
                                        'courses', classes[index]['courseId']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final courseData = snapshot.data!.data();

                                  final courseCode = courseData!['courseCode'];

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
                                                StudentClassScreen(
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
                                                  '$courseCode - IT ${classes[index]['year']}${classes[index]['block']}',
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
                                                      fontWeight:
                                                          FontWeight.w800,
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
                          ),
                        ),
                      );
                    },
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
