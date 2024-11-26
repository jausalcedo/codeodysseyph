import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/screens/instructor/instructor_add_lesson.dart';
import 'package:codeodysseyph/services/cloud_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

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

  // SERVICES
  final firestoreService = CloudFirestoreService();

  Future<void> deleteLesson(Map<String, dynamic> lesson) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Confirm Delete?\n${lesson['title']}',
      text: 'This action cannot be undone.',
      confirmBtnText: 'Delete',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        // DISMISS CONFIRM BUTTON
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        // SHOW LOADING
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
        );

        await firestoreService
            .deleteLesson(context, widget.courseId, lesson)
            .then((_) {
          // DISMISS LOADING MODAL
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        });
      },
      showCancelBtn: true,
      cancelBtnText: 'Cancel',
      onCancelBtnTap: Navigator.of(context).pop,
    );
  }

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

                          // LESSONS LISTVIEW
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
                                        trailing: IconButton(
                                          onPressed: () =>
                                              deleteLesson(lessonList[index]),
                                          icon: const Icon(
                                            Icons.delete_rounded,
                                            color: Colors.red,
                                          ),
                                        ),
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
