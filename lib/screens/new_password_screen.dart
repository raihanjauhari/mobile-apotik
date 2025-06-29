import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk SVG logo jika digunakan
// Asumsi CustomScaffold ada dan menangani latar belakang umum
import '../widgets/custom_scaffold.dart';
import 'signin_screen.dart'; // Untuk navigasi kembali ke login

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State untuk toggle visibilitas password
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // State untuk pesan error
  String _passwordError = '';
  String _confirmPasswordError = '';
  String _errorMessage = ''; // Error global
  bool _showSuccessModal = false; // State untuk menampilkan modal sukses

  // Mendefinisikan warna heksadesimal sesuai dengan desain web
  final Color primaryColor = const Color(0xFF2A4D69); // Warna utama
  final Color darkTextColor = const Color(0xFF1D242E); // Warna teks gelap
  final Color blackTextColor = const Color(0xFF000000); // Warna hitam murni
  final Color hintAndLabelColor = Colors.black54; // Ini sudah ditambahkan

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi validasi password sesuai logika ReactJS
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
    return null; // Validasi sukses
  }

  // Fungsi handleSubmit
  void _handleSubmit() {
    // Reset semua pesan error sebelumnya
    setState(() {
      _passwordError = '';
      _confirmPasswordError = '';
      _errorMessage = '';
    });

    // Panggil validate() pada FormKey untuk menjalankan validator di semua TextFormField
    if (_formKey.currentState!.validate()) {
      // Validasi password (custom)
      final String? passwordValidation =
          _validatePassword(_passwordController.text);
      if (passwordValidation != null) {
        setState(() {
          _passwordError = passwordValidation;
        });
        return;
      }

      // Validasi konfirmasi password
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _confirmPasswordError = "Konfirmasi password tidak cocok.";
        });
        return;
      }

      // --- Simulasi Logika API (sesuai "tidak pakai api kok") ---
      // Karena tidak ada API, kita langsung anggap sukses
      print(
          "Mengubah password untuk email ... dengan password: ${_passwordController.text}");

      // Menampilkan modal sukses setelah password dianggap berhasil diubah
      setState(() {
        _showSuccessModal = true;
      });

      // Bersihkan field password setelah sukses
      _passwordController.clear();
      _confirmPasswordController.clear();
    } else {
      // Jika validasi form dasar gagal
      setState(() {
        _errorMessage = "Mohon lengkapi semua field dengan benar.";
      });
    }
  }

  // Fungsi untuk tombol "Lanjutkan" pada modal sukses
  void _handleSuccessModalContinue() {
    setState(() {
      _showSuccessModal = false;
    });
    // Navigasi ke halaman login dan hapus semua rute sebelumnya
    // Hapus data reset_email dan reset_code jika disimpan di SharedPreferences/localStorage sebelumnya
    // SharedPreferences.getInstance().then((prefs) => prefs.remove('reset_email'));
    // SharedPreferences.getInstance().then((prefs) => prefs.remove('reset_code'));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tombol "Ubah Password" akan dinonaktifkan jika ada field yang kosong
    // atau jika validasi awal belum memenuhi (misal, panjang password min)
    final bool isSubmitDisabled = _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _validatePassword(_passwordController.text) !=
            null || // Tambahkan validasi password ke disabled state
        _passwordController.text !=
            _confirmPasswordController
                .text; // Juga jika confirm password tidak cocok

    return CustomScaffold(
      // Menggunakan CustomScaffold untuk latar belakang
      child: Stack(
        // Menggunakan Stack agar modal bisa overlay
        children: [
          Column(
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
                      top: Radius.circular(40.0), // Rounded top corners
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode
                          .onUserInteraction, // Validasi saat pengguna interaksi
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- Logo dan Label Pharmacy ---
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

                          // --- Judul "Buat Password Baru" ---
                          Text(
                            'Buat Password Baru',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 35.0,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 15.0),

                          // --- Deskripsi ---
                          Text(
                            'Buat Password yang berbeda dari sebelumnya untuk keamanan akun Anda',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.normal,
                              color: blackTextColor,
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          // --- Pesan Error Global (jika ada) ---
                          if (_errorMessage.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              margin: const EdgeInsets.only(bottom: 20.0),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.red.shade400),
                              ),
                              child: Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          // --- Input Password Baru ---
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
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Password',
                                  hintStyle:
                                      TextStyle(color: hintAndLabelColor),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: primaryColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    // Border saat ada error
                                    borderSide: const BorderSide(
                                        color:
                                            Colors.black12), // Warna disamakan
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    // Border saat ada error dan fokus
                                    borderSide: BorderSide(
                                        color: primaryColor), // Warna disamakan
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorStyle: const TextStyle(
                                      height: 0,
                                      fontSize: 0), // Sembunyikan teks error
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  // Kosongkan error saat mengetik
                                  setState(() {
                                    _passwordError = '';
                                    _errorMessage = '';
                                  });
                                  // Re-validate form when text changes to update button state
                                  _formKey.currentState?.validate();
                                },
                                // Menggunakan validator untuk validasi form yang terintegrasi
                                validator: _validatePassword,
                              ),
                            ],
                          ),
                          const SizedBox(height: 25.0),

                          // --- Input Konfirmasi Password ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konfirmasi Password',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500),
                              ),
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
                                    borderSide: BorderSide(color: primaryColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    // Border saat ada error
                                    borderSide: const BorderSide(
                                        color:
                                            Colors.black12), // Warna disamakan
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    // Border saat ada error dan fokus
                                    borderSide: BorderSide(
                                        color: primaryColor), // Warna disamakan
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  // --- PERUBAHAN DI SINI: Sembunyikan errorText ---
                                  errorStyle:
                                      const TextStyle(height: 0, fontSize: 0),
                                  // --- AKHIR PERUBAHAN ---
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showConfirmPassword =
                                            !_showConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  // Kosongkan error saat mengetik
                                  setState(() {
                                    _confirmPasswordError = '';
                                    _errorMessage = '';
                                  });
                                  // Re-validate form when text changes to update button state
                                  _formKey.currentState?.validate();
                                },
                                // Validator untuk konfirmasi password bisa lebih sederhana, cek kecocokan saat submit
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Konfirmasi password tidak boleh kosong.";
                                  }
                                  if (value != _passwordController.text) {
                                    return "Konfirmasi password tidak cocok.";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 30.0),

                          // --- Tombol "Ubah Password" (Selalu Aktif) ---
                          SizedBox(
                            width: double.infinity, // Lebar penuh
                            child: ElevatedButton(
                              onPressed:
                                  _handleSubmit, // LANGSUNG PANGGIL _handleSubmit
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor.withOpacity(
                                    0.9), // Warna selalu 90% opasitas
                                foregroundColor: Colors.white, // Warna teks
                                // disabledBackgroundColor dan disabledForegroundColor tidak diperlukan
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                'Ubah Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 20.0), // Padding di bagian bawah
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- Modal Berhasil (mengikuti desain ReactJS) ---
          if (_showSuccessModal)
            Container(
              color: Colors.black.withOpacity(0.5), // Background gelap
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Sudut melengkung
                ),
                contentPadding: const EdgeInsets.all(24.0),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BERHASIL',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Menggunakan ikon check_circle_outline sebagai pengganti SuccessIcon
                    Icon(
                      Icons.check_circle_outline,
                      color: primaryColor,
                      size: 100, // Sesuaikan ukuran ikon
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Selamat! Password Anda berhasil dibuat. Klik "Lanjutkan" untuk login.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSuccessModalContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryColor, // Warna tombol lanjutkan
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Lanjutkan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
