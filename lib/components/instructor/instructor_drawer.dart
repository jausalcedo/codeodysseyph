import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/instructor/instructor_course_management.dart';
import 'package:codeodysseyph/screens/instructor/instructor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InstructorDrawer extends StatefulWidget {
  const InstructorDrawer({super.key, required this.userId});

  final String userId;

  @override
  State<InstructorDrawer> createState() => _InstructorDrawerState();
}

class _InstructorDrawerState extends State<InstructorDrawer> {
  void openDashboardScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorDashboardScreen(userId: widget.userId),
      ),
    );
  }

  void openCodePlaygroundScreen() {
    // TO DO
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => StudentCodePlayground(userId: widget.userId),
    //   ),
    // );
  }

  void openCourseManagementScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            InstructorCourseManagementScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const Gap(50),
          // MENU
          const Row(
            children: [
              Gap(20),
              Text(
                'Menu',
                style: TextStyle(
                  color: primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(50),

          // STUDY AREA
          ListTile(
            onTap: openDashboardScreen,
            leading: const Icon(
              Icons.school_rounded,
              color: primary,
            ),
            title: const Text(
              'Study Area',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
          const Gap(20),

          // CODE PLAYGROUND
          ListTile(
            onTap: openCodePlaygroundScreen,
            leading: const Icon(
              Icons.code_rounded,
              color: primary,
            ),
            title: const Text(
              'Code Playground',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
          const Gap(20),

          // COURSE MANAGEMENT
          ListTile(
            onTap: openCourseManagementScreen,
            leading: const Icon(
              Icons.library_books_rounded,
              color: primary,
            ),
            title: const Text(
              'Course Management',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
