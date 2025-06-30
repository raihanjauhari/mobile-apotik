// lib/screens/new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Digunakan untuk mendapatkan userId sementara

import '../widgets/custom_scaffold.dart';
import 'signin_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String _passwordError = '';
  String _confirmPasswordError = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _showSuccessModal = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Color primaryColor = const Color(0xFF2A4D69);
  final Color darkTextColor = const Color(0xFF1D242E);
  final Color blackTextColor = const Color(0xFF000000);
  final Color hintAndLabelColor = Colors.black54;

  String? _currentUserId; // State untuk menyimpan userId dari SharedPreferences
  String?
      _currentEmail; // State untuk menyimpan email dari SharedPreferences (opsional)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _loadUserIdAndEmail(); // Panggil fungsi untuk memuat data saat inisialisasi
  }

  // Fungsi untuk memuat userId dan email dari SharedPreferences
  Future<void> _loadUserIdAndEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedUserId = prefs.getString('current_reset_user_id');
    final loadedEmail = prefs.getString('current_reset_email');

    if (loadedUserId != null) {
      setState(() {
        _currentUserId = loadedUserId;
        _currentEmail = loadedEmail;
      });
      print(
          "NewPasswordScreen: Loaded userId: $_currentUserId, email: $_currentEmail");
    } else {
      // Jika userId tidak ditemukan, tampilkan pesan error dan arahkan kembali
      setState(() {
        _errorMessage =
            "ID pengguna tidak ditemukan. Silakan mulai proses reset password dari awal.";
      });
      print("NewPasswordScreen: userId not found in SharedPreferences.");
      // Opsional: Langsung arahkan kembali ke halaman login setelah beberapa detik jika userId tidak ditemukan
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          // Pastikan widget masih ada sebelum navigasi
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (route) => false);
        }
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Password tidak boleh kosong.";
    }
    if (password.length < 6) {
      return "Password harus minimal 6 karakter.";
    }
    if (!password.contains(RegExp(r'\d'))) {
      return "Password harus mengandung angka.";
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "Password harus mengandung huruf kapital.";
    }
    return null;
  }

  void _handleSubmit() async {
    setState(() {
      _passwordError = '';
      _confirmPasswordError = '';
      _errorMessage = '';
      _isLoading = true;
    });

    if (_currentUserId == null) {
      setState(() {
        _errorMessage =
            "ID pengguna tidak tersedia. Silakan mulai proses reset password dari awal.";
        _isLoading = false;
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      final String? passwordValidation =
          _validatePassword(_passwordController.text);
      if (passwordValidation != null) {
        setState(() {
          _passwordError = passwordValidation;
          _isLoading = false;
        });
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _confirmPasswordError = "Konfirmasi password tidak cocok.";
          _isLoading = false;
        });
        return;
      }

      final String newPassword = _passwordController.text;
      // URL API yang di-deploy: https://ti054b05.agussbn.my.id/api/user/:id/password (PUT request)
      final String apiUrl =
          "https://ti054b05.agussbn.my.id/api/user/${_currentUserId}/password";

      try {
        final response = await http.put(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'password': newPassword,
          }),
        );

        if (response.statusCode == 200) {
          print("Password berhasil diubah untuk UserID: ${_currentUserId}");

          setState(() {
            _showSuccessModal = true;
          });
          _animationController.forward(from: 0.0);

          _passwordController.clear();
          _confirmPasswordController.clear();

          // Hapus userId dari SharedPreferences setelah password berhasil diubah
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('current_reset_user_id');
          await prefs.remove('current_reset_email'); // Hapus juga email
        } else {
          final errorData = json.decode(response.body);
          setState(() {
            _errorMessage = errorData['error'] ??
                "Gagal mengubah password. Mohon coba lagi.";
          });
          print("API Error: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        setState(() {
          _errorMessage =
              "Gagal terhubung ke server. Periksa koneksi internet Anda atau coba lagi nanti.";
        });
        print("Network/API Call Error: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = "Mohon lengkapi semua field dengan benar.";
        _isLoading = false;
      });
    }
  }

  void _handleSuccessModalContinue() {
    _animationController.reverse().then((_) {
      setState(() {
        _showSuccessModal = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tombol nonaktif jika loading atau userId belum dimuat
    final bool isSubmitDisabled = _isLoading || _currentUserId == null;

    return CustomScaffold(
      child: Stack(
        children: [
          Column(
            children: [
              const Expanded(flex: 0, child: SizedBox(height: 0)),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40.0)),
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
                              SvgPicture.asset('assets/images/logo.svg',
                                  height: 50, width: 50),
                              const SizedBox(width: 5),
                              Text('Pharmacy',
                                  style: TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      color: darkTextColor)),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Text('Buat Password Baru',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 35.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                          const SizedBox(height: 15.0),
                          Text(
                              'Buat Password yang berbeda dari sebelumnya untuk keamanan akun Anda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                  color: blackTextColor)),
                          const SizedBox(height: 30.0),
                          if (_errorMessage.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              margin: const EdgeInsets.only(bottom: 20.0),
                              decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border:
                                      Border.all(color: Colors.red.shade400)),
                              child: Text(_errorMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Password',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Password',
                                  hintStyle:
                                      TextStyle(color: hintAndLabelColor),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  errorStyle:
                                      const TextStyle(height: 0, fontSize: 0),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        _showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: primaryColor),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _passwordError = '';
                                    _errorMessage = '';
                                  });
                                  _formKey.currentState?.validate();
                                },
                                validator: _validatePassword,
                              ),
                              if (_passwordError.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(_passwordError,
                                        style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12.0))),
                            ],
                          ),
                          const SizedBox(height: 25.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Konfirmasi Password',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_showConfirmPassword,
                                decoration: InputDecoration(
                                  hintText: 'Konfirmasi Password',
                                  hintStyle:
                                      TextStyle(color: hintAndLabelColor),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  errorStyle:
                                      const TextStyle(height: 0, fontSize: 0),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        _showConfirmPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: primaryColor),
                                    onPressed: () {
                                      setState(() {
                                        _showConfirmPassword =
                                            !_showConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _confirmPasswordError = '';
                                    _errorMessage = '';
                                  });
                                  _formKey.currentState?.validate();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Konfirmasi password tidak boleh kosong.";
                                  }
                                  if (_passwordController.text.isNotEmpty &&
                                      _validatePassword(
                                              _passwordController.text) ==
                                          null &&
                                      value != _passwordController.text) {
                                    return "Konfirmasi password tidak cocok.";
                                  }
                                  return null;
                                },
                              ),
                              if (_confirmPasswordError.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(_confirmPasswordError,
                                        style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12.0))),
                            ],
                          ),
                          const SizedBox(height: 30.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  isSubmitDisabled ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor.withOpacity(0.9),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    primaryColor.withOpacity(0.5),
                                disabledForegroundColor:
                                    Colors.white.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Ubah Password',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                            ),
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
          if (_showSuccessModal)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  contentPadding: const EdgeInsets.all(24.0),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('BERHASIL',
                          style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      Icon(Icons.check_circle_outline,
                          color: primaryColor, size: 100),
                      const SizedBox(height: 20),
                      const Text(
                          'Selamat! Password Anda berhasil dibuat. Klik "Lanjutkan" untuk login.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.black)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSuccessModalContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Lanjutkan',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
