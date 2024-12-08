import 'dart:async';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/auth/auth_checker.dart';
import 'package:codeodysseyph/screens/student/student_dashboard.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class StudentVerificationScreen extends StatefulWidget {
  const StudentVerificationScreen({super.key, required this.userId});

  final String userId;

  @override
  State<StudentVerificationScreen> createState() =>
      _StudentVerificationScreenState();
}

class _StudentVerificationScreenState extends State<StudentVerificationScreen> {
  final _authService = AuthService();

  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = _authService.emailVerified();

    if (!isEmailVerified) {
      timer = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  Future checkEmailVerified() async {
    await _authService.reload();

    setState(() {
      isEmailVerified = _authService.emailVerified();
    });

    if (isEmailVerified) timer?.cancel();
  }

  void sendVerificationEmail() async {
    try {
      final user = _authService.getCurrentUser()!;
      await user.sendEmailVerification();
    } catch (e) {
      QuickAlert.show(
        title: 'An Error Occured',
        text: e.toString(),
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
      );
    }
  }

  void goToLoginScreen() {
    _authService.signOut();
    print('Logout Clicked');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AuthChecker(),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? StudentDashboardScreen(studentId: widget.userId)
      : Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: [
              // BACKGROUND GRADIENT
              Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff0A2353),
                      Color(0xff122C71),
                      Color(0xff56E1E9)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // CONTAINER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15)),
                    child: Container(
                      color: Colors.white,
                      height: 600,
                      width: 420,
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Image.asset('assets/images/Logo - Square.png'),
                      ),
                    ),
                  ),

                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                    child: Container(
                      color: const Color(0xffCECFDD),
                      height: 600,
                      width: 420,
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.mark_email_read_rounded,
                              size: 80,
                              color: primary,
                            ),
                            const Gap(15),
                            const Text(
                              'Verify Email',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              "A verification email has been sent to your email. Kindly check your inbox/spam folder.",
                              textAlign: TextAlign.center,
                            ),
                            const Gap(25),
                            // RESEND EMAIL BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: TextButton(
                                style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(primary),
                                  foregroundColor:
                                      WidgetStatePropertyAll(Colors.white),
                                ),
                                onPressed: sendVerificationEmail,
                                child: const Text('Resend email'),
                              ),
                            ),
                            const Gap(15),
                            // BACK TO LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: TextButton(
                                style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.white),
                                  foregroundColor:
                                      WidgetStatePropertyAll(primary),
                                ),
                                onPressed: goToLoginScreen,
                                child: const Text('Back to Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
}
