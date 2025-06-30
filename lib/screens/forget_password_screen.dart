// lib/screens/forget_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Digunakan untuk SVG logo
import 'package:http/http.dart' as http; // Import package http
import 'dart:convert'; // Import untuk menggunakan json.decode dan json.encode

import 'package:login_signup/widgets/custom_scaffold.dart'; // Widget CustomScaffold Anda
import 'package:login_signup/screens/verification_code_screen.dart'; // Halaman VerificationCodeScreen Anda
import 'package:login_signup/screens/signin_screen.dart'; // Halaman SigninScreen Anda

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF2A4D69); // Warna utama
  final Color darkTextColor = const Color(
      0xFF1D242E); // Warna teks gelap untuk judul seperti "Pharmacy"
  final Color blackTextColor = const Color(0xFF000000); // Warna hitam murni
  final Color hintAndLabelColor = Colors.black54;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengirim permintaan kode reset ke API
  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = ''; // Reset error sebelum request
      _isLoading = true; // Aktifkan loading
    });

    final String email = _emailController.text.trim();
    // Gunakan URL API yang di-deploy
    final String apiUrl =
        "https://ti054b05.agussbn.my.id/api/user/send-reset-code";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Backend Go Anda mengembalikan pesan sukses bahkan jika email tidak terdaftar
        // Ini adalah perilaku yang baik untuk keamanan (tidak membocorkan keberadaan email)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                'Jika email Anda terdaftar, kode reset telah dikirim.'),
          ),
        );
        // Navigasi ke halaman verifikasi kode, kirimkan emailnya
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodeScreen(email: email),
          ),
        );
      } else {
        // Jika status code bukan 200
        setState(() {
          _errorMessage = responseData['error'] ??
              'Gagal mengirim kode reset. Mohon coba lagi.';
        });
        print("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // Handle network errors
      setState(() {
        _errorMessage =
            "Gagal terhubung ke server. Periksa koneksi internet Anda atau coba lagi nanti.";
      });
      print("Network/API Call Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Nonaktifkan loading terlepas dari sukses/gagal
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 0,
            child: SizedBox(height: 0),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SvgPicture.asset(
                            'assets/images/logo.svg', // Pastikan path ini benar
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Pharmacy',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        'Lupa Password?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Text(
                        'Masukkan alamat email Anda yang terdaftar untuk menerima kode verifikasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                          color: blackTextColor,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Masukkan Email Anda',
                              hintStyle: TextStyle(color: hintAndLabelColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              errorStyle: const TextStyle(
                                  height: 0,
                                  fontSize:
                                      0), // Menyembunyikan pesan error default
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong.';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Masukkan alamat email yang valid.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _errorMessage =
                                    ''; // Hapus pesan error saat pengguna mulai mengetik
                              });
                            },
                          ),
                          if (_errorMessage
                              .isNotEmpty) // Tampilkan pesan error custom jika ada
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                    color: Colors.red[700], fontSize: 12.0),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _sendResetCode, // Nonaktifkan tombol saat loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                primaryColor.withOpacity(0.5),
                            disabledForegroundColor:
                                Colors.white.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color:
                                      Colors.white) // Tampilkan loading spinner
                              : const Text(
                                  'Kirim Kode',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Ingat password Anda? ',
                            style: TextStyle(
                              color: Colors.black45, // Warna teks abu-abu gelap
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (e) => const SignInScreen()),
                              );
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor, // Warna link #2A4D69
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
