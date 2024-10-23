import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class ModuleViewer extends StatefulWidget {
  final String filePath;
  final String moduleName;

  const ModuleViewer(
      {super.key, required this.filePath, required this.moduleName});

  @override
  State<ModuleViewer> createState() => _ModuleViewerState();
}

class _ModuleViewerState extends State<ModuleViewer> {
  late PdfControllerPinch pdfControllerPinch;
  int totalPageCount = 0, currentPage = 0;

  @override
  void initState() {
    pdfControllerPinch = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.filePath),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the color you want for the back button
        ),
        backgroundColor: const Color.fromARGB(255, 19, 27, 99),
        title: Text(
          widget.moduleName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ), // Fix: Removed the const
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: Column(
            children: [
              Row(
                children: [
                  Text("Total Pages $totalPageCount"),
                  IconButton(
                      onPressed: () {
                        pdfControllerPinch.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear);
                      },
                      icon: const Icon(Icons.arrow_back)),
                  Text("$currentPage"),
                  IconButton(
                      onPressed: () {
                        pdfControllerPinch.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear);
                      },
                      icon: const Icon(Icons.arrow_forward)),
                ],
              ),
              _pdfView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pdfView() {
    return Expanded(
      child: PdfViewPinch(
        onDocumentLoaded: (doc) {
          setState(() {
            totalPageCount = doc.pagesCount;
          });
        },
        onPageChanged: (page) {
          setState(() {
            currentPage = page;
          });
        },
        controller: pdfControllerPinch,
      ),
    );
  }
}
