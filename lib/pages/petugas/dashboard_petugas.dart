import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Import CustomHeader
import 'package:login_signup/widgets/menu.dart'; // Import CustomBottomNavBar
import 'package:login_signup/screens/signin_screen.dart'; // Pastikan import ini benar

// Impor halaman-halaman yang akan dinavigasikan
import 'package:login_signup/pages/petugas/eresep.dart'; // <<< IMPOR BARU
import 'package:login_signup/pages/petugas/obat.dart'; // <<< IMPOR BARU
import 'package:login_signup/pages/petugas/akun.dart'; // <<< IMPOR BARU

class DashboardPetugas extends StatefulWidget {
  const DashboardPetugas({super.key});

  @override
  State<DashboardPetugas> createState() => _DashboardPetugasState();
}

class _DashboardPetugasState extends State<DashboardPetugas> {
  // --- Colors ---
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color secondaryColor = const Color(0xFF6B8FB4);
  final Color accentColor = const Color(0xFFF0F4F8);

  // --- Mock Data ---
  final List<Map<String, dynamic>> _mockObatList = [
    {'kode_obat': 'OBT001', 'nama_obat': 'Paracetamol', 'stok': 150},
    {
      'kode_obat': 'OBT002',
      'nama_obat': 'Amoxicillin',
      'stok': 5
    }, // Hampir habis
    {'kode_obat': 'OBT003', 'nama_obat': 'Vitamin C', 'stok': 200},
    {'kode_obat': 'OBT004', 'nama_obat': 'Ibuprofen', 'stok': 0}, // Habis
    {'kode_obat': 'OBT005', 'nama_obat': 'Antasida', 'stok': 8}, // Hampir habis
    {'kode_obat': 'OBT006', 'nama_obat': 'Obat Batuk', 'stok': 0}, // Habis
    {'kode_obat': 'OBT007', 'nama_obat': 'Salep Kulit', 'stok': 70},
  ];

  final List<Map<String, dynamic>> _mockEresepList = [
    {'kode_eresep': 'ER001', 'status': 'Menunggu Pembayaran'},
    {'kode_eresep': 'ER002', 'status': 'Selesai'},
    {'kode_eresep': 'ER003', 'status': 'Menunggu Pembayaran'},
    {'kode_eresep': 'ER004', 'status': 'Diproses'},
    {'kode_eresep': 'ER005', 'status': 'Selesai'},
    {'kode_eresep': 'ER006', 'status': 'Menunggu Pembayaran'},
  ];

  final List<Map<String, dynamic>> _mockPembelianObatList = [
    {'kode_obat': 'OBT001', 'kuantitas': 5},
    {'kode_obat': 'OBT003', 'kuantitas': 10},
    {'kode_obat': 'OBT001', 'kuantitas': 3},
    {'kode_obat': 'OBT005', 'kuantitas': 2},
    {'kode_obat': 'OBT003', 'kuantitas': 7},
    {'kode_obat': 'OBT001', 'kuantitas': 8},
  ];

  final List<Map<String, dynamic>> _mockPasienList = [
    {'id_pasien': 'PSN001'},
    {'id_pasien': 'PSN002'},
    {'id_pasien': 'PSN003'},
    {'id_pasien': 'PSN004'},
    {'id_pasien': 'PSN005'},
  ];

  // --- Dashboard Data Variables ---
  Map<String, dynamic> _medicineStockStatus = {
    "aman": {"label": "Aman", "count": 0},
    "hampirHabis": {"label": "Hampir Habis", "count": 0},
    "habis": {"label": "Habis", "count": 0},
  };

  int _totalEresep = 0;
  int _eresepMenungguPembayaran = 0;
  int _pembayaranSelesai =
      0; // This variable is processed but not used in the UI
  int _totalPelanggan = 0; // This variable is processed but not used in the UI
  String _mostPurchasedMedicine = "N/A";

