import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/services/alert_service.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class CloudFirestoreService {
  final _firestore = FirebaseFirestore.instance;

  // SERVICES
  final _storageService = FirebaseStorageService();
  final _alertService = AlertService();

  // --- GENERAL USER FUNCTIONS ---
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData({
    required String userId,
  }) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // --- INSTRUCTOR FUNCTIONS ---

  Future<void> createCourseOutline(
    BuildContext context,
    String selectedCourse,
    String userId,
    // String fileName,
    // Uint8List fileBytes,
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

    await _firestore.collection('courses').add({
      'courseCode': selectedCourse,
      'instructorId': userId,
      'version': newVersion,
      'lessons': [],
      'lastUpdated': FieldValue.serverTimestamp(),
      'timeStamp': FieldValue.serverTimestamp(),
      'files': [],
    }).then((_) {
      final tempSelectedCourse =
          courseList.firstWhere((element) => element.code == selectedCourse);

      _alertService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        '${tempSelectedCourse.code} - ${tempSelectedCourse.title} Course Outline Successfully Added!',
      );
    });
  }

  Future<void> createCourseOutlineFromTemplate(
    BuildContext context,
    String selectedCourse,
    String instructorId,
    String templateId,
  ) async {
    // FETCH TEMPLATE COURSE OUTLINE
    await _firestore
        .collection('courses')
        .doc(templateId)
        .get()
        .then((courseOutline) async {
      final tempCourseCode = courseOutline['courseCode'];
      final tempLessons = courseOutline['lessons'];
      final tempFiles = courseOutline['files'];

      // QUERY EXISTING COURSE OUTLINES WITH THE SAME SELECTED COURSE CODE AND INSTRUCTOR ID
      final querySnapshot = await _firestore
          .collection('courses')
          .where('courseCode', isEqualTo: selectedCourse)
          .where('instructorId', isEqualTo: instructorId)
          .get();

      // DETERMINE VERSION NUMBER
      int newVersion = 1;
      if (querySnapshot.docs.isNotEmpty) {
        final versions = querySnapshot.docs.map((doc) {
          return doc['version'] ?? 1; // DEFAULT TO VERSION 1 IF NOT SET
        }).toList();
        newVersion = versions.reduce((a, b) => a > b ? a : b) + 1;
      }

      await _firestore.collection('courses').add({
        'courseCode': tempCourseCode,
        'instructorId': instructorId,
        'version': newVersion,
        'lessons': tempLessons,
        'lastUpdated': FieldValue.serverTimestamp(),
        'timeStamp': FieldValue.serverTimestamp(),
        'files': tempFiles,
      }).then((_) {
        final tempSelectedCourse =
            courseList.firstWhere((element) => element.code == selectedCourse);

        _alertService.showBanner(
          // ignore: use_build_context_synchronously
          context,
          '${tempSelectedCourse.code} - ${tempSelectedCourse.title} Course Outline Successfully Added!',
        );
      });
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCourseClassDataFuture(
    String collection,
    String courseIdClassCode,
  ) async {
    return await _firestore.collection(collection).doc(courseIdClassCode).get();
  }

  Future<void> deleteCourseOutline(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete().then((_) {
        _alertService.showBanner(
          // ignore: use_build_context_synchronously
          context,
          '$courseTitle Successfully Deleted.',
        );
      });
    } on FirebaseException catch (e) {
      _alertService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        'There was an error deleting $courseTitle in Firestore: $e.',
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCoursesFuture(
      String instructorId) async {
    return await _firestore
        .collection('courses')
        .where('instructorId', isEqualTo: instructorId)
        .orderBy('courseCode')
        .orderBy('timeStamp')
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getSimilarCoursesFuture(
      String instructorId, String courseCode) async {
    return await _firestore
        .collection('courses')
        .where('instructorId', isEqualTo: instructorId)
        .where('courseCode', isEqualTo: courseCode)
        .get();
  }

  Future<void> addToFiles(
      String collection, String documentId, String fullPath) async {
    await _firestore.collection(collection).doc(documentId).update({
      'files': FieldValue.arrayUnion([fullPath]),
    });
  }

  Future<void> addLesson({
    BuildContext? context,
    String? collection,
    String? documentId,
    String? lessonTitle,
    String? fileName,
    Uint8List? fileBytes,
    int? insertAtIndex,
  }) async {
    try {
      final learningMaterialPath = await _storageService.uploadFile(
        '$collection/files/',
        fileName!,
        fileBytes!,
      );

      await addToFiles(collection!, documentId!, learningMaterialPath);

      if (insertAtIndex == null) {
        await _firestore.collection(collection).doc(documentId).update({
          'lessons': FieldValue.arrayUnion([
            {
              'title': lessonTitle,
              'learningMaterial': learningMaterialPath,
              'additionalResources': [],
              'activities': [],
            }
          ]),
          'lastUpdated': FieldValue.serverTimestamp(),
        }).then((_) {
          _alertService.showBanner(
            // ignore: use_build_context_synchronously
            context!,
            '$lessonTitle Successfully Added.',
          );
        });
      } else {
        final documentReference =
            _firestore.collection(collection).doc(documentId);

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
              // 'description': lessonDescription,
              'learningMaterial': learningMaterialPath,
              'additionalResources': [],
              'activities': [],
            },
          );

          // UPDATE THE ARRAY
          transaction.update(documentReference, {
            'lessons': lessons,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }).then((_) {
          _alertService.showBanner(
            // ignore: use_build_context_synchronously
            context!,
            '$lessonTitle Successfully Added before Lesson ${insertAtIndex + 1}',
          );
        });
      }
    } on FirebaseException catch (e) {
      _alertService.showBanner(
        // ignore: use_build_context_synchronously
        context!,
        'There was an error adding $lessonTitle in Firestore: $e.',
      );
    }
  }

  Future<void> deleteLesson(
    BuildContext context,
    String collection,
    String courseId,
    Map<String, dynamic> lesson,
  ) async {
    try {
      // REMOVE FROM COURSE FILES
      await _firestore.collection(collection).doc(courseId).update({
        'files': FieldValue.arrayRemove([lesson['learningMaterial']])
      }).then((_) async {
        // REMOVE FROM STORAGE
        await _storageService
            .deleteFile([lesson['learningMaterial']]).then((_) async {
          // DELETE FROM LESSONS
          await _firestore.collection('courses').doc(courseId).update({
            'lessons': FieldValue.arrayRemove([lesson]),
            'lastUpdated': FieldValue.serverTimestamp(),
          }).then((_) {
            _alertService.showBanner(
              // ignore: use_build_context_synchronously
              context,
              '${lesson['title']} has been successfully deleted.',
            );
          });
        });
      });
    } on FirebaseException catch (ex) {
      _alertService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        'An error occured while trying to delete ${lesson['title']}: $ex',
      );
    }
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

  Future<bool> noDuplicateClass({
    required String courseCode,
    required String year,
    required String block,
    required int academicYear,
    required String semester,
  }) async {
    final classData = await _firestore
        .collection('classes')
        .where('courseCode', isEqualTo: courseCode)
        .where('year', isEqualTo: year)
        .where('block', isEqualTo: block)
        .where('academicYear', isEqualTo: academicYear)
        .where('semester', isEqualTo: semester)
        .get();

    return classData.docs.isEmpty;
  }

  Future<void> createClass({
    required BuildContext context,
    required String courseId,
    required String instructorId,
    required String year,
    required String block,
    required int academicYear,
    required String semester,
  }) async {
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
          // FETCH COURSE OUTLINE
          await _firestore.collection('courses').doc(courseId).get().then(
            (courseData) async {
              final courseCode = courseData['courseCode'];
              final lessons = courseData['lessons'];
              final files = courseData['files'];

              // USE THE CODE AS THE ID FOR THE DOCUMENT
              await _firestore.collection('classes').doc(classCode).set({
                'courseCode': courseCode,
                'instructorId': instructorId,
                'lessons': lessons,
                'files': files,
                'year': year,
                'block': block,
                'academicYear': academicYear,
                'semester': semester,
                'timeStamp': FieldValue.serverTimestamp(),
                'students': [],
                'violations': {
                  'copyPaste': 10,
                  'changeView': 2.5,
                }
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

  Future<void> deleteClass({required String classCode}) async {
    await _firestore.collection('classes').doc(classCode).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getInstructorClassesStream(
      String instructorId) {
    return _firestore
        .collection('classes')
        .where('instructorId', isEqualTo: instructorId)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getClassDataStream(
      String classCode) {
    return _firestore.collection('classes').doc(classCode).snapshots();
  }

  Future<void> addActivityToLesson({
    required BuildContext context,
    required String instructorId,
    required String classCode,
    required int lessonIndex,
    required Map<String, dynamic> newActivity,
  }) async {
    // FETCH CLASS DATA
    final classSnapshot =
        await _firestore.collection('classes').doc(classCode).get();
    final classData = classSnapshot.data();

    final lessons = (classData?['lessons'] as List?) ?? [];
    if (lessonIndex >= lessons.length) {
      throw Exception('Invalid lesson index.');
    }

    final lesson = lessons[lessonIndex] as Map<String, dynamic>;
    newActivity.addAll({
      'submissions': {},
      'lessonTag': lesson['title'],
      'metaData': {
        'createdBy': instructorId,
        'dateCreated': DateTime.now(),
      },
    });

    // UPDATE ACTIVITIES
    final activities = (lesson['activities'] as List?) ?? [];
    activities.add(newActivity);
    lesson['activities'] = activities;
    lessons[lessonIndex] = lesson;

    // SAVE BACK TO FIRESTORE
    await _firestore
        .collection('classes')
        .doc(classCode)
        .update({'lessons': lessons});
  }

  Future<void> editActivityDetails({
    required String classCode,
    required int lessonIndex,
    required int activityIndex,
    dynamic activity,
  }) async {
    // TO DO
    final classSnapshot =
        await _firestore.collection('classes').doc(classCode).get();
    final classData = classSnapshot.data();

    final List lessons = classData!['lessons'];
    final List activities = lessons[lessonIndex]['activities'];

    activities[activityIndex] = activity;
    lessons[lessonIndex]['activities'] = activities;

    await _firestore
        .collection('classes')
        .doc(classCode)
        .update({'lessons': lessons});
  }

  Future<void> scoreActivity({
    required String classCode,
    required int lessonIndex,
    required int activityIndex,
    required String studentId,
    required double score,
  }) async {
    final classSnapshot =
        await _firestore.collection('classes').doc(classCode).get();
    final classData = classSnapshot.data();

    final List lessons = classData!['lessons'];
    final List activities = lessons[lessonIndex]['activities'];

    final activity = activities[activityIndex];

    Map<String, dynamic> submissions = activity['submissions'];

    Map<String, dynamic> submissionContent = submissions[studentId];

    submissionContent['score'] = score;

    submissions[studentId] = submissionContent;

    activity['submissions'] = submissions;
    activities[activityIndex] = activity;
    lessons[lessonIndex]['activities'] = activities;

    await _firestore
        .collection('classes')
        .doc(classCode)
        .update({'lessons': lessons});
  }

  Future<void> deleteActivityFromLesson({
    required BuildContext context,
    required String classCode,
    required int lessonIndex,
    required int activityIndex,
  }) async {
    try {
      final classSnapshot =
          await _firestore.collection('classes').doc(classCode).get();

      final List lessons = classSnapshot['lessons'];
      final List activities = lessons[lessonIndex]['activities'];

      activities.removeAt(activityIndex);

      lessons[lessonIndex]['activities'] = activities;

      await _firestore.collection('classes').doc(classCode).update({
        'lessons': lessons,
      }).then((_) {
        // DISMISS LOADING
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.success,
          title:
              'Lesson ${lessonIndex + 1} - Activity ${activityIndex + 1} Deleted Successfully!',
        );
      });
    } on FirebaseException catch (ex) {
      _alertService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        'Unable to delete activity due to error: $ex',
      );
    }
  }

  Future<void> addExamToClass({
    required BuildContext context,
    required String instructorId,
    required String classCode,
    required Map<String, dynamic> newExam,
  }) async {
    final examBankReference = _firestore.collection('examBank');
    // ADD METADATA
    newExam.addAll({
      'submissions': {},
      'metaData': {
        'createdBy': instructorId,
        'dateCreated': DateTime.now(),
      },
    });

    // ADD TO FIRESTORE
    await _firestore.collection('classes').doc(classCode).update({
      'exams': FieldValue.arrayUnion([newExam]),
    }).then((_) async {
      // ADD TO TEST BANK
      await examBankReference.add(newExam);

      // POP THE LOADING
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // DISPLAY SUCCESS
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.success,
        title: 'Success!',
        text: 'You have added a new exam to the class!',
        onConfirmBtnTap: () {
          // DISMISS SUCCESS
          Navigator.of(context).pop();
          // CLOSE ADD EXAM MODAL
          Navigator.of(context).pop();
        },
      );
    });
  }

  Future<void> editExamDetails({
    required String classCode,
    required int examIndex,
    required dynamic exam,
  }) async {
    final classSnapshot =
        await _firestore.collection('classes').doc(classCode).get();
    final classData = classSnapshot.data();

    final List exams = classData!['exams'];
    exams[examIndex] = exam;

    await _firestore
        .collection('classes')
        .doc(classCode)
        .update({'exams': exams});
  }

  Future<void> deleteExamFromClass({
    required BuildContext context,
    required String classCode,
    required dynamic exam,
    required int examIndex,
  }) async {
    try {
      final classSnapshot =
          await _firestore.collection('classes').doc(classCode).get();

      final List exams = classSnapshot['exams'];

      exams.removeAt(examIndex);

      await _firestore.collection('classes').doc(classCode).update({
        'exams': exams,
      }).then((_) {
        // DISMISS LOADING
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.success,
          title:
              '${exam['exam']} ${exam['examType']} Exam Deleted Successfully!',
        );
      });
    } on FirebaseException catch (ex) {
      _alertService.showBanner(
        // ignore: use_build_context_synchronously
        context,
        'Unable to delete exam due to error: $ex',
      );
    }
  }

  Future<void> addAnnouncement({
    required String classCode,
    String? title,
    required String message,
    required String instructorName,
  }) async {
    final Timestamp timestamp = Timestamp.now();

    await _firestore
        .collection('announcements')
        .doc(classCode)
        .collection('messages')
        .add({
      'title': title ?? '! Announcement !',
      'message': message,
      'timestamp': timestamp,
      'instructorName': instructorName,
    });
  }

  Stream<QuerySnapshot> getAnnouncements({required String classCode}) {
    return _firestore
        .collection('announcements')
        .doc(classCode)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteAnnouncement({
    required BuildContext context,
    required String classCode,
    required String announcementId,
  }) async {
    await _firestore
        .collection('announcements')
        .doc(classCode)
        .collection('messages')
        .doc(announcementId)
        .delete()
        .then((_) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      _alertService.showBanner(context, 'Announcement Successfully Deleted.');
    });
  }

  Future<void> removeStudent(
      {required String classCode, required String studentId}) async {
    await _firestore.collection('classes').doc(classCode).update({
      'students': FieldValue.arrayRemove([studentId])
    });
  }

  Future<void> saveViolations({
    required String classCode,
    required double changeView,
    required double copyPaste,
  }) async {
    _firestore.collection('classes').doc(classCode).update({
      'violations': {
        'changeView': changeView,
        'copyPaste': copyPaste,
      },
    });
  }

  // --- STUDENT FUNCTIONS ---

  Future<void> joinClass(
      BuildContext context, String classCode, String studentId) async {
    try {
      final classDoc =
          await _firestore.collection('classes').doc(classCode).get();

      if (classDoc.exists) {
        List<dynamic> currentStudents = classDoc.data()?['students'] ?? [];

        // CHECK IF STUDENT IS NOT IN THE LIST
        if (!currentStudents.contains(studentId)) {
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
        } else {
          // IF ALREADY EXISTING, JUST INFORM THEM
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();

          QuickAlert.show(
            // ignore: use_build_context_synchronously
            context: context,
            type: QuickAlertType.info,
            title: 'You are already in this class!',
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          title: 'Class not found!',
        );
      }
    } on FirebaseException catch (ex) {
      _alertService.showBanner(
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

  Future<void> submitActivityAnswer({
    required String classCode,
    required String studentId,
    required int lessonIndex,
    required int activityIndex,
    dynamic attachments,
  }) async {
    final classSnapshot =
        await _firestore.collection('classes').doc(classCode).get();
    final classData = classSnapshot.data();

    final lessons = classData!['lessons'];

    final activities = lessons[lessonIndex]['activities'];

    final activity = activities[activityIndex];

    Map<String, dynamic> submissions = activity['submissions'];

    submissions.addAll({
      studentId: {
        'attachments': attachments,
      },
    });

    activity['submissions'] = submissions;
    activities[activityIndex] = activity;
    lessons[lessonIndex]['activities'] = activities;

    await _firestore
        .collection('classes')
        .doc(classCode)
        .update({'lessons': lessons});
  }

  Future<void> initializeExamScore({
    required String classCode,
    required int examIndex,
    required String studentId,
  }) async {
    final classSnapshot =
        await _firestore.collection('classes').doc(classCode).get();
    final classData = classSnapshot.data();

    final List<dynamic> exams = classData!['exams'];
    final Map<String, dynamic> exam = exams[examIndex];
    exam.addAll({
      'submissions': {
        studentId: {
          'score': 0,
          'writtenAnswer': 'No Answer',
        },
      },
    });

    exams[examIndex] = exam;

    await _firestore
        .collection('classes')
        .doc(classCode)
        .update({'exams': exams});
  }

  Future<void> submitExamAnswer({
    required String classCode,
    required bool isLab,
    required int examIndex,
    required String studentId,
    required double score,
    String? laboratoryAnswer,
    List<String?>? writtenAnswer,
    int? copyPasteViolations,
    required int changeViewViolations,
  }) async {
    // TO DO
    final classSnapshot =
        await _firestore.collection('classes').doc(classCode).get();
    final classData = classSnapshot.data();

    final exams = classData!['exams'];

    final answeredExam = exams[examIndex];

    Map<String, dynamic> submissions = answeredExam['submissions'];

    Map<String, dynamic> submissionContent = {};

    if (isLab) {
      submissionContent = {
        'score': score,
        'laboratoryAnswer': laboratoryAnswer,
        'copyPasteViolations': copyPasteViolations,
        'changeViewViolations': changeViewViolations,
      };
    } else {
      submissionContent = {
        'score': score,
        'writtenAnswer': writtenAnswer,
        'changeViewViolations': changeViewViolations,
      };
    }

    submissions.addAll({
      studentId: submissionContent,
    });

    answeredExam['submissions'] = submissions;
    exams[examIndex] = answeredExam;

    await _firestore
        .collection('classes')
        .doc(classCode)
        .update({'exams': exams});
  }
}
