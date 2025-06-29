import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Pastikan CustomHeader Anda ada
import 'package:login_signup/widgets/menu.dart'; // Pastikan CustomBottomNavBar Anda ada
import 'package:login_signup/screens/signin_screen.dart'; // Untuk navigasi Signin

// Import halaman-halaman utama lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/petugas/dashboard_petugas.dart'; // Penting untuk navigasi antar menu
import 'package:login_signup/pages/petugas/eresep.dart'; // Penting untuk navigasi antar menu
import 'package:login_signup/pages/petugas/obat.dart'; // Penting untuk navigasi antar menu

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  // --- Colors (Salin dari DashboardPetugas agar konsisten) ---
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color secondaryColor = const Color(0xFF6B8FB4);
  final Color accentColor =
      const Color(0xFFF0F4F8); // Warna latar belakang terang

  // --- UI State Variables (Salin dari DashboardPetugas) ---
  int _selectedIndex =
      3; // Default selected index untuk AkunPage adalah 3 (asumsi: 0-Dashboard, 1-Eresep, 2-Obat, 3-Akun)
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Methods ---

  /// Shows a simple modal dialog with a title and content.
  void _showSimpleModal(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: CustomHeader(
        primaryColor: primaryColor,
        onNotificationPressed: () {
          // Karena ini halaman Akun, notifikasi bisa terkait akun itu sendiri.
          // Untuk demo, kita bisa tampilkan modal atau ke halaman notifikasi spesifik.
          _showSimpleModal(
              'Notifikasi Akun', 'Tidak ada notifikasi akun baru.');
        },
        searchController: _searchController,
        onSearchChanged: (text) {
          // Handle search text changes di halaman Akun
          print('Search text on AkunPage: $text');
          // Anda bisa menambahkan logika filter/pencarian di sini nanti
        },
        searchHintText:
            'Cari sesuatu di Akun...', // Custom hint text untuk halaman Akun
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Halaman Akun Petugas',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Di sini akan ada detail profil, pengaturan, dll.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showSimpleModal(
                    'Pengaturan', 'Fitur pengaturan akun akan segera hadir!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Logika navigasi yang sama seperti di DashboardPetugas dan ObatPage
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPetugas()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EresepPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObatPage()),
            );
          } else if (index == 3) {
            // Sudah di halaman Akun, jadi tidak perlu navigasi ulang
            // Atau bisa juga melakukan refresh data jika ada
            print("Sudah di halaman Akun.");
          } else if (index == 4) {
            // Asumsi ada 5 item di menu
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (Route<dynamic> route) => false,
            );
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600]!,
        primaryColor: primaryColor,
      ),
    );
  }
}
