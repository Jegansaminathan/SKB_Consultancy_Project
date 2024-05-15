import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdf;

  PdfViewerPage({required this.pdf});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? pdfUrl;

  @override
  void initState() {
    super.initState();

    // fetchPdfFromStorage();
  }

  Future<void> fetchPdfFromStorage() async {
    try {
      final ref = FirebaseStorage.instance.ref().child('path/to/your/pdf/file.pdf');
      final url = await ref.getDownloadURL();
      setState(() {
        pdfUrl = url;
      });
    } catch (e) {
      print('Error fetching PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
        body: Center(
        child: Transform.translate(
        offset: Offset(0, MediaQuery.of(context).size.height * -0.12),
          child:PDFView(
              filePath: widget.pdf,
              enableSwipe: true,
              swipeHorizontal: true,
          )
        )
        )
    );
  }
}