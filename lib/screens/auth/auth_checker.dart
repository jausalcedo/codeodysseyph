import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/screens/auth/instructor_verification.dart';
import 'package:codeodysseyph/screens/auth/login.dart';
import 'package:codeodysseyph/screens/auth/student_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          String userId = snapshot.data!.uid;

          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                String accountType = snapshot.data!.data()!['accountType'];

                if (accountType == 'Instructor') {
                  return InstructorVerificationScreen(userId: userId);
                } else if (accountType == 'Student') {
                  return StudentVerificationScreen(userId: userId);
                }
              }

              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
