import 'package:codeodysseyph/components/instructor/instructor_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    TextEditingController fname = TextEditingController();
    TextEditingController lname = TextEditingController();

    void showModal() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.only(top: 20, bottom: 0),
            title: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  right: 0.0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF132763),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Gap(10),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: fname,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const Gap(20),
                      SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: lname,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print(fname.text);
                    print(lname.text);

                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      text:
                          'Profile information has been updated successfully!',
                      confirmBtnText: 'OK',
                      onConfirmBtnTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A76F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          const Gap(30),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              width: screenWidth * 0.5,
              height: screenHeight * 0.5,
              child: Column(
                children: [
                  const Gap(30),
                  const Text(
                    "My Profile",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  const Gap(20),
                  const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF132763),
                      child: Text(
                        "JS",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      )),
                  const Gap(8),
                  const Text(
                    "Jau Salcedo",
                    style: TextStyle(fontSize: 26),
                  ),
                  const Gap(2),
                  const Text(
                    "jau@gmail.com",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(0, 0, 0, .5),
                    ),
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showModal();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 19, 27, 99),
                        ),
                        child: const Text(
                          "Edit",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                      const Gap(4),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.key,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 19, 27, 99),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 75),
        child: InstructorAppbar(userId: userId, goBackToClass: null),
      ),
    );
  }
}
