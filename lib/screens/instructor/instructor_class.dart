import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:disclosure/disclosure.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InstructorClassScreen extends StatefulWidget {
  const InstructorClassScreen({
    super.key,
    required this.userId,
    required this.classCode,
    required this.courseCodeYearBlock,
    required this.courseTitle,
  });

  final String userId;
  final String classCode;
  final String courseCodeYearBlock;
  final String courseTitle;

  @override
  State<InstructorClassScreen> createState() => _InstructorClassScreenState();
}

class _InstructorClassScreenState extends State<InstructorClassScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: InstructorAppbar(userId: widget.userId),
      ),
      body: Center(
        child: SizedBox(
          width: 1080,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // COURSE CODE YEAR BLOCK
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
                            const Gap(10),
                            // JAVA LOGO
                            Image.asset(
                              "assets/images/java-logo.png",
                              width: 50,
                              height: 50,
                            ),
                            // COURSE TITLE
                            Text(
                              widget.courseTitle,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 19, 27, 99),
                              ),
                            ),
                          ],
                        ),
                        // CLASS CODE
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.classCode,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color.fromARGB(255, 19, 27, 99),
                                ),
                              ),
                              const Text(
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
                    TabBar(
                      controller: tabController,
                      tabs: const [
                        Tab(text: 'Course Work'),
                        Tab(text: 'Student Performance'),
                        Tab(text: 'Annoucements'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          // COURSE WORK
                          DisclosureGroup(
                            multiple: false,
                            clearable: true,
                            insets: const EdgeInsets.all(15),
                            children: List<Widget>.generate(5, (index) {
                              return Disclosure(
                                key: ValueKey('lesson-$index'),
                                wrapper: (state, child) {
                                  return Card.outlined(
                                    color: state.closed ? primary : secondary,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: state.closed
                                            ? Colors.black26
                                            : secondary,
                                        width: state.closed ? 1 : 2,
                                      ),
                                    ),
                                    child: child,
                                  );
                                },
                                header: DisclosureButton(
                                  child: ListTile(
                                    title: Text(
                                      'Disclosure Panel ${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    trailing: const DisclosureIcon(),
                                  ),
                                ),
                                divider: const Divider(height: 1),
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen.",
                                  ),
                                ),
                              );
                            }),
                          ),
                          // STUDENT PERFORMANCE
                          const Placeholder(),
                          // ANNOUNCEMENTS
                          const Placeholder(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