  // --- UI State Variables ---
  int _selectedIndex = 0;
  int? _hoveredCardIndex;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _processLocalData();
    // PERBAIKAN UNTUK ERROR ScrollController
    _scrollController.addListener(() {
      _scrollListener();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener); // Gunakan juga di sini
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Methods ---

  /// Listens to scroll events to show/hide the scroll-to-top button.
  void _scrollListener() {
    setState(() {
      _showScrollToTopButton = _scrollController.offset >= 400;
    });
  }

  /// Processes local mock data to update dashboard statistics.
  void _processLocalData() {
    int amanCount = 0;
    int hampirHabisCount = 0;
    int habisCount = 0;

    // Calculate medicine stock status
    for (var obat in _mockObatList) {
      int stok = obat['stok'] as int;
      if (stok >= 10) {
        amanCount++;
      } else if (stok > 0 && stok < 10) {
        hampirHabisCount++;
      } else if (stok == 0) {
        habisCount++;
      }
    }

    // Calculate e-prescription status
    int totalEresepCount = _mockEresepList.length;
    int eresepBaruCount = _mockEresepList
        .where((item) => item['status'] == "Menunggu Pembayaran")
        .length;
    int pembayaranSelesaiCount =
        _mockEresepList.where((item) => item['status'] == "Selesai").length;
    int totalPelangganCount = _mockPasienList.length;

    // Calculate most frequently purchased medicine
    Map<String, int> medicineQuantityMap = {};
    for (var item in _mockPembelianObatList) {
      String kodeObat = item['kode_obat'] as String;
      int kuantitas = item['kuantitas'] as int;
      medicineQuantityMap[kodeObat] =
          (medicineQuantityMap[kodeObat] ?? 0) + kuantitas;
    }

    String mostFrequentObatName = "N/A";
    int maxKuantitas = 0;

    medicineQuantityMap.forEach((kodeObat, kuantitas) {
      if (kuantitas > maxKuantitas) {
        maxKuantitas = kuantitas;
        final foundObat = _mockObatList.firstWhere(
          (obat) => obat['kode_obat'] == kodeObat,
          orElse: () => {'nama_obat': 'N/A'},
        );
        mostFrequentObatName = foundObat['nama_obat'] as String;
      }
    });

    setState(() {
      _medicineStockStatus = {
        "aman": {"label": "Aman", "count": amanCount},
        "hampirHabis": {"label": "Hampir Habis", "count": hampirHabisCount},
        "habis": {"label": "Habis", "count": habisCount},
      };
      _totalEresep = totalEresepCount;
      _eresepMenungguPembayaran = eresepBaruCount;
      _pembayaranSelesai = pembayaranSelesaiCount;
      _totalPelanggan = totalPelangganCount;
      _mostPurchasedMedicine = mostFrequentObatName;
    });
  }

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

  // --- Widget Builders ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: CustomHeader(
        primaryColor: primaryColor,
        // LOGIKA onNotificationPressed: akan menampilkan pop-up
        onNotificationPressed: () {
          _showSimpleModal(
              'Notifikasi', 'Anda memiliki beberapa notifikasi baru.');
        },
        searchController: _searchController,
        onSearchChanged: (text) {
          // Handle search text changes
          print('Search text: $text');
        },
        searchHintText: 'Cari...',
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // "Healing begins..." section with doctor image and quote
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20.0),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              secondaryColor.withOpacity(0.9),
                              primaryColor.withOpacity(0.9)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 100),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.format_quote,
                                      color: Colors.white, size: 30),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Kesehatan Anda adalah prioritas kami. Apotek, mitra terpercaya dalam setiap langkah penyembuhan.',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 25,
                        left: 25,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(2, 4),
                                )
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/doctor_image.png',
                              height: 130,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading doctor image: $error');
                                return Container(
                                  height: 130,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error_outline,
                                      size: 80, color: Colors.red),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info Cards Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.2,
                    children: [
                      // 'GOOD' Status Card
                      _buildInfoCard(
                        cardIndex: 0,
                        icon: Icons.shield,
                        iconColor: Colors.green,
                        title: 'GOOD',
                        subtitle: 'Status Inventaris',
                        detailText: 'Lihat Detail Laporan',
                        // UBAH LOGIKA onClick DI SINI untuk pop-up
                        onClick: () => _showSimpleModal('Status Inventaris',
                            'Ini adalah detail laporan status inventaris.'),
                        isSpecialCard: true,
                      ),

                      // Incoming E-Prescriptions
                      _buildInfoCard(
                        cardIndex: 1,
                        icon: Icons.inbox,
                        iconColor: Colors.amber[700]!,
                        title: _eresepMenungguPembayaran.toString(),
                        subtitle: 'E-Resep Masuk',
                        detailText: 'Lihat Detail Laporan',
                        // UBAH LOGIKA onClick DI SINI untuk pop-up
                        onClick: () => _showSimpleModal('E-Resep Masuk',
                            'Ini adalah detail e-resep yang masuk.'),
                      ),

                      // Low Stock Medicine
                      _buildInfoCard(
                        cardIndex: 2,
                        icon: Icons.medical_services,
                        iconColor: Colors.blue,
                        title: (_medicineStockStatus["hampirHabis"]["count"])
                            .toString(),
                        subtitle: 'Obat Hampir Habis',
                        detailText: 'Lihat Persediaan',
                        // UBAH LOGIKA onClick DI SINI untuk pop-up
                        onClick: () => _showSimpleModal('Obat Hampir Habis',
                            'Ini adalah daftar obat yang hampir habis.'),
                      ),

                      // Out of Stock Medicine
                      _buildInfoCard(
                        cardIndex: 3,
                        icon: Icons.warning,
                        iconColor: Colors.red,
                        title:
                            _medicineStockStatus["habis"]["count"].toString(),
                        subtitle: 'Obat Habis',
                        detailText: 'Stok Sekarang',
                        // UBAH LOGIKA onClick DI SINI untuk pop-up
                        onClick: () => _showSimpleModal(
                            'Obat Habis', 'Ini adalah daftar obat yang habis.'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Online Medicine Orders Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pemesanan Obat Online',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Ini tetap modal sederhana karena belum ada halaman spesifik "Lihat Semua Layanan Medis"
                          _showSimpleModal('Layanan Medis',
                              'Fitur "Lihat Semua" untuk layanan medis.');
                        },
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(color: primaryColor, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Text(
                    'Lihat daftar layanan yang sesuai.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: [
                      // Chip-chip ini bisa dinavigasikan ke halaman ObatPage jika diklik
                      // Untuk demo ini, tidak ada aksi onTap di sini, hanya visual.
                      _buildMedicalServiceChip(
                          Icons.local_hospital, 'Obat Paru-paru'),
                      _buildMedicalServiceChip(Icons.water_drop, 'Obat Ginjal'),
                      _buildMedicalServiceChip(
                          Icons.remove_red_eye, 'Obat Mata'),
                      _buildMedicalServiceChip(
                          Icons.medical_services_outlined, 'Umum'),
                      _buildMedicalServiceChip(
                          Icons.health_and_safety, 'Obat Khusus'),
                      _buildMedicalServiceChip(Icons.sick, 'Obat Lambung'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recommendations Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Rekomendasi untukmu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      // Untuk rekomendasi ini, tidak ada navigasi yang diminta, jadi hanya visual
                      _buildMedicineCard(
                        'assets/images/medicine_example_1.png',
                        'Contoh obat',
                        'Rp. 20.000',
                      ),
                      const SizedBox(width: 16),
                      _buildMedicineCard(
                        'assets/images/medicine_example_2.png',
                        'Contoh obat',
                        'Rp. 27.000',
                      ),
                      const SizedBox(width: 16),
                      _buildMedicineCard(
                        'assets/images/medicine_example_3.png',
                        'Contoh obat',
                        'Rp. 29.000',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Summary Sections (Stock and E-Resep)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummarySection(
                        title: "Stock",
                        linkText: "Lihat Stok",
                        // UBAH LOGIKA linkAction DI SINI untuk pop-up
                        linkAction: () => _showSimpleModal('Ringkasan Stok',
                            'Ini adalah ringkasan stok obat.'),
                        children: [
                          _buildSummaryItem(
                            _mockObatList.length.toString(),
                            "Jumlah Obat",
                            Icons.medical_services,
                            Colors.blue,
                          ),
                          _buildSummaryItem(
                            _medicineStockStatus["habis"]["count"].toString(),
                            "Obat Habis",
                            Icons.warning_amber_rounded,
                            Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSummarySection(
                        title: "e-Eresep",
                        linkText: "Lihat e-Resep",
                        // UBAH LOGIKA linkAction DI SINI untuk pop-up
                        linkAction: () => _showSimpleModal('Ringkasan E-Resep',
                            'Ini adalah ringkasan e-resep.'),
                        children: [
                          _buildSummaryItem(
                            _eresepMenungguPembayaran.toString(),
                            "e-Eresep Baru",
                            Icons.receipt_long,
                            Colors.orange,
                          ),
                          _buildSummaryItem(
                            _totalEresep.toString(),
                            "Jumlah e-Eresep",
                            Icons.description_outlined,
                            Colors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // --- LOGIKA NAVIGASI DARI BOTTOM NAV BAR (TIDAK BERUBAH) ---
          if (index == 0) {
            // Ini tetap Dashboard, jadi cukup scroll ke atas
            _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          } else if (index == 1) {
            // Navigasi ke Halaman E-Resep (mengganti halaman saat ini)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EresepPage()),
            );
          } else if (index == 2) {
            // Navigasi ke Halaman Obat (mengganti halaman saat ini)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObatPage()),
            );
          } else if (index == 3) {
            // Navigasi ke Halaman Akun (mengganti halaman saat ini)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunPage()),
            );
          } else if (index == 4) {
            // Asumsi ada 5 item di menu
            // Navigasi untuk Sign Out / Kembali ke Sign In Screen (menghapus riwayat)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (Route<dynamic> route) =>
                  false, // Menghapus semua route sebelumnya di stack
            );
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600]!,
        primaryColor: primaryColor,
      ),
      floatingActionButton: _showScrollToTopButton
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: primaryColor,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }

  /// Builds an information card for the dashboard grid.
  Widget _buildInfoCard({
    required int cardIndex,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String detailText,
    required VoidCallback onClick,
    bool isSpecialCard = false, // Added for potential special styling
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCardIndex = cardIndex),
      onExit: (_) => setState(() => _hoveredCardIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: iconColor, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: onClick,
              child: Container(
                decoration: BoxDecoration(
                  color: _hoveredCardIndex == cardIndex
                      ? primaryColor.withOpacity(1.0)
                      : primaryColor.withOpacity(0.85),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      detailText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    const Text('»',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a medical service chip.
  Widget _buildMedicalServiceChip(IconData icon, String label) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: secondaryColor.withOpacity(0.2),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  /// Builds a medicine recommendation card.
  Widget _buildMedicineCard(String imagePath, String name, String price) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              imagePath,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a summary section with a title, optional link, and child items.
  Widget _buildSummarySection({
    required String title,
    List<Widget>? children,
    String? linkText,
    VoidCallback? linkAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (linkText != null && linkAction != null)
                  TextButton(
                    onPressed: linkAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerRight,
                    ),
                    child: Row(
                      children: [
                        Text(linkText, style: TextStyle(color: primaryColor)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            size: 16, color: primaryColor),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            if (children != null) ...children,
          ],
        ),
      ),
    );
  }

  /// Builds an individual summary item with a value, label, icon, and color.
  Widget _buildSummaryItem(
      String value, String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
