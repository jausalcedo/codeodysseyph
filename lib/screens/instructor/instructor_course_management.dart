import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:codeodysseyph/components/instructor/instructor_drawer.dart';
import 'package:flutter/material.dart';

class InstructorCourseManagementScreen extends StatelessWidget {
  const InstructorCourseManagementScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: InstructorDrawer(userId: userId),
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: InstructorAppbar(),
      ),
    );
  }
}
