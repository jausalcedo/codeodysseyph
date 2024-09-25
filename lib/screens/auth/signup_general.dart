import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/main.dart';
import 'package:codeodysseyph/screens/auth/signup_final.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SignupGeneralScreen extends StatefulWidget {
  const SignupGeneralScreen({super.key});

  @override
  State<SignupGeneralScreen> createState() => _SignupGeneralScreenState();
}

class _SignupGeneralScreenState extends State<SignupGeneralScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final cPassword = TextEditingController();

  bool isObscured = true;

  final formKey = GlobalKey<FormState>();

  void goToLoginScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AuthChecker(),
      ),
    );
  }

  void goToFinalSignupScreen() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SignupFinalScreen(
        email: email.text,
        password: password.text,
      ),
    ));
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

              // SIGNUP FORM
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
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // WELCOME MESSAGE
                          const Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Center(
                              child: Text('Please enter your account details')),
                          const Gap(15),

                          // BREADCRUMBS
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 7,
                                backgroundColor: primary,
                              ),
                              Gap(15),
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: Colors.black38,
                              )
                            ],
                          ),
                          const Gap(15),

                          // ACCOUNT INFORMATION TEXT
                          const Text(
                            'Account Information',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Gap(10),

                          // EMAIL FIELD
                          TextFormField(
                            controller: email,
                            decoration: const InputDecoration(
                              label: Text('Email'),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required. Please enter an email address.';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),

                          // PASSWORD FIELD
                          TextFormField(
                            controller: password,
                            obscureText: isObscured,
                            decoration: InputDecoration(
                              label: const Text('Password'),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isObscured = !isObscured;
                                  });
                                },
                                icon: Icon(isObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required. Please enter your password.';
                              }
                              if (value.length < 8) {
                                return 'Please use a password with at least 8 characters.';
                              }
                              if (value != cPassword.text) {
                                return 'Passwords MUST match.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),

                          // CONFIRM PASSWORD FIELD
                          TextFormField(
                            controller: cPassword,
                            obscureText: isObscured,
                            decoration: const InputDecoration(
                              label: Text('Confirm Password'),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required. Please confirm your password.';
                              }
                              if (value != password.text) {
                                return 'Passwords MUST match.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),

                          // NEXT BUTTON
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
                              onPressed: goToFinalSignupScreen,
                              child: const Text('Next'),
                            ),
                          ),
                          const Gap(25),

                          // GO TO LOGIN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?'),
                              const Gap(5),
                              GestureDetector(
                                onTap: goToLoginScreen,
                                child: const Text(
                                  'Login here!',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
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
