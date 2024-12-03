import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:disclosure/disclosure.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

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
  // TAB ESSENTIALS
  late TabController tabController;

  // SERVICES
  final _firestoreService = CloudFirestoreService();
  final _storageService = FirebaseStorageService();

  // OPERATIONS
  Future<void> downloadLearningMaterial(String learningMaterialPath) async {
    final downloadUrl = await _storageService.storageRef
        .child(learningMaterialPath)
        .getDownloadURL();
    if (!await launchUrl(Uri.parse(downloadUrl))) {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text:
            'There was a problem downloading the learning material. Please try again in a few minutes...',
        confirmBtnText: 'Okay',
        // ignore: use_build_context_synchronously
        onCancelBtnTap: Navigator.of(context).pop,
      );
    }
  }

  void openAddLessonModal() {
    // TO DO
  }

  void openAddActivityModal() {
    // TO DO
  }

  void openAddAdditionalResourceModal() {
    // TO DO
  }

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
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
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
                            height: 60,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.classCode,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: primary,
                              ),
                            ),
                            const Text(
                              "Class Code",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
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
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Lessons:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  MenuAnchor(
                                    alignmentOffset: const Offset(-100, 0),
                                    builder: (context, controller, child) {
                                      return ElevatedButton.icon(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(primary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white)),
                                        onPressed: () {
                                          if (controller.isOpen) {
                                            controller.close();
                                          } else {
                                            controller.open();
                                          }
                                        },
                                        label: const Text('Add'),
                                        icon: const Icon(Icons.add_rounded),
                                      );
                                    },
                                    menuChildren: [
                                      // ADD LESSON
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    secondary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            shape: WidgetStatePropertyAll(
                                                ContinuousRectangleBorder()),
                                          ),
                                          onPressed: openAddLessonModal,
                                          label: const Text('New Lesson'),
                                          icon: const Icon(
                                              Icons.library_books_rounded),
                                        ),
                                      ),
                                      // ADD ACTIVITY
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    secondary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            shape: WidgetStatePropertyAll(
                                                ContinuousRectangleBorder()),
                                          ),
                                          onPressed: openAddActivityModal,
                                          label: const Text('New Activity'),
                                          icon: const Icon(Icons
                                              .drive_file_rename_outline_rounded),
                                        ),
                                      ),
                                      // ADD ADDITIONAL RESOURCES
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    secondary),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            shape: WidgetStatePropertyAll(
                                                ContinuousRectangleBorder()),
                                          ),
                                          onPressed:
                                              openAddAdditionalResourceModal,
                                          label:
                                              const Text('Additional Resource'),
                                          icon: const Icon(
                                              Icons.attach_file_rounded),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(5),
                              Expanded(
                                child: ListView(
                                  children: [
                                    StreamBuilder(
                                      stream: _firestoreService
                                          .getClassData(widget.classCode),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final classData = snapshot.data!.data();

                                        final lessons = classData!['lessons'];

                                        return DisclosureGroup(
                                          multiple: false,
                                          clearable: true,
                                          // insets: const EdgeInsets.all(15),
                                          children: List<Widget>.generate(
                                            lessons.length,
                                            (index) {
                                              final List<dynamic> activities =
                                                  lessons[index]
                                                          ['activities'] ??
                                                      [];

                                              final List<dynamic>
                                                  additionalResources =
                                                  lessons[index][
                                                          'additionalResources'] ??
                                                      [];

                                              return Disclosure(
                                                key: ValueKey('lesson-$index'),
                                                wrapper: (state, child) {
                                                  return Card.outlined(
                                                    color: primary,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        color: Colors.black26,
                                                        width: state.closed
                                                            ? 1
                                                            : 2,
                                                      ),
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                header: DisclosureButton(
                                                  child: ListTile(
                                                    title: Text(
                                                      'Lesson ${index + 1}: ${lessons[index]['title']}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    trailing:
                                                        const DisclosureIcon(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                divider:
                                                    const Divider(height: 1),
                                                child: Container(
                                                  color: Colors.white,
                                                  width: double.infinity,
                                                  // CONTENT HEIGHT
                                                  height: 400,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // LEARNING MATERIAL
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Learning Material: ${lessons[index]['title']}.pdf',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    WidgetStatePropertyAll(
                                                                        Colors.green[
                                                                            800]),
                                                                foregroundColor:
                                                                    const WidgetStatePropertyAll(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                              onPressed: () =>
                                                                  downloadLearningMaterial(
                                                                      lessons[index]
                                                                          [
                                                                          'learningMaterial']),
                                                              child: const Row(
                                                                children: [
                                                                  Text(
                                                                      'Download'),
                                                                  Icon(Icons
                                                                      .download_rounded)
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        // ACTIVITIES
                                                        const Text(
                                                          'Activities:',
                                                          // style: TextStyle(
                                                          //   fontSize: 20,
                                                          // ),
                                                        ),
                                                        activities.isEmpty
                                                            ? const Text(
                                                                'No activities yet.')
                                                            : SizedBox(
                                                                height: 145,
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      activities
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          Card(
                                                                    child:
                                                                        ListTile(
                                                                      title: Text(
                                                                          'Activity ${index + 1} - ${activities[index]['activityTitle']}'),
                                                                      subtitle:
                                                                          Text(
                                                                              'Type: ${activities[index]['activityType']}'),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                        const Gap(5),

                                                        // ADDITIONAL RESOURCES
                                                        const Text(
                                                          'Additional Resources:',
                                                          // style: TextStyle(
                                                          //   fontSize: 20,
                                                          // ),
                                                        ),
                                                        additionalResources
                                                                .isEmpty
                                                            ? const Text(
                                                                'Empty.')
                                                            : SizedBox(
                                                                height: 145,
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      additionalResources
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          Card(
                                                                    child:
                                                                        ListTile(
                                                                      title: Text(
                                                                          additionalResources[index]
                                                                              [
                                                                              'resourceName']),
                                                                      subtitle:
                                                                          Text(
                                                                              'Type: ${additionalResources[index]['resourceTitle']}'),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
