import 'package:flutter/material.dart';
// Import file routes yang baru Anda buat
import 'package:login_signup/routes/routes.dart'; // <--- Tambahkan ini
import 'package:login_signup/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Apotek', // Lebih spesifik dari 'Flutter Demo'
      theme: lightMode,
      // Ganti 'home' dengan 'initialRoute' dan 'routes'
      initialRoute: AppRoutes.welcome, // <--- Tentukan rute awal aplikasi
      routes: AppRoutes.routes, // <--- Gunakan map rute dari AppRoutes
      // onGenerateRoute: AppRoutes.onGenerateRoute, // Opsional: aktifkan jika butuh route generator
    );
  }
}
