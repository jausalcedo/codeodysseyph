import 'package:codeodysseyph/firebase_options.dart';
import 'package:codeodysseyph/screens/auth/auth_checker.dart';
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
