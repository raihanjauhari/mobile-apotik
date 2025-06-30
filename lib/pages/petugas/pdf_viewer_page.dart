// lib/pages/petugas/pdf_viewer_page.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String path;
  final String title;

  const PdfViewerPage({Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor:
            const Color(0xFF2A4D69), // Menggunakan primaryColor Anda
        foregroundColor: Colors.white,
      ),
      body: SfPdfViewer.asset(
          path), // Menggunakan SfPdfViewer.asset untuk aset lokal
    );
  }
}
