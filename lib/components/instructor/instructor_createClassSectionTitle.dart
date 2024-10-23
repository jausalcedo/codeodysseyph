import 'package:codeodysseyph/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CreateClassSectionTitle extends StatelessWidget {
  const CreateClassSectionTitle({
    super.key,
    required this.number,
    required this.sectionTitle,
  });

  final String number;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: primary,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Gap(10),
        Text(
          sectionTitle,
          style: const TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
