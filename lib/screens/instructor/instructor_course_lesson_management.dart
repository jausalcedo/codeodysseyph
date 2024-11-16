import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';

class InstructorCourseLessonManagement extends StatelessWidget {
  const InstructorCourseLessonManagement({
    super.key,
    required this.courseId,
  });

  final String courseId;

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
              .doc(courseId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final courseData = snapshot.data!.data();

            final course = courseList.firstWhere(
                (course) => course.code == courseData!['courseCode']);

            final String rawSyllabusName =
                courseData!['syllabus'].split('/').last;

            final syllabusName = extractSyllabusName(rawSyllabusName);

            return Center(
              child: SizedBox(
                width: 1050,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // COURSE NAME
                        Text(
                          '${course.code} - ${course.title} v${courseData['version']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // SYLLABUS NAME
                        Text('Syllabus: $syllabusName'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
