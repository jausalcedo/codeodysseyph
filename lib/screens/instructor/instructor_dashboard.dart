import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/screens/instructor/instructor_studentPerformance.dart';
import 'package:codeodysseyph/components/instructor/instructor_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/models/class.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class InstructorDashboardScreen extends StatelessWidget {
  InstructorDashboardScreen({super.key, required this.userId});

  final String userId;

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
                    Gap(20),
                    Container(
                      width: 800,
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Color.fromARGB(255, 19, 27, 99),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              Gap(10), // Adds some space between the row and dropdown
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
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
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Color.fromARGB(255, 19, 27, 99),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              Gap(10),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
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
                    Gap(20),
                    Container(
                      width: 800,
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Color.fromARGB(255, 19, 27, 99),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              Gap(10),
                              Row(
                                children: [
                                  Container(
                                    width: 200,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
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
                                  Gap(8),
                                  Container(
                                    width: 200,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
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
                    Gap(20),
                    Container(
                      width: 800,
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Color.fromARGB(255, 19, 27, 99),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              Gap(10),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
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
                              Container(
                                width: 800,
                                height: 200,
                                child: Expanded(
                                  child: ListView.builder(
                                    itemCount: items
                                        .length, // Adjust the number of list items as needed
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        leading: Icon(Icons.book),
                                        title: Text('Course Topic $index'),
                                        trailing: Icon(
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

                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // Check if it's the last item
                    if (index == items.length - 1) {
                      // Special design for the last item
                      return GestureDetector(
                        onTap: () {
                          showAddClass();
                        },
                        child: Card(
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
                              "+Create Class",
                              style: TextStyle(
                                  fontSize: screenWidth * 0.011,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 104, 105, 119)),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Default card design for other items
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  InstructorClassPerformance(),
                            ),
                          );
                        },
                        child: Center(
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
                                        color: const Color.fromARGB(
                                            255, 19, 27, 99),
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
