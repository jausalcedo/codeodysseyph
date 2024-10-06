import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/screens/instructor/instructor_studentPerformance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class InstructorDashboardScreen extends StatelessWidget {
  InstructorDashboardScreen({super.key, required this.userId});

  final String userId;
  final List<String> items = List.generate(5, (index) => 'CC102- IT $index A');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              Icons.insert_chart,
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
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          40, 30, 0, 0),
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
        child: InstructorAppbar(),
      ),
    );
  }
}
