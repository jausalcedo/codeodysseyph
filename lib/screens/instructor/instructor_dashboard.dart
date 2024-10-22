import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/screens/instructor/instructor_studentPerformance.dart';
import 'package:codeodysseyph/components/instructor/instructor_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/models/class.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class Class {
  final String courseCode;
  final String courseTitle;
  final String year;
  final String block;

  Class({
    required this.courseCode,
    required this.courseTitle,
    required this.year,
    required this.block,
  });
}

class InstructorDashboardScreen extends StatelessWidget {
  InstructorDashboardScreen({super.key, required this.userId});

  final String userId;

  List items = ["Java"];

  final List<Class> classes = [
    Class(
      courseCode: 'CC102',
      courseTitle: 'Fundamentals of Programming',
      year: '1',
      block: 'A',
    ),
    Class(
      courseCode: 'CC103',
      courseTitle: 'Intermediate Programming',
      year: '1',
      block: 'A',
    ),
    Class(
      courseCode: 'CC104',
      courseTitle: 'Data Structures and Algorithms',
      year: '1',
      block: 'A',
    ),
    Class(
      courseCode: 'OOP101',
      courseTitle: 'Object Oriented Programming',
      year: '1',
      block: 'A',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    TextEditingController fname = TextEditingController();
    TextEditingController lname = TextEditingController();
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    void showAddClass() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.only(top: 20, bottom: 0),
            title: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Create Class',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 19, 27, 99),
                  ),
                ),
                Positioned(
                  right: 0.0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(35, 15, 35, 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Gap(20),
                    Container(
                      width: 800,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 19, 27, 99),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        Color.fromARGB(255, 19, 27, 99),
                                    child: Text(
                                      "1",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Gap(10),
                                  Text(
                                    "Select The Programming Language",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 19, 27, 99),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(
                                  10), // Adds some space between the row and dropdown
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Programming Language',
                                  border: OutlineInputBorder(),
                                ),
                                items: ['Java', 'Python', 'C++']
                                    .map((language) => DropdownMenuItem(
                                          value: language,
                                          child: Text(language),
                                        ))
                                    .toList(),
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Container(
                      width: 800,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 19, 27, 99),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        Color.fromARGB(255, 19, 27, 99),
                                    child: Text(
                                      "2",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Gap(10),
                                  Text(
                                    "Select Course",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 19, 27, 99),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Course',
                                  border: OutlineInputBorder(),
                                ),
                                items: ['OOP']
                                    .map((year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(year),
                                        ))
                                    .toList(),
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Container(
                      width: 800,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 19, 27, 99),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        Color.fromARGB(255, 19, 27, 99),
                                    child: Text(
                                      "3",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Gap(10),
                                  Text(
                                    "Year and Block",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 19, 27, 99),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
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
                                      onChanged: (value) {},
                                    ),
                                  ),
                                  const Gap(8),
                                  SizedBox(
                                    width: 200,
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Select Block',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: ['A', 'B', 'C', 'D', 'E']
                                          .map((year) => DropdownMenuItem(
                                                value: year,
                                                child: Text(year),
                                              ))
                                          .toList(),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Container(
                      width: 800,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 19, 27, 99),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        Color.fromARGB(255, 19, 27, 99),
                                    child: Text(
                                      "3",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Gap(10),
                                  Text(
                                    "Customize Course",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 19, 27, 99),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Course',
                                  border: OutlineInputBorder(),
                                ),
                                items: ['OOP']
                                    .map((year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(year),
                                        ))
                                    .toList(),
                                onChanged: (value) {},
                              ),
                              SizedBox(
                                width: 800,
                                height: 200,
                                child: Expanded(
                                  child: ListView.builder(
                                    itemCount: items
                                        .length, // Adjust the number of list items as needed
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        leading: const Icon(Icons.book),
                                        title: Text('Course Topic $index'),
                                        trailing: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onTap: () {
                                          // Action on tap
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Tapped on module $index')),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print(fname.text);
                    print(lname.text);

                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      text: 'Class is created successfully!',
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
                    'Save',
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

    // ADD DUMMY CLASS FOR CREATE CLASS BUTTON
    classes.add(Class(
      courseCode: '',
      courseTitle: '',
      year: '',
      block: '',
    ));

    return Scaffold(
      drawer: InstructorDrawer(userId: userId),
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
                                onTap: () {
                                  showAddClass();
                                },
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
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InstructorClassPerformance()));
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
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
