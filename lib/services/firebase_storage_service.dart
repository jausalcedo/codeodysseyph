import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  // STORAGE REREFENCE
  final storageRef = FirebaseStorage.instance.ref();

  // UPLOAD SYLLABUS FILE
  Future<String> uploadFile(
    String storagePath,
    String fileName,
    Uint8List fileBytes,
  ) async {
    try {
      final timeStamp = DateTime.now().microsecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$storagePath$timeStamp-$fileName');
      final uploadTask = storageRef.putData(fileBytes);

      final snapshot = await uploadTask;

      return snapshot.ref.fullPath;
    } catch (e) {
      throw Exception('Error uploading PDF: $e');
    }
  }

  Future<bool> deleteFile(List files) async {
    try {
      for (int i = 0; i < files.length; i++) {
        final fileRef = storageRef.child(files[i]);

        await fileRef.delete();
      }
      return true;
    } catch (e) {
      // ignore: use_build_context_synchronously
      return false;
    }
  }
}
