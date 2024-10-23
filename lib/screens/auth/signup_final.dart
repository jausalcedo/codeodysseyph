import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/auth/auth_checker.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class SignupFinalScreen extends StatefulWidget {
  const SignupFinalScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  State<SignupFinalScreen> createState() => _SignupFinalScreenState();
}

class _SignupFinalScreenState extends State<SignupFinalScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final university = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String? accountType;

  final defaultButtonStyle = const ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    foregroundColor: WidgetStatePropertyAll(Colors.black54),
  );

  final selectedButtonStyle = const ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    foregroundColor: WidgetStatePropertyAll(primary),
    side: WidgetStatePropertyAll(
      BorderSide(
        color: primary,
        width: 3,
      ),
    ),
  );

  void signup() async {
    // VALIDATE NAME
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (accountType == null || accountType!.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Please select your account type.',
      );
      return;
    }

    print('${widget.email} : ${widget.password}');
    print('${firstName.text} ${lastName.text}, $accountType');

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
    );

    final authService = AuthService();

    try {
      UserCredential user = await authService.createUserWithEmailPassword(
        widget.email,
        widget.password,
      );

      String userId = user.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userId': userId,
        'email': widget.email,
        'accountType': accountType,
        'firstName': firstName.text,
        'lastName': lastName.text,
      });

      // POP THE LOADING MODAL
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      try {
        final user = authService.getCurrentUser()!;
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

      // SIGNOUT THE USER IN ORDER TO LOGIN AGAIN
      FirebaseAuth.instance.signOut();

      // SUCCESS MESSAGE
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.success,
        title: 'Signup Successful!',
        text:
            'A confirmation email has been sent to the email address you\'ve provided. Please check your email and verify your account to continue.',
        confirmBtnColor: Colors.grey[800]!,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();

          // GO TO LOGIN
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AuthChecker(),
            ),
          );
        },
      );
    } catch (ex) {
      // POP THE LOADING MODAL
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      String errorTitle = 'Signup Error';
      String errorText = 'An unknown error occurred. Please try again.';

      if (ex.toString().contains('email-already-in-use')) {
        errorTitle = 'Email Already in Use';
        errorText = 'Please use a different email.';
      }

      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: errorTitle,
        text: errorText,
        confirmBtnColor: Colors.grey[800]!,
        confirmBtnText: 'Try again.',
      );
    }
  }

  void goToLoginScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AuthChecker(),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50.0,
                      vertical: 20,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),

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
                              child: Text('Just a few more things...')),
                          const Gap(15),

                          // BREADCRUMBS
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: Colors.black38,
                              ),
                              Gap(15),
                              CircleAvatar(
                                radius: 7,
                                backgroundColor: primary,
                              )
                            ],
                          ),
                          const Gap(15),

                          // ACCOUNT TYPE TEXT
                          const Text(
                            'Account Type',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Gap(10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // INSTRUCTOR TYPE BUTTON
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        accountType = 'Instructor';
                                      });
                                    },
                                    style: accountType != 'Instructor'
                                        ? defaultButtonStyle
                                        : selectedButtonStyle,
                                    icon: const Icon(Icons.school_rounded),
                                    label: const Text('Instructor'),
                                  ),
                                ),
                              ),

                              const Gap(25),

                              // STUDENT TYPE BUTTON
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        accountType = 'Student';
                                      });
                                    },
                                    style: accountType != 'Student'
                                        ? defaultButtonStyle
                                        : selectedButtonStyle,
                                    icon: const Icon(Icons.person_rounded),
                                    label: const Text('Student'),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const Gap(15),

                          // ACCOUNT INFORMATION TEXT
                          const Text(
                            'Personal Information',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Gap(10),

                          // FIRST NAME FIELD
                          TextFormField(
                            controller: firstName,
                            decoration: const InputDecoration(
                              label: Text('First Name'),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required. Please enter your first name.';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),

                          // LAST NAME FIELD
                          TextFormField(
                            controller: lastName,
                            decoration: const InputDecoration(
                              label: Text('Last Name'),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required. Please enter your last name.';
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
                              onPressed: signup,
                              child: const Text('Signup'),
                            ),
                          ),
                          const Gap(25),
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
