import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Pastikan CustomHeader Anda ada
import 'package:login_signup/widgets/menu.dart'; // Pastikan CustomBottomNavBar Anda ada
import 'package:login_signup/screens/signin_screen.dart'; // Untuk navigasi Signin

// Import halaman-halaman utama lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/petugas/dashboard_petugas.dart'; // Penting untuk navigasi antar menu
import 'package:login_signup/pages/petugas/eresep.dart'; // Penting untuk navigasi antar menu
import 'package:login_signup/pages/petugas/akun.dart'; // Penting untuk navigasi antar menu

class ObatPage extends StatefulWidget {
  const ObatPage({super.key});

  @override
  State<ObatPage> createState() => _ObatPageState();
}

class _ObatPageState extends State<ObatPage> {
  // --- Colors (Salin dari DashboardPetugas agar konsisten) ---
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color secondaryColor = const Color(0xFF6B8FB4);
  final Color accentColor =
      const Color(0xFFF0F4F8); // Warna latar belakang terang

  // --- UI State Variables (Salin dari DashboardPetugas) ---
  int _selectedIndex =
      2; // Default selected index untuk ObatPage adalah 2 (asumsi: 0-Dashboard, 1-Eresep, 2-Obat)
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
          // Navigasi ke Halaman Akun dari notifikasi (konsisten dengan Dashboard)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AkunPage()),
          );
        },
        searchController: _searchController,
        onSearchChanged: (text) {
          // Handle search text changes di halaman Obat
          print('Search text on ObatPage: $text');
          // Anda bisa menambahkan logika filter obat di sini nanti
        },
        searchHintText:
            'Cari Obat di sini...', // Custom hint text untuk halaman Obat
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Halaman Obat',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Ini adalah tampilan detail daftar obat.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showSimpleModal('Informasi',
                    'Fitur daftar obat lengkap akan segera hadir!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Lihat Daftar Obat'),
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
          // Logika navigasi yang sama seperti di DashboardPetugas
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
            // Sudah di halaman Obat, jadi tidak perlu navigasi ulang
            // Atau bisa juga melakukan refresh data jika ada
            print("Sudah di halaman Obat.");
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunPage()),
            );
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
