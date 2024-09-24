import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StudentDashboardScreen extends StatelessWidget {
  StudentDashboardScreen({super.key, required this.userId});
  final List<String> items = List.generate(5, (index) => 'CC102- IT $index A');
  final String userId;

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          const Gap(40),
          ListTile(
            leading: const Icon(
              Icons.school,
              size: 40,
              color: Color.fromARGB(255, 19, 27, 99),
            ),
            title: const Text(
              'Courses',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 19, 27, 99),
              ),
            ),
            onTap: () {
              // Handle navigation or actions here
            },
          ),
          const Gap(20),
          ListTile(
            leading: const Icon(
              Icons.code_rounded,
              size: 40,
              color: Color.fromARGB(255, 19, 27, 99),
            ),
            title: const Text(
              'Playground',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 19, 27, 99),
              ),
            ),
            onTap: () {
              // Handle navigation or actions here
            },
          ),
          const Gap(20),
          ListTile(
            leading: const Icon(
              Icons.lightbulb_rounded,
              size: 40,
              color: Color.fromARGB(255, 19, 27, 99),
            ),
            title: const Text(
              'Daily Challenge',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 19, 27, 99),
              ),
            ),
            onTap: () {
              // Handle navigation or actions here
            },
          ),
        ]),
      ),
      body: Column(
        children: [
          Gap(screenWidth * 0.02),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(300, 0, 0, 0),
                child: const Text(
                  "Classes",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          Gap(screenWidth * 0.02),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              width: screenWidth * 0.7, // Responsive width (70% of the screen)
              height:
                  screenHeight * 0.7, // Responsive height (70% of the screen)
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 1200
                        ? 3
                        : screenWidth > 800
                            ? 2
                            : 1, // Adapt number of columns based on screen width
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // Check if it's the last item
                    if (index == items.length - 1) {
                      // Special design for the last item
                      return Card(
                        color: const Color.fromARGB(255, 253, 253,
                            253), // Different background color for the last item
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(
                            color: Color.fromARGB(
                                255, 104, 105, 119), // Different border color
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "+Join Class",
                            style: TextStyle(
                                fontSize: screenWidth * 0.011,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 104, 105, 119)),
                          ),
                        ),
                      );
                    } else {
                      // Default card design for other items
                      return Center(
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 19, 27, 99),
                              width: 4,
                            ),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: screenWidth *
                                        0.17, // Responsive container width
                                    height: screenHeight *
                                        0.05, // Responsive container height
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 19, 27, 99),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        items[index],
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(85, 30, 0, 0),
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 30, 0, 0),
                                              child: Text(
                                                "Fundamentals of\nProgramming",
                                                style: TextStyle(
                                                  fontSize: screenWidth *
                                                      0.011, // Responsive font size
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color.fromARGB(
                                                      255, 21, 21, 21),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: screenWidth *
                                                    0.07, // Responsive width
                                                maxHeight: screenHeight *
                                                    0.11, // Responsive height
                                              ),
                                              child: Image.asset(
                                                "assets/images/java-logo.png",
                                                fit: BoxFit
                                                    .contain, // Ensure the image fits within the space
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: StudentAppbar(),
      ),
    );
  }
}
