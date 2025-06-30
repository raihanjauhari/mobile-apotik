import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Import CustomHeader
import 'package:login_signup/widgets/menu.dart'; // Import CustomBottomNavBar
import 'package:login_signup/screens/signin_screen.dart';

// Import halaman-halaman admin lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/admin/dashboard_admin.dart';
import 'package:login_signup/pages/admin/obat.dart';
import 'package:login_signup/pages/admin/akun.dart';

class EresepAdminPage extends StatefulWidget {
  const EresepAdminPage({super.key});

  @override
  State<EresepAdminPage> createState() => _EresepAdminPageState();
}

class _EresepAdminPageState extends State<EresepAdminPage> {
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color accentColor = const Color(0xFFF0F4F8);
  int _selectedIndex = 1; // Index untuk E-Resep di BottomNavBar

  final TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: CustomHeader(
        primaryColor: primaryColor,
        onNotificationPressed: () {
          _showSimpleModal('Notifikasi',
              'Anda memiliki beberapa notifikasi baru di halaman E-Resep Admin.');
        },
        searchController: _searchController,
        onSearchChanged: (text) {
          print('Search text E-Resep Admin: $text');
        },
        searchHintText: 'Cari E-Resep Admin...',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 100,
              color: primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Halaman E-Resep Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Di sini admin dapat mengelola daftar E-Resep.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
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
          // Logika navigasi untuk Admin
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardAdmin()),
            );
          } else if (index == 1) {
            print("Sudah di halaman E-Resep Admin.");
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObatAdminPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunAdminPage()),
            );
          } else if (index == 4) {
            // Sign Out / Kembali ke Sign In Screen
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
