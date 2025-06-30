import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart'; // Dipertahankan untuk ikon sosial media
import 'package:flutter_svg/flutter_svg.dart'; // Untuk SVG logo
import 'package:http/http.dart' as http; // <<< TAMBAHKAN INI UNTUK API CALL
import 'dart:convert'; // <<< TAMBAHKAN INI UNTUK JSON ENCODE/DECODE
import 'package:shared_preferences/shared_preferences.dart'; // <<< TAMBAHKAN INI UNTUK SIMPAN TOKEN/INFO USER

// Asumsi file-file ini ada di proyek Anda
import '../widgets/custom_scaffold.dart'; // Widget CustomScaffold Anda
import 'forget_password_screen.dart'; // Halaman ForgetPasswordScreen Anda

// Impor halaman dashboard berdasarkan role
import '../pages/admin/dashboard_admin.dart'; // Pastikan path ini benar
import '../pages/petugas/dashboard_petugas.dart'; // Pastikan path ini benar

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool rememberPassword = true;
  bool _obscureText = true; // Mengontrol visibilitas password

  // --- STATE BARU SESUAI LOGIKA REACTJS DAN UNTUK API ---
  String _emailError = ''; // Error spesifik untuk field email
  String _passwordError = ''; // Error spesifik untuk field password
  String _globalMessage = ''; // Pesan global (sukses/error)
  bool _loginSuccess = false; // Status login sukses
  bool _isAuthenticating = false; // Indikator loading saat autentikasi
  // --- AKHIR STATE BARU ---

  // Mendefinisikan warna heksadesimal sesuai dengan desain web
  final Color primaryColor = const Color(0xFF2A4D69); // Warna utama
  final Color darkTextColor = const Color(
      0xFF1D242E); // Warna teks gelap untuk judul seperti "Pharmacy"
  final Color blackTextColor = const Color(0xFF000000); // Warna hitam murni
  final Color hintAndLabelColor =
      Colors.black54; // Warna untuk hint dan label input fields

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi validasi email (untuk validator TextFormField)
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return 'Format email tidak valid.';
    }
    return null; // Valid
  }

  // Fungsi validasi password (mengikuti logika ReactJS)
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Password tidak boleh kosong.";
    }
    if (password.length < 6) {
      return "Password harus memiliki minimal 6 karakter.";
    }
    if (!password.contains(RegExp(r'\d'))) {
      return "Password harus mengandung angka.";
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "Password harus mengandung huruf kapital.";
    }
    return null; // Validasi sukses
  }

  // Fungsi handle submit dengan API Login
  Future<void> _handleSubmit() async {
    // Reset semua pesan error/sukses sebelum submit
    setState(() {
      _emailError = '';
      _passwordError = '';
      _globalMessage = '';
      _loginSuccess = false;
      _isAuthenticating = true; // Aktifkan loading
    });

    // Panggil validate() pada FormKey
    if (!_formSignInKey.currentState!.validate()) {
      setState(() {
        _globalMessage = "Mohon lengkapi semua data dengan benar.";
        _loginSuccess = false;
        _isAuthenticating =
            false; // Nonaktifkan loading jika validasi form gagal
      });
      return; // Hentikan proses jika form tidak valid
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // URL API Login Anda
    final String apiUrl = "https://ti054b05.agussbn.my.id/api/auth/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Login berhasil
        final String token = responseData['token'];
        final Map<String, dynamic> user = responseData['user'];
        final String role = user['role']; // Asumsi role ada di objek user

        // Simpan token dan info user di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_id', user['id_user']);
        await prefs.setString('user_email', user['email']);
        await prefs.setString('user_role', user['role']);
        await prefs.setString(
            'user_name', user['nama_user']); // Tambahan jika perlu

        setState(() {
          _loginSuccess = true;
          _globalMessage = "Login Berhasil! Mengarahkan ke Dashboard...";
        });

        // Navigasi berdasarkan role
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardAdmin()),
          );
        } else if (role == 'petugas') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPetugas()),
          );
        } else {
          // Handle role lain atau default
          setState(() {
            _globalMessage =
                "Login berhasil, namun role tidak dikenali. Silakan hubungi admin.";
            _loginSuccess = false;
          });
        }
      } else {
        // Login gagal (status code bukan 200)
        setState(() {
          _loginSuccess = false;
          _globalMessage =
              responseData['error'] ?? "Email atau password salah.";
        });
        print("API Login Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // Handle error jaringan atau lainnya
      setState(() {
        _globalMessage = "Password Salah";
        _loginSuccess = false;
      });
      print("Network/API Call Error: $e");
    } finally {
      setState(() {
        _isAuthenticating =
            false; // Nonaktifkan loading terlepas dari sukses/gagal
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
            flex:
                1, // Memastikan container putih mengambil semua sisa ruang vertikal yang tersedia
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40.0), // Melengkungkan hanya sisi atas
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  autovalidateMode: AutovalidateMode
                      .onUserInteraction, // Validasi saat pengguna interaksi
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- Pesan Sukses/Error Global ---
                      if (_globalMessage.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.only(bottom: 20.0),
                          decoration: BoxDecoration(
                            color: _loginSuccess
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: _loginSuccess
                                    ? Colors.green.shade400
                                    : Colors.red.shade400),
                          ),
                          child: Text(
                            _globalMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _loginSuccess
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // --- Logo dan Label Pharmacy ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SvgPicture.asset(
                            'assets/images/logo.svg', // Pastikan path ini benar di proyek Anda
                            height: 50, // Sesuaikan ukuran logo
                            width: 50,
                          ),
                          const SizedBox(
                              width: 5), // Jarak antara logo dan teks
                          Text(
                            'Pharmacy',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor, // Menggunakan warna #1D242E
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                          height:
                              20.0), // Jarak antara logo/label dengan judul "LOGIN"

                      Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor, // Menggunakan warna #2A4D69
                        ),
                      ),
                      const SizedBox(
                          height: 15.0), // Jarak di bawah judul "LOGIN"

                      Text(
                        'Masuk untuk mengelola sistem dan\noperasional apotek.',
                        textAlign: TextAlign.center, // Pusatkan teks deskripsi
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                          color: blackTextColor, // Menggunakan warna #000000
                        ),
                      ),
                      const SizedBox(
                          height: 40.0), // Jarak ke input form pertama

                      // --- Input Email ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController, // Kaitkan controller
                            validator:
                                _validateEmail, // Menggunakan validator yang sudah dibuat
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              label: null, // Label sudah di atas TextFormField
                              hintText: 'Masukkan Email',
                              hintStyle: TextStyle(color: hintAndLabelColor),
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black12), // Warna disamakan
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: primaryColor), // Warna disamakan
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorStyle: const TextStyle(
                                  height: 0,
                                  fontSize: 0), // Sembunyikan teks error
                            ),
                            onChanged: (value) {
                              setState(() {
                                _emailError = '';
                                _globalMessage = '';
                              });
                              _formSignInKey.currentState
                                  ?.validate(); // Validasi untuk update formKey
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // --- Input Password ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller:
                                _passwordController, // Kaitkan controller
                            obscureText:
                                _obscureText, // Kontrol visibilitas password
                            obscuringCharacter: '*',
                            validator:
                                _validatePassword, // Menggunakan validator yang sudah dibuat
                            decoration: InputDecoration(
                              label: null, // Label sudah di atas TextFormField
                              hintText: 'Masukkan Password',
                              hintStyle: TextStyle(color: hintAndLabelColor),
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black12), // Warna disamakan
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: primaryColor), // Warna disamakan
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: primaryColor, // Warna ikon visibilitas
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText =
                                        !_obscureText; // Toggle visibilitas
                                  });
                                },
                              ),
                              errorStyle: const TextStyle(
                                  height: 0,
                                  fontSize: 0), // Sembunyikan teks error
                            ),
                            onChanged: (value) {
                              setState(() {
                                _passwordError = '';
                                _globalMessage = '';
                              });
                              _formSignInKey.currentState
                                  ?.validate(); // Validasi untuk update formKey
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // --- Checkbox "Ingat saya" (tetap di kiri) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor:
                                    primaryColor, // Warna checkbox aktif: #2A4D69
                              ),
                              const Text(
                                'Ingat saya',
                                style: TextStyle(
                                  color: Colors
                                      .black45, // Warna teks abu-abu gelap
                                ),
                              ),
                            ],
                          ),
                          // Tidak ada "Lupa Password?" di sini, dipindahkan ke bawah tombol Login
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // --- Tombol Login ---
                      SizedBox(
                        width: double.infinity, // Lebar penuh
                        child: ElevatedButton(
                          onPressed: _isAuthenticating
                              ? null
                              : _handleSubmit, // Nonaktifkan saat loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryColor.withOpacity(0.9), // Warna tombol
                            foregroundColor: Colors.white, // Warna teks tombol
                            disabledBackgroundColor: primaryColor
                                .withOpacity(0.5), // Warna saat disabled
                            disabledForegroundColor: Colors.white
                                .withOpacity(0.5), // Warna teks saat disabled
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Sudut tombol melengkung
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15), // Padding vertikal tombol
                          ),
                          child: _isAuthenticating
                              ? const CircularProgressIndicator(
                                  color: Colors.white) // Tampilkan loading
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // --- Link untuk lupa password ---
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Lupa password? ', // Bagian teks pertama
                              style: TextStyle(
                                color: Colors
                                    .black, // Warna hitam untuk teks biasa
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) =>
                                        const ForgetPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Klik disini', // Bagian teks kedua yang clickable
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor, // Warna link #2A4D69
                                  decoration: TextDecoration
                                      .underline, // Underline untuk efek link
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // --- Divider "Atau" ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(
                                  0.5), // Warna divider abu-abu transparan
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Atau', // Teks "Atau"
                              style: TextStyle(
                                color: Colors
                                    .black45, // Warna teks "Atau" abu-abu gelap
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(
                                  0.5), // Warna divider abu-abu transparan
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // --- Tombol login dengan akun sosial ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialButton(Logo(Logos.google)),
                          _buildSocialButton(Logo(Logos.apple)),
                          _buildSocialButton(Logo(Logos.facebook_f)),
                        ],
                      ),
                      const SizedBox(
                          height: 20.0), // Padding di bagian paling bawah form
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

  // Helper method untuk membuat tombol sosial media dari icons_plus
  Widget _buildSocialButton(Widget iconWidget) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        // Menggunakan InkWell untuk efek ripple
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Login dengan Sosial Media (simulasi)')),
          );
          // TODO: Implementasi logika login sosial media di sini
        },
        child: Center(child: iconWidget), // Menggunakan iconWidget langsung
      ),
    );
  }
}
