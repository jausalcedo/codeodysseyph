import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/screens/instructor/instructor_add_lesson.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InstructorCourseLessonManagement extends StatefulWidget {
  const InstructorCourseLessonManagement({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<InstructorCourseLessonManagement> createState() =>
      _InstructorCourseLessonManagementState();
}

class _InstructorCourseLessonManagementState
    extends State<InstructorCourseLessonManagement> {
  String extractSyllabusName(String syllabusWithTimeStamp) {
    final splitted = syllabusWithTimeStamp.split('-');

    String finalSyllabusName = '';

    for (int i = 1; i < splitted.length; i++) {
      if (i != splitted.length - 1) {
        finalSyllabusName += '${splitted[i]}-';
      } else {
        finalSyllabusName += splitted[i];
      }
    }

    return finalSyllabusName;
  }

  void goToAddLessonScreen(String courseId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorAddLessonScreen(courseId: courseId),
      ),
    );
  }

  Uint8List? lessonFileBytes;
  String? lessonFileName;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      // allowedExtensions: ['pdf', 'pptx', 'ppt'],
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        lessonFileBytes = result.files.first.bytes;
        lessonFileName = result.files.first.name;
      });
    }
  }

  String activityType = 'Multiple Choice';
  final questionController = TextEditingController();
  final choiceControllers = List.generate(4, (_) => TextEditingController());
  final correctAnswerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size(double.infinity, 75),
          child: InstructorAppbar(),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final courseData = snapshot.data!.data();

            final course = courseList.firstWhere(
                (course) => course.code == courseData!['courseCode']);

            // final String rawSyllabusName =
            //     courseData!['syllabus'].split('/').last;

            // final syllabusName = extractSyllabusName(rawSyllabusName);

            final lessonList = courseData!['lessons'];

            return Center(
              child: SizedBox(
                width: 1050,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // COURSE OUTLINE INFO
                          Text(
                            '${course.code} - ${course.title} v${courseData['version']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // TITLE
                              const Text(
                                'Lessons',
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                              // ADD LESSON BUTTON
                              TextButton.icon(
                                onPressed: () =>
                                    goToAddLessonScreen(widget.courseId),
                                label: const Text('Add New Lesson'),
                                icon: const Icon(Icons.add_rounded),
                                style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(primary),
                                  foregroundColor:
                                      WidgetStatePropertyAll(Colors.white),
                                ),
                              )
                            ],
                          ),

                          // LESSONS FUTURE BUILDER
                          lessonList.length == 0
                              ? const Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                            'You haven\'t added a lesson yet. Click the button above to add your first lesson!'),
                                      ),
                                    ],
                                  ),
                                )
                              : Expanded(
                                  child: ListView.builder(
                                    itemCount: lessonList.length,
                                    itemBuilder: (context, index) => Card(
                                      child: ListTile(
                                        title: Text(
                                            'Lesson ${index + 1}: ${lessonList[index]['title']}'),
                                      ),
                                    ),
                                  ),
                                )
                        ],
                      )),
                ),
              ),
            );
          },
        ));
  }
}
