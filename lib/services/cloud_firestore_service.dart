import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/constants/courses.dart';
import 'package:codeodysseyph/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';

class CloudFirestoreService {
  final _firestore = FirebaseFirestore.instance;

  final _storageService = FirebaseStorageService();

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

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
              '${tempSelectedCourse.code} - ${tempSelectedCourse.title} Course Outline Successfully Added!'),
          actions: [
            TextButton(
                onPressed:
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
                child: const Text('Dismiss'))
          ],
        ),
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
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: Text('$courseTitle Successfully Deleted.'),
            actions: [
              TextButton(
                onPressed:
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      });
    } on FirebaseException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
              'There was an error deleting $courseTitle in Firestore: $e.'),
          actions: [
            TextButton(
              onPressed:
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
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
            'setDate': false,
            'content': content,
          }
        ])
      }).then((_) {
        // ignore: use_build_context_synchronously

        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: Text('$lessonTitle Successfully Added.'),
            actions: [
              TextButton(
                onPressed:
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      });
    } on FirebaseException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content:
              Text('There was an error adding $lessonTitle in Firestore: $e.'),
          actions: [
            TextButton(
              onPressed:
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    }
  }
}
