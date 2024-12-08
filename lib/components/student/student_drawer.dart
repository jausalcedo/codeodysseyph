import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/student/student_codeplayground.dart';
import 'package:codeodysseyph/screens/student/student_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StudentDrawer extends StatefulWidget {
  const StudentDrawer({super.key, required this.studentId});

  final String studentId;

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  void openDashboardScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            StudentDashboardScreen(studentId: widget.studentId),
      ),
    );
  }

  void openCodePlaygroundScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentCodePlayground(userId: widget.studentId),
      ),
    );
  }

  void openDailyChallengeScreen() {
    // TO DO
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

          // DAILY CHALLENGE
          ListTile(
            onTap: openDailyChallengeScreen,
            leading: const Icon(
              Icons.lightbulb_rounded,
              color: primary,
            ),
            title: const Text(
              'Daily Challenge',
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
