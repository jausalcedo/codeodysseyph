import 'package:codeodysseyph/services/auth_service.dart';
import 'package:flutter/material.dart';

class InstructorDashboardScreen extends StatelessWidget {
  InstructorDashboardScreen({super.key, required this.userId});

  final String userId;
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: authService.signOut,
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      
    );
  }
}