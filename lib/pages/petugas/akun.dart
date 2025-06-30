import 'package:flutter/material.dart';
// Header dan Inti (menu) akan diganti, jadi tidak perlu import lagi CustomHeader
import 'package:login_signup/widgets/menu.dart'; // Pastikan CustomBottomNavBar Anda ada
import 'package:login_signup/screens/signin_screen.dart'; // Untuk navigasi Signin

// Import halaman-halaman utama lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/petugas/dashboard_petugas.dart';
import 'package:login_signup/pages/petugas/eresep.dart';
import 'package:login_signup/pages/petugas/obat.dart';

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
  // final Color tealColor = const Color(0xFF00BCD4); // Dihapus
  // final Color lightTealColor = const Color(0xFF4DD0E1); // Dihapus
  final Color redColor =
      const Color(0xFFD32F2F); // Warna merah untuk tombol logout

  // --- Mock Data Pengguna ---
  final Map<String, dynamic> _userData = {
    "id_user": "U001",
    "email": "raihanfg565@gmail.com",
    "password": "", // Password tidak ditampilkan
    "nama_user": "DON Jumbo",
    "role": "petugas",
    "foto_user": "jumbo.jpeg", // Nama file gambar profil (akan diabaikan)
  };

  // --- UI State Variables ---
  int _selectedIndex =
      3; // Default selected index untuk AkunPage adalah 3 (asumsi: 0-Dashboard, 1-Eresep, 2-Obat, 3-Akun)

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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

  /// Shows a confirmation dialog for logout.
  Future<void> _confirmLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Tidak jadi logout
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Ya, logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor, // Warna merah untuk tombol Logout
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // --- Widget Builders ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileMenuItems(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
            print("Sudah di halaman Akun.");
          } else if (index == 4) {
            _confirmLogout();
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600]!,
        primaryColor: primaryColor,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      // Menggunakan Container dengan BorderRadius langsung
      width: double.infinity,
      height: 200, // TINGGI HEADER disesuaikan menjadi 200
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, secondaryColor], // Menggunakan warna tema
        ),
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(50)), // Lengkungan lebih besar tapi halus
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Judul "Profil Saya"
          Positioned(
            top: 30, // Sesuaikan posisi judul
            child: Text(
              'Profil Saya',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Konten Profil (Foto, Nama, Email)
          Positioned(
            top: 70, // Sesuaikan posisi foto dan detail
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 40, // Mengurangi radius avatar
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 45,
                          color: primaryColor), // Warna ikon disesuaikan
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 15, // Ukuran lingkaran edit
                        backgroundColor: primaryColor,
                        child: Icon(
                            // Ikon edit langsung, bukan IconButton di dalam CircleAvatar
                            Icons.edit,
                            color: Colors.white,
                            size: 15 // Ukuran ikon edit
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Mengurangi spasi
                Text(
                  _userData['nama_user'] ?? 'Nama Pengguna',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Mengurangi ukuran font nama
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userData['email'] ?? 'email@example.com',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11, // Mengurangi ukuran font email
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Profil', () {
            _showSimpleModal('Profil', 'Detail profil pribadi Anda.');
          }),
          _buildMenuItem(Icons.favorite_border, 'Favorit', () {
            _showSimpleModal('Favorit', 'Daftar item favorit Anda.');
          }),
          _buildMenuItem(Icons.payment, 'Metode Pembayaran', () {
            _showSimpleModal(
                'Metode Pembayaran', 'Kelola metode pembayaran Anda.');
          }),
          _buildMenuItem(Icons.lock_outline, 'Kebijakan Privasi', () {
            _showSimpleModal(
                'Kebijakan Privasi', 'Kebijakan privasi aplikasi.');
          }),
          _buildMenuItem(Icons.settings_outlined, 'Pengaturan', () {
            _showSimpleModal('Pengaturan', 'Pengaturan aplikasi.');
          }),
          _buildMenuItem(Icons.help_outline, 'Bantuan', () {
            _showSimpleModal('Bantuan', 'Pusat bantuan.');
          }),
          _buildMenuItem(Icons.logout, 'Keluar', () {
            _confirmLogout();
          }, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return Column(
      children: [
        Card(
          // Menggunakan Card untuk setiap ListTile agar ada elevasi dan rounded corner
          elevation: 1, // Elevasi minimal
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Sudut melengkung
          ),
          margin: EdgeInsets.zero, // Hapus margin default Card
          child: ListTile(
            leading: Icon(icon, color: primaryColor),
            title: Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: isLogout
                ? null
                : Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: onTap,
            // tileColor: Colors.white, // Tidak perlu tileColor jika pakai Card
          ),
        ),
        const SizedBox(height: 10), // Spasi antar item menu
      ],
    );
  }
}

// Custom Clipper untuk bentuk gelombang di header (DIHAPUS KARENA MENGGUNAKAN BORDERRADIUS)
// class WaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height * 0.75);
//     path.quadraticBezierTo(
//       size.width / 4, size.height,
//       size.width / 2, size.height * 0.75
//     );
//     path.quadraticBezierTo(
//       size.width * 3 / 4, size.height * 0.5,
//       size.width, size.height * 0.75
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }

// Custom Painter untuk gelombang di latar belakang (masih digunakan untuk gelombang putih transparan)
class WavePainter extends CustomPainter {
  final Color primaryColor;

  WavePainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = primaryColor;
    var path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7,
        size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
