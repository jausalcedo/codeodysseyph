import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/components/student/student_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/models/class.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
    ),
    Class(
      classCode: 'PSU-URD-0002',
      courseCode: 'CC103',
      courseTitle: 'Intermediate Programming',
      year: '1',
      block: 'A',
    ),
    Class(
      classCode: 'PSU-URD-0003',
      courseCode: 'CC104',
      courseTitle: 'Data Structures and Algorithms',
      year: '1',
      block: 'A',
    ),
    Class(
      classCode: 'PSU-URD-0004',
      courseCode: 'OOP101',
      courseTitle: 'Object Oriented Programming',
      year: '1',
      block: 'A',
    ),
  ];

  final authService = AuthService();

  void openJoinClassModal() {}

  @override
  Widget build(BuildContext context) {
    // ADD DUMMY CLASS FOR JOIN CLASS BUTTON
    classes.add(Class(
      classCode: '',
      courseCode: '',
      courseTitle: '',
      year: '',
      block: '',
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
                              onTap: openJoinClassModal,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
