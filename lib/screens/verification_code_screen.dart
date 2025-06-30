// lib/screens/verification_code_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Digunakan untuk SVG logo
import 'package:http/http.dart' as http; // Import package http
import 'dart:convert'; // Import untuk menggunakan json.decode dan json.encode
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan userId sementara

// Asumsi file-file ini ada di proyek Anda
import 'package:login_signup/widgets/custom_scaffold.dart'; // Widget CustomScaffold Anda
import 'package:login_signup/screens/signin_screen.dart'; // Halaman SigninScreen Anda
import 'package:login_signup/screens/new_password_screen.dart'; // Halaman NewPasswordScreen Anda

class VerificationCodeScreen extends StatefulWidget {
  // Properti untuk menerima email dari halaman sebelumnya (ForgetPasswordScreen)
  final String email;

  const VerificationCodeScreen({super.key, required this.email});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  // List Controllers dan FocusNodes untuk 6 kotak input OTP
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (index) => FocusNode());

  // Definisi warna yang konsisten dengan desain Anda
  final Color primaryColor = const Color(0xFF2A4D69); // Warna utama
  final Color darkTextColor = const Color(
      0xFF1D242E); // Warna teks gelap untuk judul seperti "Pharmacy"
  final Color blackTextColor = const Color(0xFF000000); // Warna hitam murni

  String _errorMessage = ''; // State untuk menampilkan pesan error
  bool _isLoading = false; // State untuk indikator loading

  @override
  void initState() {
    super.initState();
    // Menambahkan listener ke setiap controller OTP untuk mengontrol fokus
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        final text = _otpControllers[i].text;
        // Pastikan hanya satu digit dan itu angka
        if (text.length > 1) {
          _otpControllers[i].text = text.substring(0, 1);
        }

        // Pindah fokus ke kotak berikutnya jika 1 digit dimasukkan dan bukan kotak terakhir
        if (_otpControllers[i].text.isNotEmpty &&
            i < _otpControllers.length - 1) {
          _otpFocusNodes[i + 1].requestFocus();
        }
        // Pindah fokus ke kotak sebelumnya jika kotak kosong (dihapus) dan bukan kotak pertama
        else if (_otpControllers[i].text.isEmpty && i > 0) {
          _otpFocusNodes[i - 1].requestFocus();
        }
        // Hapus pesan error saat pengguna mulai mengetik lagi atau kotak terisi/kosong
        setState(() {
          _errorMessage = '';
        });
      });
    }
  }

  @override
  void dispose() {
    // Pastikan semua controller dan focus node dibuang untuk mencegah memory leak
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Fungsi untuk memverifikasi kode OTP dengan API
  Future<void> _verifyOtp() async {
    final String otpCode = _otpControllers
        .map((c) => c.text.trim())
        .join(); // Gabungkan semua digit menjadi satu string

    // Validasi panjang kode di sisi klien
    if (otpCode.length != 6) {
      setState(() {
        _errorMessage = "Kode verifikasi harus 6 digit.";
      });
      return;
    }

    setState(() {
      _errorMessage = ''; // Reset error sebelum request
      _isLoading = true; // Aktifkan loading
    });

    // URL API yang di-deploy
    final String apiUrl =
        "https://ti054b05.agussbn.my.id/api/user/verify-reset-code";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': widget
              .email, // Gunakan email yang diterima dari halaman sebelumnya
          'code': otpCode, // Kirim kode OTP yang dimasukkan pengguna
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Pastikan user_id tidak null atau kosong dari respons API backend
        final String? userId = responseData['user_id'];
        if (userId == null || userId.isEmpty) {
          setState(() {
            _errorMessage =
                "Respons API tidak memiliki User ID yang valid. Coba kirim ulang kode.";
          });
          print(
              "API Error: User ID is null or empty in response. Full response: ${response.body}");
          return; // Hentikan proses jika userId tidak valid
        }

        // Simpan userId dan email di SharedPreferences untuk digunakan di halaman selanjutnya
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_reset_user_id', userId);
        await prefs.setString(
            'current_reset_email', widget.email); // Simpan email juga

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData['message'] ?? 'Kode verifikasi berhasil!')),
        );
        // Navigasi ke halaman buat password baru setelah verifikasi sukses
        // Gunakan pushReplacement agar pengguna tidak bisa kembali ke halaman verifikasi kode
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewPasswordScreen()),
        );
      } else {
        // Jika status code bukan 200 (misal 400, 401, 404, 500)
        final errorData = json.decode(response.body);
        setState(() {
          // Ambil pesan error dari respons API, jika tidak ada, gunakan pesan default
          _errorMessage = errorData['error'] ??
              "Kode verifikasi salah atau sudah kadaluarsa.";
        });
        print("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // Handle network errors (e.g., no internet, server not reachable)
      setState(() {
        _errorMessage = "Kode Verifikasi Salah";
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
    // Tombol "Kirim" akan nonaktif jika ada kotak OTP yang masih kosong atau sedang loading
    // atau jika _isLoading adalah true
    final bool isSubmitDisabled =
        _otpControllers.any((controller) => controller.text.isEmpty) ||
            _isLoading;

    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 0,
            child: SizedBox(height: 0),
          ),
          Expanded(
            flex:
                1, // Memastikan kontainer putih mengambil semua sisa ruang vertikal yang tersedia.
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40.0), // Melengkungkan hanya sisi atas
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                        const SizedBox(width: 5), // Jarak antara logo dan teks
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
                    const SizedBox(height: 20.0), // Jarak di bawah logo

                    // --- Judul "Periksa Email Kamu" ---
                    Text(
                      'Periksa Email Kamu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                        color: primaryColor, // Menggunakan warna #2A4D69
                      ),
                    ),
                    const SizedBox(height: 15.0), // Jarak di bawah judul

                    // --- Teks Deskripsi ---
                    Text(
                      'Kami Mengirim link reset ke Email kamu.\nMasukkan 6 digit kode yang ada di Email kamu.',
                      textAlign: TextAlign.center, // Pusatkan teks deskripsi
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                        color: blackTextColor, // Menggunakan warna #000000
                      ),
                    ),
                    const SizedBox(height: 40.0), // Jarak ke input OTP

                    // --- Kotak Input OTP (6 digit) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6, // Jumlah kotak OTP
                        (index) => SizedBox(
                          width: 50, // Lebar setiap kotak input
                          height: 50, // Tinggi setiap kotak input
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            keyboardType: TextInputType.number, // Hanya angka
                            textAlign: TextAlign.center, // Teks di tengah kotak
                            maxLength: 1, // Hanya satu karakter per kotak
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: blackTextColor,
                            ),
                            decoration: InputDecoration(
                              counterText:
                                  "", // Menyembunyikan hitungan karakter
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 0.0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: primaryColor, // Warna border utama
                                  width: 3.0, // Ketebalan border
                                ),
                                borderRadius: BorderRadius.circular(
                                    10), // Sudut melengkung
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      primaryColor, // Warna border saat tidak fokus
                                  width: 3.0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      primaryColor, // Warna border saat fokus
                                  width: 3.0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                // Panggil setState agar isSubmitDisabled dievaluasi ulang
                                // dan pesan error hilang saat mulai mengetik
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    // --- Pesan Error (jika ada) ---
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 40.0), // Jarak sebelum tombol

                    // --- Tombol "Kirim" ---
                    SizedBox(
                      width: double.infinity, // Lebar penuh
                      child: ElevatedButton(
                        onPressed: isSubmitDisabled
                            ? null
                            : _verifyOtp, // Nonaktif jika kode belum lengkap atau sedang loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor
                              .withOpacity(0.9), // Warna saat aktif (90%)
                          disabledBackgroundColor: primaryColor
                              .withOpacity(0.5), // Warna saat tidak aktif (50%)
                          foregroundColor:
                              Colors.white, // Warna teks tombol saat aktif
                          disabledForegroundColor: Colors.white.withOpacity(
                              0.5), // Warna teks tombol saat tidak aktif
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Sudut tombol melengkung
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15), // Padding vertikal tombol
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white) // Tampilkan loading spinner
                            : const Text(
                                'Kirim',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 25.0), // Jarak di bawah tombol

                    // --- Link "Kembali ke halaman Login" ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Kembali ke halaman ',
                          style: TextStyle(
                            color: Colors.black45, // Warna teks abu-abu gelap
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Menggunakan pushReplacement agar tidak bisa kembali dengan tombol back ke halaman ini
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
                    const SizedBox(
                        height: 20.0), // Padding di bagian paling bawah
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
