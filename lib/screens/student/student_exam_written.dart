import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:flutter/material.dart';

class StudentLaboratoryExamScreen extends StatefulWidget {
  const StudentLaboratoryExamScreen({super.key});

  @override
  State<StudentLaboratoryExamScreen> createState() =>
      _StudentLaboratoryExamScreenState();
}

class _StudentLaboratoryExamScreenState
    extends State<StudentLaboratoryExamScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: StudentAppbar(),
      ),
    );
  }
}
