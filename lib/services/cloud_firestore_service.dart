import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/services/error_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class CloudFirestoreService {
  final _firestore = FirebaseFirestore.instance;

  // SERVICES
  final _storageService = FirebaseStorageService();
  final _errorService = ErrorService();

  // --- INSTRUCTOR FUNCTIONS ---

  Future<void> addCourseOutline(
    BuildContext context,
    String selectedCourse,
    String userId,
    String fileName,
    Uint8List fileBytes,
  ) async {
    // QUERY EXISTING COURSE OUTLINES WITH THE SAME SELECTED COURSE CODE AND INSTRUCTOR ID
    final querySnapshot = await _firestore
        .collection('courses')
        .where('courseCode', isEqualTo: selectedCourse)
        .where('instructorId', isEqualTo: userId)
        .get();

    // DETERMINE VERSION NUMBER
    int newVersion = 1;
    if (querySnapshot.docs.isNotEmpty) {
      final versions = querySnapshot.docs.map((doc) {
        return doc['version'] ?? 1; // DEFAULT TO VERSION 1 IF NOT SET
      }).toList();
      newVersion = versions.reduce((a, b) => a > b ? a : b) + 1;
    }

    final fullPath = await _storageService.uploadFile(
      'courses/files/',
      fileName,
      fileBytes,
    );

    await _firestore.collection('courses').add({
      'syllabus': fullPath,
      'courseCode': selectedCourse,
      'instructorId': userId,
      'version': newVersion,
      'lessons': [],
      'timeStamp': FieldValue.serverTimestamp(),
      'files': [fullPath]
    }).then((_) {
      final tempSelectedCourse =
          courseList.firstWhere((element) => element.code == selectedCourse);

      _errorService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        '${tempSelectedCourse.code} - ${tempSelectedCourse.title} Course Outline Successfully Added!',
      );
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCourseData(
    String courseId,
  ) async {
    return await _firestore.collection('courses').doc(courseId).get();
  }

  Future<void> deleteCourseOutline(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete().then((_) {
        _errorService.showBanner(
          // ignore: use_build_context_synchronously
          context,
          '$courseTitle Successfully Deleted.',
        );
      });
    } on FirebaseException catch (e) {
      _errorService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        'There was an error deleting $courseTitle in Firestore: $e.',
      );
    }
  }

  Future<void> addToFiles(String courseId, String fullPath) async {
    await _firestore.collection('courses').doc(courseId).update({
      'files': FieldValue.arrayUnion([fullPath]),
    });
  }

  Future<void> addLesson({
    BuildContext? context,
    String? courseId,
    String? lessonTitle,
    String? lessonDescription,
    String? fileName,
    Uint8List? fileBytes,
    int? insertAtIndex,
  }) async {
    try {
      final learningMaterialPath = await _storageService.uploadFile(
        'courses/files/',
        fileName!,
        fileBytes!,
      );

      await addToFiles(courseId!, learningMaterialPath);

      if (insertAtIndex == null) {
        await _firestore.collection('courses').doc(courseId).update({
          'lessons': FieldValue.arrayUnion([
            {
              'title': lessonTitle,
              'description': lessonDescription,
              'learningMaterial': learningMaterialPath,
              'additionalResources': [],
            }
          ])
        }).then((_) {
          _errorService.showBanner(
            // ignore: use_build_context_synchronously
            context!,
            '$lessonTitle Successfully Added.',
          );
        });
      } else {
        final documentReference =
            _firestore.collection('courses').doc(courseId);

        await _firestore.runTransaction((transaction) async {
          // READ CURRENT DATA
          final snapshot = await transaction.get(documentReference);

          // GET CURRENT ARRAY
          List<dynamic> lessons = snapshot.get('lessons');

          // INSERT NEW LESSON AT SPECIFIED INDEX
          lessons.insert(
            insertAtIndex,
            {
              'title': lessonTitle,
              'description': lessonDescription,
              'learningMaterial': learningMaterialPath,
              'additionalResources': [],
            },
          );

          // UPDATE THE ARRAY
          transaction.update(documentReference, {'lessons': lessons});
        }).then((_) {
          _errorService.showBanner(
            // ignore: use_build_context_synchronously
            context!,
            '$lessonTitle Successfully Added before Lesson ${insertAtIndex + 1}',
          );
        });
      }
    } on FirebaseException catch (e) {
      _errorService.showBanner(
        // ignore: use_build_context_synchronously
        context!,
        'There was an error adding $lessonTitle in Firestore: $e.',
      );
    }
  }

  Future<void> deleteLesson(
    BuildContext context,
    String courseId,
    Map<String, dynamic> lesson,
  ) async {
    try {
      // REMOVE FROM COURSE FILES
      await _firestore.collection('courses').doc(courseId).update({
        'files': FieldValue.arrayRemove([lesson['learningMaterial']])
      }).then((_) async {
        // REMOVE FROM STORAGE
        await _storageService
            .deleteFile([lesson['learningMaterial']]).then((_) async {
          // DELETE FROM LESSONS
          await _firestore.collection('courses').doc(courseId).update({
            'lessons': FieldValue.arrayRemove([lesson])
          }).then((_) {
            _errorService.showBanner(
              // ignore: use_build_context_synchronously
              context,
              '${lesson['title']} has been successfully deleted.',
            );
          });
        });
      });
    } on FirebaseException catch (ex) {
      _errorService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        'An error occured while trying to delete ${lesson['title']}: $ex',
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCourses(
      String instructorId) async {
    return await _firestore
        .collection('courses')
        .where('instructorId', isEqualTo: instructorId)
        .get();
  }

  String generateUniqueCode() {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        5,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  Future<void> createClass(
    BuildContext context,
    String courseId,
    String instructorId,
    String year,
    String block,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // GET INSTRUCTOR DATA
    await _firestore.collection('users').doc(instructorId).get().then(
      (instructorData) async {
        // GET INSTRUCTOR INITIALS
        final firstNameInitial = instructorData['firstName'][0];
        final lastNameInitial = instructorData['lastName'][0];

        // CHECK IF CLASS CODE IS UNIQUE
        bool classCodeOk = false;
        String classCode = '';

        while (!classCodeOk) {
          // GENERATE UNIQUE 5 DIGIT CODE
          final uniqueCode = generateUniqueCode();

          // SET CLASS CODE
          classCode = '$firstNameInitial$lastNameInitial-$uniqueCode';

          await _firestore
              .collection('classes')
              .doc(classCode)
              .get()
              .then((checkClass) {
            if (!checkClass.exists) {
              classCodeOk = true;
            }
          });
        }

        if (classCodeOk) {
          // FETCH LESSONS
          await _firestore.collection('courses').doc(courseId).get().then(
            (courseData) async {
              final lessons = courseData['lessons'];
              final deadlines = List<dynamic>.generate(
                lessons.length,
                (index) => false,
              );

              final courseCode = courseData['courseCode'];
              // USE THE CODE AS THE ID FOR THE DOCUMENT
              await _firestore.collection('classes').doc(classCode).set({
                'courseId': courseId,
                'instructorId': instructorId,
                'year': year,
                'block': block,
                'startDate': startDate,
                'endDate': endDate,
                'deadlines': deadlines,
                'students': [],
              }).then(
                (_) {
                  // POP THE LOADING
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();

                  return QuickAlert.show(
                    // ignore: use_build_context_synchronously
                    context: context,
                    type: QuickAlertType.success,
                    title: '$courseCode - IT $year$block Successfully Created!',
                    onConfirmBtnTap: () {
                      // POP THE SUCCESS
                      Navigator.of(context).pop();
                      // POP THE MODAL
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getInstructorClasses(
      String instructorId) {
    return _firestore
        .collection('classes')
        .where('instructorId', isEqualTo: instructorId)
        .snapshots();
  }

  // --- STUDENT FUNCTIONS ---

  Future<void> joinClass(
      BuildContext context, String classCode, String studentId) async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
      );

      await _firestore.collection('classes').doc(classCode).update({
        'students': FieldValue.arrayUnion([studentId])
      }).then((_) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.success,
          title: 'Successfully joined the class!',
          onConfirmBtnTap: () {
            // POP THE SUCCESS MODAL
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      });
    } on FirebaseException catch (ex) {
      _errorService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        'Unable to join class due to error: $ex',
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStudentClasses(
      String studentId) {
    return _firestore
        .collection('classes')
        .where('students', arrayContains: studentId)
        .snapshots();
  }
}
