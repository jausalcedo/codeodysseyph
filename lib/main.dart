import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/firebase_options.dart';
import 'package:codeodysseyph/screens/auth/login.dart';
import 'package:codeodysseyph/screens/auth/verification.dart';
import 'package:codeodysseyph/screens/instructor/instructor_dashboard.dart';
import 'package:codeodysseyph/screens/student/student_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CodeOdyssey());
}

class CodeOdyssey extends StatelessWidget {
  const CodeOdyssey({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
    );
  }
}

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
                  return InstructorDashboardScreen(userId: userId);
                } else if (accountType == 'Student') {
                  return StudentDashboardScreen(userId: userId);
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
