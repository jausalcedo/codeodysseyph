import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/screens/student/student_profile.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StudentAppbar extends StatelessWidget {
  StudentAppbar({super.key});

  final authService = AuthService();

  void openProfileScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StudentProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      backgroundColor: Colors.white,
      shape: const Border.symmetric(
        horizontal: BorderSide(color: Colors.black87),
      ),
      title: Image.asset(
        'assets/images/Logo - Long Row.png',
        height: 100,
      ),
      actions: [
        const Icon(
          Icons.notifications_rounded,
          size: 30,
        ),
        const Gap(25),
        const TextButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(secondary),
              foregroundColor: WidgetStatePropertyAll(Colors.white)),
          onPressed: null,
          child: Text(
            'Student',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Gap(25),
        MenuAnchor(
          alignmentOffset: const Offset(-70, 7),
          builder: (context, controller, child) {
            return IconButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(primary),
                  foregroundColor: WidgetStatePropertyAll(Colors.white)),
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              tooltip: 'Menu',
              icon: const Icon(Icons.person_rounded),
            );
          },
          menuChildren: [
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(secondary),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    shape: WidgetStatePropertyAll(ContinuousRectangleBorder())),
                onPressed: () => openProfileScreen(context),
                label: const Text('Profile'),
                icon: const Icon(Icons.person_rounded),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(cRed),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    shape: WidgetStatePropertyAll(ContinuousRectangleBorder())),
                onPressed: authService.signOut,
                label: const Text('Logout'),
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
          ],
        ),
        const Gap(25),
      ],
    );
  }
}