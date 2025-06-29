import 'package:flutter/material.dart';
// SESUAIKAN IMPORT INI DENGAN NAMA PROYEK ANDA YANG BENAR
import 'package:login_signup/screens/signin_screen.dart'; // <--- INI SUDAH BENAR SEKARANG

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  // Warna utama yang konsisten dengan aplikasi
  final Color primaryColor = const Color(0xFF2A4D69);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor, // Memberikan warna pada AppBar
        iconTheme:
            const IconThemeData(color: Colors.white), // Mengatur warna ikon
        automaticallyImplyLeading: false, // Menyembunyikan tombol back default
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Ikon logout
            onPressed: () {
              // Navigasi kembali ke SignInScreen dan hapus semua rute sebelumnya
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Selamat Datang, Admin!',
              style: TextStyle(
                fontSize: 28, // Ukuran font lebih besar
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              'Ini adalah halaman dashboard untuk Administrator.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
