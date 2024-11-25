import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ModuleViewer extends StatefulWidget {
  final String filePath;
  final String moduleName;

  const ModuleViewer(
      {super.key, required this.filePath, required this.moduleName});

  @override
  State<ModuleViewer> createState() => _ModuleViewerState();
}

class _ModuleViewerState extends State<ModuleViewer> {
  final storageRef = FirebaseStorage.instance.ref();
  Uint8List? pdfData;

  @override
  void initState() {
    super.initState();
  }

  void loadPDFFromFirebase() async {
    try {
      final pdfRef = FirebaseStorage.instance.refFromURL(
          'gs://codeodysseyph.appspot.com/courses/syllabus/1730007748121000-CodeOdyssey - Final Letter.pdf');

      await pdfRef.getData().then((value) {
        setState(() {
          pdfData = value;
        });
      });
    } on FirebaseException catch (ex) {
      print('Error Loading PDF: $ex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 19, 27, 99),
        title: Text(
          widget.moduleName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: pdfData != null
          ? SfPdfViewer.memory(pdfData!)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
