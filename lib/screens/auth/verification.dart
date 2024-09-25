import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/auth/signup_general.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  void openSignupScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupGeneralScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Icon(
                          Icons.email,
                          size: 80,
                          color: Color.fromARGB(255, 19, 27, 99),
                        ),
                        Gap(15),
                        const Text(
                          'Verify your email',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                            "We've sent you an email verification. \nPlease check your inbox/spam folder."),
                        const Gap(25),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: TextButton(
                            //resend email button
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(primary),
                                foregroundColor:
                                    WidgetStatePropertyAll(Colors.white)),
                            onPressed: () {},
                            child: const Text('Resend email'),
                          ),
                        ),
                        const Gap(25),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: TextButton(
                            // back to login button
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.white),
                                foregroundColor:
                                    WidgetStatePropertyAll(primary)),
                            onPressed: () {},
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
}
