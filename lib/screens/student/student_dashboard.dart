import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/components/student/student_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/models/class.dart';
import 'package:codeodysseyph/screens/student/student_module_activities.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class StudentDashboardScreen extends StatelessWidget {
  StudentDashboardScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  final List<Class> classes = [
    Class(
      classCode: 'PSU-URD-0001',
      courseCode: 'CC102',
      courseTitle: 'Fundamentals of Programming',
      year: '1',
      block: 'A',
      instructorId: 'ewan',
    ),
    Class(
      classCode: 'PSU-URD-0002',
      courseCode: 'CC103',
      courseTitle: 'Intermediate Programming',
      year: '1',
      block: 'A',
      instructorId: 'ewan',
    ),
    Class(
      classCode: 'PSU-URD-0003',
      courseCode: 'CC104',
      courseTitle: 'Data Structures and Algorithms',
      year: '1',
      block: 'A',
      instructorId: 'ewan',
    ),
    Class(
      classCode: 'PSU-URD-0004',
      courseCode: 'OOP101',
      courseTitle: 'Object Oriented Programming',
      year: '1',
      block: 'A',
      instructorId: 'ewan',
    ),
  ];

  final authService = AuthService();

  final classCodeController = TextEditingController();

  void openJoinClassModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    label: Text('Class code'),
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
                    onPressed: () {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                        text: 'You successfully joined in the class',
                        confirmBtnText: 'OK',
                        onConfirmBtnTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      );
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

  @override
  Widget build(BuildContext context) {
    // ADD DUMMY CLASS FOR JOIN CLASS BUTTON
    classes.add(Class(
      classCode: '',
      courseCode: '',
      courseTitle: '',
      year: '',
      block: '',
      instructorId: '',
    ));

    return Scaffold(
      drawer: StudentDrawer(userId: userId),
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
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Classes",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
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
                          // Check if it's the last item
                          if (index == classes.length - 1) {
                            // CREATE CLASS CARD
                            return GestureDetector(
                              onTap: () => openJoinClassModal(context),
                              child: DottedBorder(
                                color: black50,
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(25),
                                strokeWidth: 3,
                                dashPattern: const [10, 5],
                                child: const Card(
                                  child: Center(
                                    child: Text(
                                      "+ Join Class",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: black50,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Default card design for other items
                            return Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const StudentViewModuleAnnouncement()));
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: const BorderSide(
                                      color: Color.fromARGB(255, 19, 27, 99),
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
                                            bottomRight: Radius.circular(15),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${classes[index].courseCode} - IT ${classes[index].year}${classes[index].block}',
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
                                              classes[index].courseTitle,
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

                                      // INVISIBLE WIDGET TO CENTER THE COURSE TITLE
                                      const Gap(25),
                                    ],
                                  ),
                                ),
                              ),
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
