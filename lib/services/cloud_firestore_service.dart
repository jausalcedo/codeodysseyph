import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';

class CloudFirestoreService {
  final _firestore = FirebaseFirestore.instance;

  final _storageService = FirebaseStorageService();

  void _showBanner(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

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

      _showBanner(
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
        // ignore: use_build_context_synchronously
        _showBanner(context, '$courseTitle Successfully Deleted.');
      });
    } on FirebaseException catch (e) {
      // ignore: use_build_context_synchronously
      _showBanner(context,
          'There was an error deleting $courseTitle in Firestore: $e.');
    }
  }

  Future<void> addToFiles(String courseId, String fullPath) async {
    await _firestore.collection('courses').doc(courseId).update({
      'files': FieldValue.arrayUnion([fullPath]),
    });
  }

  Future<void> addLesson(
    BuildContext context,
    String courseId,
    String lessonTitle,
    String fileName,
    Uint8List fileBytes,
    String activityType,
    dynamic content,
  ) async {
    try {
      final learningMaterialPath = await _storageService.uploadFile(
        'courses/files/',
        fileName,
        fileBytes,
      );

      await addToFiles(courseId, learningMaterialPath);

      await _firestore.collection('courses').doc(courseId).update({
        'lessons': FieldValue.arrayUnion([
          {
            'title': lessonTitle,
            'learningMaterial': learningMaterialPath,
            'activityType': activityType,
            'content': content,
          }
        ])
      }).then((_) {
        // ignore: use_build_context_synchronously
        _showBanner(context, '$lessonTitle Successfully Added.');
      });
    } on FirebaseException catch (e) {
      // ignore: use_build_context_synchronously
      _showBanner(
          context, 'There was an error adding $lessonTitle in Firestore: $e.');
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
            _showBanner(
              // ignore: use_build_context_synchronously
              context,
              '${lesson['title']} has been successfully deleted.',
            );
          });
        });
      });
    } on FirebaseException catch (ex) {
      _showBanner(
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
}
