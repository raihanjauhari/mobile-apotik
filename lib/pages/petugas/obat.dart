import 'package:flutter/material.dart';

class ObatPage extends StatelessWidget {
  const ObatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obat'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('Halaman Obat (Belum Diimplementasikan Penuh)'),
      ),
    );
  }
}
