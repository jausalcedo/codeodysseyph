import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/instructor/module_viewer.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InstructorClassScreen extends StatefulWidget {
  const InstructorClassScreen({super.key, required this.courseCodeYearBlock});

  final String courseCodeYearBlock;

  @override
  State<InstructorClassScreen> createState() => _InstructorClassScreenState();
}

class _InstructorClassScreenState extends State<InstructorClassScreen>
    with SingleTickerProviderStateMixin {
  final List<bool> _isExpandedList = [false, false, false];

  late TabController _tabController;

  void _toggleExpand(int index) {
    setState(() {
      _isExpandedList[index] = !_isExpandedList[index];
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Center(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Colors.white,
                  height: screenHeight * .8,
                  width: screenWidth * .7,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 225,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 19, 27, 99),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.courseCodeYearBlock,
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
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: Color.fromARGB(255, 19, 27, 99),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "05162002",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color.fromARGB(255, 19, 27, 99),
                                  ),
                                ),
                                Text(
                                  "Class Code",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(0, 0, 0, .5)),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const Gap(20),
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
                            SingleChildScrollView(
                              child: Expanded(
                                child: ListView.builder(
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Prevent internal scrolling
                                  shrinkWrap: true,
                                  itemCount: _isExpandedList.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(1000, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: const BorderSide(
                                                  color: Color(0xFF677FFD)),
                                            ),
                                            backgroundColor:
                                                const Color(0xFF677FFD),
                                          ),
                                          onPressed: () => _toggleExpand(index),
                                          child: Text(
                                            "Module ${index + 1}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 5),
                                          height:
                                              _isExpandedList[index] ? 300 : 0,
                                          color: const Color.fromARGB(
                                              255, 232, 232, 232),
                                          width: 900,
                                          child: _isExpandedList[index]
                                              ? Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Gap(15),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const ModuleViewer(
                                                                moduleName:
                                                                    "Fundamentals of Programming Module 1",
                                                                filePath:
                                                                    'assets/modules/Fundamentals of Programming Module 1.pdf',
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        icon: const Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .subdirectory_arrow_right,
                                                              size: 25,
                                                              color: primary,
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .my_library_books_rounded,
                                                              size: 30,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      19,
                                                                      27,
                                                                      99),
                                                            ),
                                                            Text(
                                                              "Topic Content",
                                                              style: TextStyle(
                                                                  color:
                                                                      primary,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const Gap(20),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .subdirectory_arrow_right,
                                                              size: 25,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      19,
                                                                      27,
                                                                      99),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  color: Colors
                                                                      .white),
                                                              width: 700,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        25,
                                                                        12,
                                                                        25,
                                                                        12),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          12.0),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          const Text(
                                                                            "Input/Output\nStatements Activity",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color.fromARGB(255, 19, 27, 99),
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.w700,
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Image.asset(
                                                                                "assets/images/java-logo.png",
                                                                                width: 20,
                                                                              ),
                                                                              const Text(
                                                                                "Java",
                                                                                style: TextStyle(
                                                                                  color: Color.fromARGB(255, 19, 27, 99),
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w700,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.calendar_today_rounded,
                                                                                color: Colors.green,
                                                                              ),
                                                                              Text(
                                                                                "16 July 2024  08:00 AM", //date start activity
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w700,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const Gap(
                                                                              5),
                                                                          const Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.calendar_today_rounded,
                                                                                color: Colors.red,
                                                                              ),
                                                                              Text(
                                                                                "23 July 2024  07:00 AM", //date start activity
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 2,
                                                                      height:
                                                                          100,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              12.0),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  Gap(15),
                                                                                  Text(
                                                                                    "0/10",
                                                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                                                                                  ),
                                                                                  Gap(15),
                                                                                  Text(
                                                                                    "Average Score",
                                                                                    style: TextStyle(fontSize: 12),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                              Gap(15),
                                                                              Column(
                                                                                children: [
                                                                                  Gap(15),
                                                                                  Text("6 days 23 hrs", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                                                                                  Gap(15),
                                                                                  Text("Activity Closes In", style: TextStyle(fontSize: 12))
                                                                                ],
                                                                              )
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Placeholder for Student Performance
                            Column(
                              children: [
                                const Gap(15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF677FFD),
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
                                                      fontWeight:
                                                          FontWeight.w500),
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
                                        color: const Color(0xFF677FFD),
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
                                                      fontWeight:
                                                          FontWeight.w500),
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
                                        color: const Color(0xFF677FFD),
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
                                                Gap(7),
                                                Text(
                                                  "Average Topic \n Completion",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w500),
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
                                const Gap(10),
                                SingleChildScrollView(
                                  scrollDirection: Axis
                                      .horizontal, // Enables horizontal scrolling if needed
                                  child: DataTable(
                                    headingRowColor:
                                        WidgetStateColor.resolveWith((states) =>
                                            const Color(0xFF677FFD)),
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
                                          DataCell(
                                              Text('Salcedo, Lance Jericho')),
                                          DataCell(Text('0/30')),
                                          DataCell(Text('0/10')),
                                          DataCell(Text('0')),
                                          DataCell(Text('40')),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(
                                              Text('Tabalba, Elijah Venisse')),
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
                                const Gap(20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 30, 0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStateProperty
                                              .all(const Color(
                                                  0xFF677FFD)), // Set background color
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8.0), // Set border radius
                                            ),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: const Text(
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
                                      padding: const EdgeInsets.fromLTRB(
                                          50, 20, 50, 0),
                                      child: SizedBox(
                                        height:
                                            400, // Set a fixed height for the ListView
                                        child: ListView.builder(
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                const Gap(60),
                                                Card(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: Colors
                                                          .grey, // Border color
                                                      width:
                                                          1.0, // Border width
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0), // Rounded corners
                                                  ),
                                                  child: const ListTile(
                                                    title: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              CircleAvatar(
                                                                backgroundColor:
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            19,
                                                                            27,
                                                                            99),
                                                                child: Text(
                                                                  "JS",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
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
                                                                      fontSize:
                                                                          18,
                                                                      color: Color.fromARGB(
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
                                                                      fontSize:
                                                                          13,
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
                                                                  FontWeight
                                                                      .w600,
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
              ),
            )
          ],
        ),
      ),
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: InstructorAppbar(),
      ),
    );
  }
}
