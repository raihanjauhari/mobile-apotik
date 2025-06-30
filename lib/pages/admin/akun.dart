import 'package:flutter/material.dart';
import 'package:login_signup/widgets/menu.dart'; // Import CustomBottomNavBar
import 'package:login_signup/screens/signin_screen.dart';

// Import halaman-halaman admin lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/admin/dashboard_admin.dart'; // Mengarah ke DashboardAdmin
import 'package:login_signup/pages/admin/eresep.dart';
import 'package:login_signup/pages/admin/obat.dart';

class AkunAdminPage extends StatefulWidget {
  const AkunAdminPage({super.key});

  @override
  State<AkunAdminPage> createState() => _AkunAdminPageState();
}

class _AkunAdminPageState extends State<AkunAdminPage> {
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color accentColor = const Color(0xFFF0F4F8);
  int _selectedIndex =
      3; // Index untuk Akun di BottomNavBar (0:Dashboard, 1:E-Resep, 2:Obat, 3:Akun, 4:Keluar)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: AppBar(
        // Menggunakan AppBar standar tanpa elemen header kustom
        backgroundColor: primaryColor,
        title: const Text(
          'Akun Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading:
            false, // Menghilangkan tombol kembali otomatis
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 100,
              color: primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Halaman Akun Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Di sini admin dapat mengelola profil dan pengaturan.',
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EresepAdminPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObatAdminPage()),
            );
          } else if (index == 3) {
            print("Sudah di halaman Akun Admin.");
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
