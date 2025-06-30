import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Import CustomHeader
import 'package:login_signup/widgets/menu.dart'; // Import CustomBottomNavBar
import 'package:login_signup/screens/signin_screen.dart'; // Ensure this import is correct
import 'package:intl/intl.dart'; // Import for currency formatting

// Import HALAMAN-HALAMAN ADMIN lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/admin/eresep.dart'; // NEW ADMIN E-Resep
import 'package:login_signup/pages/admin/obat.dart'; // NEW ADMIN Obat
import 'package:login_signup/pages/admin/akun.dart'; // NEW ADMIN Akun

// Import the chart widgets
import 'package:login_signup/widgets/admin/laporan_penyakit_card.dart';
import 'package:login_signup/widgets/admin/apotik_chart_card.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  // --- Colors ---
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color secondaryColor = const Color(0xFF6B8FB4);
  final Color accentColor = const Color(0xFFF0F4F8);
  final Color successColor = const Color(0xFF4CAF50); // Green for GOOD status
  final Color warningColor = const Color(0xFFFFC107); // Amber for warning
  final Color dangerColor = const Color(0xFFF44336); // Red for danger/empty

  // --- Mock Data Obat ---
  // Data ini digunakan untuk statistik di ringkasan stok obat
  List<Map<String, dynamic>> _mockObatList = [
    {
      "kode_obat": "OBT001",
      "nama_obat": "Paracetamol 500mg",
      "stok": 150,
      "harga_satuan": 6000,
      "deskripsi": "Obat pereda nyeri dan demam.",
    },
    {
      "kode_obat": "OBT002",
      "nama_obat": "Amoxicillin 250mg",
      "stok": 80,
      "harga_satuan": 3000,
      "deskripsi": "Antibiotik untuk infeksi bakteri.",
    },
    {
      "kode_obat": "OBT003",
      "nama_obat": "Vitamin C 1000mg",
      "stok": 200,
      "harga_satuan": 75000,
      "deskripsi": "Suplemen untuk daya tahan tubuh.",
    },
    {
      "kode_obat": "OBT004",
      "nama_obat": "Ibuprofen 250mg",
      "stok": 0, // Stok Habis
      "harga_satuan": 12000,
      "deskripsi": "Obat anti-inflamasi non-steroid.",
    },
    {
      "kode_obat": "OBT005",
      "nama_obat": "Dexamethasone 0.5mg",
      "stok": 120,
      "harga_satuan": 1000,
      "deskripsi": "Obat kortikosteroid untuk alergi dan radang.",
    },
    {
      "kode_obat": "OBT006",
      "nama_obat": "Lansoprazole 30 mg",
      "stok": 90,
      "harga_satuan": 15000,
      "deskripsi": "Obat untuk meredakan gejala asam lambung.",
    },
    {
      "kode_obat": "OBT007",
      "nama_obat": "Betadine Solution",
      "stok": 50,
      "harga_satuan": 8000,
      "deskripsi": "Antiseptik untuk luka.",
    },
    {
      "kode_obat": "OBT008",
      "nama_obat": "Counterpain Cream",
      "stok": 0, // Stok Habis
      "harga_satuan": 12000,
      "deskripsi": "Krim pereda nyeri otot.",
    },
    {
      "kode_obat": "OBT009",
      "nama_obat": "Diapet",
      "stok": 75,
      "harga_satuan": 1500,
      "deskripsi": "Obat diare herbal.",
    },
    {
      "kode_obat": "OBT010",
      "nama_obat": "Bodrex Migra",
      "stok": 110,
      "harga_satuan": 1800,
      "deskripsi": "Obat untuk sakit kepala migrain.",
    },
    {
      "kode_obat": "OBT011",
      "nama_obat": "Promag",
      "stok": 0, // Stok Habis
      "harga_satuan": 1200,
      "deskripsi": "Obat sakit maag.",
    },
    {
      "kode_obat": "OBT012",
      "nama_obat": "Biogesic",
      "stok": 130,
      "harga_satuan": 1400,
      "deskripsi": "Paracetamol merek lain.",
    },
    {
      "kode_obat": "OBT013",
      "nama_obat": "Sanmol",
      "stok": 95,
      "harga_satuan": 1600,
      "deskripsi": "Obat penurun panas dan pereda nyeri.",
    },
    {
      "kode_obat": "OBT014",
      "nama_obat": "OBH Combi",
      "stok": 60,
      "harga_satuan": 7000,
      "deskripsi": "Obat batuk berdahak dan pilek.",
    },
    {
      "kode_obat": "OBT015",
      "nama_obat": "FreshCare Roll On",
      "stok": 25,
      "harga_satuan": 9500,
      "deskripsi": "Minyak angin aroma terapi.",
    },
  ];

  // Mock data untuk E-Resep
  final List<Map<String, dynamic>> _mockEresepList = [
    {'kode_eresep': 'ER001', 'status': 'Menunggu Pembayaran'},
    {'kode_eresep': 'ER002', 'status': 'Selesai'},
    {'kode_eresep': 'ER003', 'status': 'Menunggu Pembayaran'},
    {'kode_eresep': 'ER004', 'status': 'Diproses'},
    {'kode_eresep': 'ER005', 'status': 'Selesai'},
    {'kode_eresep': 'ER006', 'status': 'Menunggu Pembayaran'},
  ];

  // Mock data untuk Pembelian Obat (untuk obat terlaris)
  final List<Map<String, dynamic>> _mockPembelianObatList = [
    {'kode_obat': 'OBT001', 'kuantitas': 5},
    {'kode_obat': 'OBT003', 'kuantitas': 10},
    {'kode_obat': 'OBT001', 'kuantitas': 3},
    {'kode_obat': 'OBT005', 'kuantitas': 2},
    {'kode_obat': 'OBT003', 'kuantitas': 7},
    {'kode_obat': 'OBT001', 'kuantitas': 8},
  ];

  // Mock data Pasien (jika diperlukan untuk metrik lain di masa depan)
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
  int _pembayaranSelesai = 0;
  int _totalPelanggan = 0; // Disertakan jika suatu saat dibutuhkan di UI
  String _mostPurchasedMedicine = "N/A";

  // --- UI State Variables ---
  int _selectedIndex = 0; // Default selected index for Dashboard Admin
  int? _hoveredCardIndex;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _processLocalData();
    _scrollController.addListener(() {
      _scrollListener();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
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
    int eresepBaruCount = _mockEresepList
        .where((item) => item['status'] == "Menunggu Pembayaran")
        .length;
    int pembayaranSelesaiCount =
        _mockEresepList.where((item) => item['status'] == "Selesai").length;
    int totalEresepCount = _mockEresepList.length; // Total e-resep diterima
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
      _totalEresep = totalEresepCount; // Menggunakan total e-resep
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 50),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 24,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: CustomHeader(
        primaryColor: primaryColor,
        onNotificationPressed: () {
          _showSimpleModal(
              'Notifikasi', 'Anda memiliki beberapa notifikasi baru.');
        },
        searchController: _searchController,
        onSearchChanged: (text) {
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
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Text(
                    'Dashboard Admin',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Info Cards Grid (hanya 4 kartu teratas)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.95,
                    children: [
                      // 'GOOD' Status Card
                      _buildInfoCard(
                        cardIndex: 0,
                        icon: Icons.check_circle_rounded,
                        iconColor: successColor,
                        title: 'GOOD',
                        subtitle: 'Status Inventaris',
                        detailText: 'Lihat Detail Laporan',
                        onClick: () => _showSimpleModal('Status Inventaris',
                            'Ini adalah detail laporan status inventaris. Semua stok obat dalam kondisi baik.'),
                        isSpecialCard: true,
                      ),

                      // Incoming E-Prescriptions
                      _buildInfoCard(
                        cardIndex: 1,
                        icon: Icons.assignment,
                        iconColor: warningColor,
                        title: _eresepMenungguPembayaran.toString(),
                        subtitle: 'E-Resep Masuk',
                        detailText: 'Lihat Detail Laporan',
                        onClick: () => _showSimpleModal('E-Resep Masuk',
                            'Ini adalah detail e-resep yang masuk dan sedang menunggu pembayaran.'),
                      ),

                      // Low Stock Medicine
                      _buildInfoCard(
                        cardIndex: 2,
                        icon: Icons.folder,
                        iconColor: Colors.blue,
                        title: (_medicineStockStatus["hampirHabis"]["count"])
                            .toString(),
                        subtitle: 'Obat Hampir Habis',
                        detailText: 'Lihat Persediaan',
                        onClick: () => _showSimpleModal('Obat Hampir Habis',
                            'Ini adalah daftar obat yang stoknya hampir habis dan perlu segera diisi ulang.'),
                      ),

                      // Out of Stock Medicine
                      _buildInfoCard(
                        cardIndex: 3,
                        icon: Icons.error,
                        iconColor: dangerColor,
                        title:
                            _medicineStockStatus["habis"]["count"].toString(),
                        subtitle: 'Obat Habis',
                        detailText: 'Stok Sekarang',
                        onClick: () => _showSimpleModal(
                            'Obat Habis', 'Ini adalah daftar obat yang habis.'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[300],
                    indent: 16,
                    endIndent: 16),
                const SizedBox(height: 32),

                // Laporan Penyakit Chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LaporanPenyakitCardFlutter(
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    accentColor: accentColor,
                  ),
                ),
                const SizedBox(height: 32), // Spacing after chart

                // Apotik Chart Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ApotikChartCardFlutter(
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    accentColor: accentColor,
                  ),
                ),
                const SizedBox(height: 32), // Spacing after chart

                // Summary Sections (Stock and E-Resep)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummarySection(
                        title: "Ringkasan Stok Obat",
                        linkText: "Lihat Selengkapnya",
                        linkAction: () => _showSimpleModal(
                            'Ringkasan Stok Obat',
                            'Ini adalah ringkasan stok obat secara keseluruhan.'),
                        children: [
                          _buildSummaryItem(
                            _mockObatList.length.toString(),
                            "Total Obat Terdaftar",
                            Icons.medical_information,
                            primaryColor,
                          ),
                          _buildSummaryItem(
                            _medicineStockStatus["hampirHabis"]["count"]
                                .toString(),
                            "Obat Hampir Habis",
                            Icons.warning_amber_rounded,
                            warningColor,
                          ),
                          _buildSummaryItem(
                            _medicineStockStatus["habis"]["count"].toString(),
                            "Obat Habis (Perlu Restock)",
                            Icons.outbox_rounded,
                            dangerColor,
                          ),
                          _buildSummaryItem(
                            _mostPurchasedMedicine,
                            "Obat Terlaris",
                            Icons.trending_up_rounded,
                            successColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSummarySection(
                        title: "Ringkasan E-Resep",
                        linkText: "Lihat Semua E-Resep",
                        linkAction: () => _showSimpleModal('Ringkasan E-Resep',
                            'Ini adalah ringkasan status e-resep.'),
                        children: [
                          _buildSummaryItem(
                            _totalEresep.toString(),
                            "Total E-Resep Diterima",
                            Icons.assignment_turned_in_rounded,
                            secondaryColor,
                          ),
                          _buildSummaryItem(
                            _eresepMenungguPembayaran.toString(),
                            "E-Resep Menunggu Pembayaran",
                            Icons.hourglass_bottom_rounded,
                            warningColor,
                          ),
                          _buildSummaryItem(
                            _pembayaranSelesai.toString(),
                            "E-Resep Selesai",
                            Icons.check_circle_outline_rounded,
                            successColor,
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
          // --- LOGIKA NAVIGASI DARI BOTTOM NAV BAR KHUSUS ADMIN ---
          if (index == 0) {
            // Ini tetap Dashboard Admin, jadi cukup scroll ke atas
            _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          } else if (index == 1) {
            // Navigasi ke Halaman E-Resep Admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const EresepAdminPage()), // Mengarah ke halaman admin
            );
          } else if (index == 2) {
            // Navigasi ke Halaman Obat Admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const ObatAdminPage()), // Mengarah ke halaman admin
            );
          } else if (index == 3) {
            // Navigasi ke Halaman Akun Admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AkunAdminPage()), // Mengarah ke halaman admin
            );
          } else if (index == 4) {
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
}
