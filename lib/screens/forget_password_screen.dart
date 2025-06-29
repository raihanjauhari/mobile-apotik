import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Digunakan untuk SVG logo

// Asumsi file-file ini ada di proyek Anda
import '../widgets/custom_scaffold.dart'; // Widget CustomScaffold Anda
import 'signin_screen.dart'; // Halaman SignInScreen Anda
import 'verification_code_screen.dart'; // Halaman VerificationCodeScreen Anda

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formForgetPasswordKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  // Define hexadecimal colors according to the web design
  final Color primaryColor = const Color(0xFF2A4D69); // Main color
  final Color darkTextColor =
      const Color(0xFF1D242E); // Dark text color for titles like "Pharmacy"
  final Color blackTextColor = const Color(0xFF000000); // Pure black color
  final Color hintAndLabelColor =
      Colors.black54; // Color for hint and label input fields

  // --- STATE BARU SESUAI LOGIKA REACTJS ---
  String _emailError = ''; // Error spesifik untuk field email
  String _globalMessage = ''; // Pesan global (sukses/error)
  bool _sendSuccess = false; // Status pengiriman email sukses
  // --- AKHIR STATE BARU ---

  @override
  void dispose() {
    _emailController.dispose(); // Pastikan controller dibuang
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

  // Fungsi handle submit (sesuai logika ReactJS)
  void _handleSubmit() {
    // Reset semua pesan sebelum submit
    setState(() {
      _emailError = '';
      _globalMessage = '';
      _sendSuccess = false;
    });

    if (_formForgetPasswordKey.currentState!.validate()) {
      // Validasi tambahan jika diperlukan (sudah di handle validator)
      // Simulasi API call (karena "tidak pakai api kok")
      print("Mencoba mengirim tautan reset ke: ${_emailController.text}");

      // --- LOGIKA SIMULASI RESPON BACKEND ---
      // Jika email adalah 'test@example.com', anggap sukses
      // Jika email adalah 'error@example.com', anggap gagal
      // Lainnya juga sukses untuk alur dasar
      if (_emailController.text == 'error@example.com') {
        setState(() {
          _sendSuccess = false;
          _globalMessage =
              "Gagal mengirim email reset. Email mungkin tidak terdaftar.";
        });
      } else {
        setState(() {
          _sendSuccess = true;
          _globalMessage = "Email reset password berhasil dikirim!";
        });
        // Navigasi ke halaman verifikasi kode setelah "sukses" mengirim email
        // Di sini Anda bisa meneruskan email ke halaman verifikasi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodeScreen(
              email: _emailController.text, // Meneruskan email
            ),
          ),
        );
      }
    } else {
      // Jika validasi form bawaan gagal, tampilkan pesan umum
      setState(() {
        _globalMessage = "Mohon perbaiki kesalahan input.";
        _sendSuccess = false; // Pastikan status sukses direset
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tombol "Kirim Tautan Reset" akan nonaktif jika email kosong atau tidak valid
    final bool isSubmitDisabled = _emailController.text.isEmpty ||
        !RegExp(r'\S+@\S+\.\S+').hasMatch(_emailController.text);

    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 0,
            child: SizedBox(
              height: 0,
            ),
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
                  key: _formForgetPasswordKey,
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
                            color: _sendSuccess
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: _sendSuccess
                                    ? Colors.green.shade400
                                    : Colors.red.shade400),
                          ),
                          child: Text(
                            _globalMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _sendSuccess
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
                            'assets/images/logo.svg',
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
                        'LUPA PASSWORD',
                        style: TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15.0),

                      Text(
                        'Masukkan e-mail yang terdaftar. Kami\nakan mengirimkan pesan untuk atur\nulang password Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                          color: blackTextColor,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // --- Email Input ---
                      TextFormField(
                        controller: _emailController,
                        validator:
                            _validateEmail, // Menggunakan validator yang sudah dibuat
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          labelStyle: TextStyle(color: primaryColor),
                          hintText: 'Masukkan Email Anda',
                          hintStyle: TextStyle(color: hintAndLabelColor),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // errorText: _emailError.isNotEmpty ? _emailError : null, // ErrorText dari validator Form
                        ),
                        onChanged: (value) {
                          // Mengosongkan pesan error global atau spesifik saat mengetik
                          setState(() {
                            _globalMessage = '';
                            _emailError =
                                ''; // Opsional, validator FormField sudah cukup
                          });
                          _formForgetPasswordKey.currentState
                              ?.validate(); // Panggil validate agar button state update
                        },
                      ),
                      const SizedBox(height: 25.0),

                      // --- Tombol "Kirim Tautan Reset" ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitDisabled ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor
                                .withOpacity(0.9), // Warna saat aktif
                            foregroundColor:
                                Colors.white, // Warna teks saat aktif
                            disabledBackgroundColor: primaryColor
                                .withOpacity(0.5), // Warna saat disabled
                            disabledForegroundColor: Colors.white
                                .withOpacity(0.5), // Warna teks saat disabled
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            'Kirim Tautan Reset',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // --- Tambahan: Teks "Tidak menerima email?" ---
                      const Text(
                        'Tidak menerima email? Periksa folder spam Anda atau coba lagi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 15.0),

                      // --- Link "Kirim Ulang Email" (Navigasi ke VerificationCodeScreen) ---
                      GestureDetector(
                        onTap: () {
                          // Jika email valid, navigasi ke VerificationCodeScreen
                          if (_emailController.text.isNotEmpty &&
                              RegExp(r'\S+@\S+\.\S+')
                                  .hasMatch(_emailController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Mengirim ulang email verifikasi...'),
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerificationCodeScreen(
                                  email:
                                      _emailController.text, // Teruskan email
                                ),
                              ),
                            );
                          } else {
                            // Tampilkan pesan jika email kosong/tidak valid
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Mohon masukkan email yang valid terlebih dahulu.'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Kirim Ulang Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // --- Link "Sudah ingat password? Login disini" ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah ingat password? ',
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Login disini',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80.0),
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
