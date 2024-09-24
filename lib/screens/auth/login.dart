import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/auth/signup_general.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isObscured = true;

  void login() async {
    // VALIDATE EMAIL AND PASSWORD
    if (!formKey.currentState!.validate()) {
      return;
    }

    // TO ADD: SHOW LOADING
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    final authService = AuthService();

    // FIREBASE SIGN IN
    try {
      await authService.signInWithEmailPassword(email.text, password.text);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (ex) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      String errorTitle = 'Login Error';
      String errorText = 'An unknown error occured. Please try again later.';

      if (ex.toString().contains('invalid-credential')) {
        errorTitle = 'Invalid Login Credentials';
        errorText = 'Please check your email and/or password.';
      }

      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        title: errorTitle,
        text: errorText,
        type: QuickAlertType.error,
        confirmBtnColor: Colors.grey[800]!,
        confirmBtnText: 'Try again.',
      );
    }
  }

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

              // LOGIN FORM
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
                        children: [
                          // WELCOME MESSAGE
                          const Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text('Please enter your login details...'),
                          const Gap(25),

                          // EMAIL FIELD
                          TextFormField(
                            controller: email,
                            decoration: const InputDecoration(
                              label: Text('Email'),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Please enter a valid email.';
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
                                      BorderRadius.all(Radius.circular(10))),
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
                                return 'Please enter your password.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),

                          // LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: TextButton(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(primary),
                                  foregroundColor:
                                      WidgetStatePropertyAll(Colors.white)),
                              onPressed: login,
                              child: const Text('Login'),
                            ),
                          ),
                          const Gap(25),

                          // GO TO SIGNUP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Need an account?'),
                              const Gap(5),
                              GestureDetector(
                                onTap: () => openSignupScreen(context),
                                child: const Text(
                                  'Signup here!',
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
