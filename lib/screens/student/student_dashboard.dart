import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatelessWidget {
  StudentDashboardScreen({super.key, required this.userId});

  final String userId;

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: StudentAppbar(),
      ),
    );
  }
}
