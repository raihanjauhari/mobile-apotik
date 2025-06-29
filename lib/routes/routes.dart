import 'package:flutter/material.dart';
import 'package:login_signup/screens/welcome_screen.dart';
import 'package:login_signup/screens/signin_screen.dart';
import 'package:login_signup/screens/signup_screen.dart'; // <--- PASTIKAN IMPORT INI BENAR
import 'package:login_signup/screens/forget_password_screen.dart';
import 'package:login_signup/screens/new_password_screen.dart';
import 'package:login_signup/screens/verification_code_screen.dart'; // Pastikan import ini benar
import 'package:login_signup/pages/petugas/dashboard_petugas.dart';
// Tambahkan import untuk halaman lain yang mungkin akan Anda buat, contoh:
// import 'package:login_signup/components/pages/petugas/obat_page.dart';
// import 'package:login_signup/components/pages/petugas/eresep_page.dart';

class AppRoutes {
  // Definisikan semua nama rute sebagai konstanta string untuk menghindari typo
  static const String welcome = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup'; // <--- Tambahkan ini
  static const String forgotPassword = '/forgot-password';
  static const String newPassword = '/new-password';
  static const String verification =
      '/verification'; // Nama konstanta adalah 'verification'
  static const String dashboardPetugas = '/dashboard-petugas';
  // Tambahkan rute untuk halaman lain di aplikasi Anda
  // static const String obat = '/obat';
  // static const String eresep = '/eresep';
  // static const String profile = '/profile';

  // Map yang memetakan nama rute ke widget yang sesuai
  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomeScreen(),
      signIn: (context) => const SignInScreen(),
      forgotPassword: (context) => const ForgetPasswordScreen(),
      newPassword: (context) => const NewPasswordScreen(),
      // SOLUSI UNTUK ERROR "missing_required_argument":
      // Anda HARUS menyediakan nilai untuk 'email'.
      // Di sini kita gunakan nilai placeholder, idealnya ini akan ditangani via onGenerateRoute
      verification: (context) => const VerificationCodeScreen(
          email: 'placeholder@email.com'), // <--- PERBAIKAN DI SINI
      dashboardPetugas: (context) => const DashboardPetugas(),
      // Daftarkan rute lainnya di sini
      // obat: (context) => const ObatPage(),
      // eresep: (context) => const EresepPage(),
      // profile: (context) => const ProfilePage(),
    };
  }

  // Jika Anda ingin menggunakan route generator untuk penanganan rute yang tidak ditemukan atau dinamis
  // Ini adalah cara yang lebih baik untuk meneruskan argumen seperti email
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == verification) {
      final String? email =
          settings.arguments as String?; // Coba ambil email dari argumen
      // Jika email disediakan saat navigasi, gunakan itu. Jika tidak, gunakan placeholder atau tampilkan error.
      return MaterialPageRoute(
        builder: (context) => VerificationCodeScreen(
            email: email ?? 'default_from_generator@example.com'),
      );
    }
    // Jika rute tidak ditangani oleh onGenerateRoute, biarkan map 'routes' yang di atas menanganinya.
    return null;
  }
}
