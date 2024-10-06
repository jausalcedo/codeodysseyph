import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InstructorClassPerformance extends StatefulWidget {
  InstructorClassPerformance({super.key});

  @override
  State<InstructorClassPerformance> createState() =>
      _InstructorClassPerformanceState();
}

class _InstructorClassPerformanceState extends State<InstructorClassPerformance>
    with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> items = List<String>.generate(3, (i) => " Title $i");

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          const Gap(30),
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 19, 27, 99), // Border color
                  width: 2.0, // Border width
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              height: screenHeight * .8,
              width: screenWidth * .7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: screenWidth * 0.17, // Responsive container width
                        height:
                            screenHeight * 0.07, // Responsive container height
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 19, 27, 99),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "CC102 - IT 1A",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Image.asset(
                        "assets/images/java-logo.png",
                        width: 50,
                        height: 50,
                      ),
                      const Text(
                        "Fundamentals of Programming",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: const Color.fromARGB(255, 19, 27, 99),
                        ),
                      ),
                      Gap(250),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "05162002",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: const Color.fromARGB(255, 19, 27, 99)),
                          ),
                          Text(
                            "Class Code",
                            style: TextStyle(
                                fontSize: 8,
                                color: Color.fromRGBO(0, 0, 0, .5)),
                          )
                        ],
                      )
                    ],
                  ),
                  Gap(20),
                  TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    tabs: const <Widget>[
                      Tab(
                        text: 'Lessons',
                      ),
                      Tab(
                        text: 'Student Performance',
                      ),
                      Tab(
                        text: 'Announcements',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.code, size: 80, color: Colors.blue),
                              SizedBox(height: 20),
                              Text(
                                'Lessons',
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                        // Placeholder for Student Performance
                        Column(
                          children: [
                            Gap(15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF677FFD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  width: 250,
                                  height: 80,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(17, 12, 17, 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Gap(10),
                                            Text(
                                              "Students Enrolled",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text("5",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w800))
                                          ],
                                        ),
                                        Icon(
                                          Icons.groups,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF677FFD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  width: 250,
                                  height: 80,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(17, 12, 17, 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Gap(10),
                                            Text(
                                              "Average Grade",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text("0%",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w800))
                                          ],
                                        ),
                                        Icon(
                                          Icons.area_chart_outlined,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF677FFD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  width: 250,
                                  height: 80,
                                  child: const Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        17, 12, 17, 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Gap(7),
                                            Text(
                                              "Average Topic \n Completion",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text("0%",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800))
                                          ],
                                        ),
                                        Icon(
                                          Icons.library_books_outlined,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gap(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 150,
                                  height: 30,
                                  child: DropdownButtonFormField<String>(
                                    iconSize: 12,
                                    style: TextStyle(fontSize: 8),
                                    decoration: InputDecoration(
                                      labelText: 'Courses and Activity',
                                      labelStyle: TextStyle(fontSize: 8),
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
                                ),
                                Container(
                                  width: 150,
                                  height: 30,
                                  child: DropdownButtonFormField<String>(
                                    style: TextStyle(fontSize: 8),
                                    decoration: InputDecoration(
                                      labelText: 'Search Student',
                                      labelStyle: TextStyle(fontSize: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                    iconSize: 12,
                                    items: ['Java', 'Python', 'C++']
                                        .map((language) => DropdownMenuItem(
                                              value: language,
                                              child: Text(language),
                                            ))
                                        .toList(),
                                    onChanged: (value) {},
                                  ),
                                ),
                                Container(
                                  width: 150,
                                  height: 30,
                                  child: DropdownButtonFormField<String>(
                                    iconSize: 12,
                                    style: TextStyle(fontSize: 10),
                                    decoration: InputDecoration(
                                      labelText: 'Search Lesson',
                                      labelStyle: TextStyle(fontSize: 8),
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
                                ),
                                Container(
                                  width: 150,
                                  height: 30,
                                  child: DropdownButtonFormField<String>(
                                    iconSize: 12,
                                    style: TextStyle(fontSize: 10),
                                    decoration: InputDecoration(
                                      labelText: 'Search Activity',
                                      labelStyle: TextStyle(fontSize: 8),
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
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .green, // Set the background color to green
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.picture_as_pdf,
                                          size: 16, color: Colors.white),
                                      Gap(8),
                                      Text(
                                        "Export Records",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Gap(10),
                            SingleChildScrollView(
                              scrollDirection: Axis
                                  .horizontal, // Enables horizontal scrolling if needed
                              child: DataTable(
                                headingRowColor: MaterialStateColor.resolveWith(
                                    (states) => Color(0xFF677FFD)!),
                                columns: const <DataColumn>[
                                  DataColumn(
                                    label: Text(
                                      'Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                    tooltip: 'Name of the student',
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Basic Program Structure Activity',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                    tooltip: 'Marks out of 30',
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Input/Output Statements Activity',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                    tooltip: 'Marks out of 10',
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Total Score',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                    tooltip: 'Total score of the student',
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Max Score',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                    tooltip: 'Maximum possible score',
                                  ),
                                ],
                                rows: const <DataRow>[
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text('Biag, Joreson Mark')),
                                      DataCell(Text('0/30')),
                                      DataCell(Text('0/10')),
                                      DataCell(Text('0')),
                                      DataCell(Text('40')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text('Cuison, Jordan')),
                                      DataCell(Text('0/30')),
                                      DataCell(Text('0/10')),
                                      DataCell(Text('0')),
                                      DataCell(Text('40')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text('Salcedo, Lance Jericho')),
                                      DataCell(Text('0/30')),
                                      DataCell(Text('0/10')),
                                      DataCell(Text('0')),
                                      DataCell(Text('40')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text('Tabalba, Elijah Venisse')),
                                      DataCell(Text('0/30')),
                                      DataCell(Text('0/10')),
                                      DataCell(Text('0')),
                                      DataCell(Text('40')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text('Villanueva, Jyra')),
                                      DataCell(Text('0/30')),
                                      DataCell(Text('0/10')),
                                      DataCell(Text('0')),
                                      DataCell(Text('40')),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        // Placeholder for Announcements
                        Column(
                          children: [
                            Gap(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 30, 0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(Color(
                                              0xFF677FFD)), // Set background color
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Set border radius
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      "+Create Announcement",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              child: Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(50, 20, 50, 0),
                                  child: SizedBox(
                                    height:
                                        400, // Set a fixed height for the ListView
                                    child: ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Gap(60),
                                            Card(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  color: Colors
                                                      .grey, // Border color
                                                  width: 1.0, // Border width
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0), // Rounded corners
                                              ),
                                              child: ListTile(
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            child: Text(
                                                              "JS",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            backgroundColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    19,
                                                                    27,
                                                                    99),
                                                          ),
                                                          Gap(8),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Jau Salcedo",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 18,
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      19,
                                                                      27,
                                                                      99),
                                                                ),
                                                              ),
                                                              Text(
                                                                "October 6, 2024",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      Gap(10),
                                                      Text(
                                                        "Welcome to Fundamentals of Programming!",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                                  maxLines:
                                                      3, // Limit subtitle text to 3 lines
                                                  overflow: TextOverflow
                                                      .ellipsis, // Show ellipsis if text overflows
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: InstructorAppbar(),
      ),
    );
  }
}
