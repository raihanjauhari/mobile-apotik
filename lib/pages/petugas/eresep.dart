import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart';
import 'package:login_signup/widgets/menu.dart';
import 'package:login_signup/screens/signin_screen.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

// Import halaman-halaman utama lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/petugas/dashboard_petugas.dart';
import 'package:login_signup/pages/petugas/obat.dart';
import 'package:login_signup/pages/petugas/akun.dart';
import 'package:login_signup/pages/petugas/pdf_viewer_page.dart'; // Import halaman PDF viewer

class EresepPage extends StatefulWidget {
  const EresepPage({super.key});

  @override
  State<EresepPage> createState() => _EresepPageState();
}

class _EresepPageState extends State<EresepPage> {
  // --- Colors (Salin dari DashboardPetugas agar konsisten) ---
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color secondaryColor = const Color(0xFF6B8FB4);
  final Color accentColor =
      const Color(0xFFF0F4F8); // Warna latar belakang terang

  // --- Mock Data ---
  List<Map<String, dynamic>> _mockResepList = [
    {
      "id_pendaftaran": "PD001",
      "nama_pasien": "Anisa Aulya",
      "nama_dokter": "dr. Lestari Wardhani",
      "status": "Diproses", // Ini yang akan muncul sebagai "Antrian E-Resep"
      "tanggal_resep": "2024-05-20",
      "detail_resep": {
        "id_resep": "ER001",
        "poli": "Umum",
        "umur": "28 Tahun",
        "beratBadan": "60 Kg",
        "diagnosa": "Influenza",
        "keterangan": "Istirahat cukup, hindari makanan pedas.",
        "daftarObat": [
          {
            "nama_obat": "Paracetamol 500mg",
            "aturan_pakai": "3x sehari 1 tablet",
            "kuantitas": 10,
            "harga_satuan": 2000
          },
          {
            "nama_obat": "Amoxicillin 250mg",
            "aturan_pakai": "3x sehari 1 kapsul",
            "kuantitas": 7,
            "harga_satuan": 3000
          },
        ],
        "catatan": "Resep untuk flu biasa.",
      },
    },
    {
      "id_pendaftaran": "PD002",
      "nama_pasien": "Setya Adjie",
      "nama_dokter": "dr. Dewa Mahendra",
      "status": "Menunggu Pembayaran",
      "tanggal_resep": "2024-05-21",
      "detail_resep": {
        "id_resep": "ER002",
        "poli": "Anak",
        "umur": "5 Tahun",
        "beratBadan": "20 Kg",
        "diagnosa": "Demam Tinggi",
        "keterangan": "Pantau suhu tubuh anak.",
        "daftarObat": [
          {
            "nama_obat": "Tempra Sirup",
            "aturan_pakai": "3x sehari 5ml",
            "kuantitas": 1,
            "harga_satuan": 35000
          },
        ],
        "catatan": "Berikan sesuai dosis anak.",
      },
    },
    {
      "id_pendaftaran": "PD003",
      "nama_pasien": "Hairul Azmi",
      "nama_dokter": "dr. Intan Prameswari",
      "status":
          "Sudah Bayar", // Ini yang akan muncul sebagai "Menunggu Panggilan"
      "tanggal_resep": "2024-05-19",
      "detail_resep": {
        "id_resep": "ER003",
        "poli": "Gigi",
        "umur": "35 Tahun",
        "beratBadan": "75 Kg",
        "diagnosa": "Sakit Gigi",
        "keterangan": "Jaga kebersihan gigi.",
        "daftarObat": [
          {
            "nama_obat": "Mefenamic Acid",
            "aturan_pakai": "2x sehari 1 tablet",
            "kuantitas": 5,
            "harga_satuan": 1500
          },
        ],
        "catatan": "Minum setelah makan.",
      },
    },
    {
      "id_pendaftaran": "PD004",
      "nama_pasien": "Budi Santoso",
      "nama_dokter": "dr. Ahmad Subardjo",
      "status": "Selesai",
      "tanggal_resep": "2024-05-18",
      "detail_resep": {
        "id_resep": "ER004",
        "poli": "Umum",
        "umur": "40 Tahun",
        "beratBadan": "70 Kg",
        "diagnosa": "Flu",
        "keterangan": "Banyak minum air putih.",
        "daftarObat": [
          {
            "nama_obat": "Bodrex",
            "aturan_pakai": "3x sehari 1 tablet",
            "kuantitas": 10,
            "harga_satuan": 1000
          },
        ],
        "catatan": "Istirahat yang cukup.",
      },
    },
    {
      "id_pendaftaran": "PD005",
      "nama_pasien": "Mabel Pines", // Changed to match the image
      "nama_dokter": "Dr. Atta", // Changed to match the image
      "status": "Menunggu Pembayaran",
      "tanggal_resep": "2025-05-05", // Changed to match the image
      "detail_resep": {
        "id_resep": "ER005", // Changed to match the image
        "poli": "Poli KIA", // Changed to match the image
        "umur": "34", // Changed to match the image
        "beratBadan": "58.7", // Changed to match the image
        "diagnosa": "Alergi Musim", // Changed to match the image
        "keterangan":
            "Gunakan sabun muka khusus.", // Not used in new modal design
        "daftarObat": [
          {
            "nama_obat": "Amoxicillin", // Changed to match the image
            "aturan_pakai":
                "3x sehari setelah makan", // Changed to match the image
            "kuantitas": 8, // Changed to match the image
            "harga_satuan": 15000 // Changed to match the image
          },
        ],
        "catatan": "Obat alergi musim", // Added this to match the image
      },
    },
  ];

  // --- Filter and Sort State ---
  String _statusFilter = "Semua"; // Currently active filter
  String _searchText = ""; // Search text
  bool _showAll = false; // To show all items if there are more than 12
  bool _isLoading = false; // Simulate data loading

  // Diperbaiki: Mengubah urutan agar "Semua" menjadi yang pertama
  final List<String> _categoryOptions = [
    "Semua",
    "Antrian E-Resep",
    "Menunggu Pembayaran",
    "Menunggu Panggilan",
    "Selesai",
  ];

  // Map for converting from button status (display name) to internal data status
  final Map<String, String> _statusFilterMap = {
    "Semua": "Semua", // "Semua" status doesn't need conversion, used directly
    "Antrian E-Resep": "Diproses",
    "Menunggu Pembayaran": "Menunggu Pembayaran",
    "Menunggu Panggilan": "Sudah Bayar",
    "Selesai": "Selesai",
  };

  // Map for converting from internal data status to UI display
  final Map<String, String> _statusDisplayMap = {
    "Diproses": "Antrian E-Resep",
    "Menunggu Pembayaran": "Menunggu Pembayaran",
    "Sudah Bayar": "Menunggu Panggilan",
    "Selesai": "Selesai",
  };

  // Priority map for sorting (masih dipertahankan, tapi tidak digunakan jika dropdown urutkan dihapus)
  final Map<String, int> _statusPriority = {
    "Sudah Bayar": 1, // Highest priority
    "Diproses": 2,
    "Menunggu Pembayaran": 3,
    "Selesai": 4, // Lowest priority
  };

  // --- UI State Variables untuk Header dan Menu ---
  int _selectedIndex =
      1; // Default selected index untuk EresepPage adalah 1 (asumsi: 0-Dashboard, 1-Eresep)
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  final TextEditingController _headerSearchController =
      TextEditingController(); // Controller untuk search bar di header

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterAndSortResep();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _headerSearchController.dispose(); // Dispose controller header
    super.dispose();
  }

  // --- Methods ---

  /// Listens to scroll events to show/hide the scroll-to-top button.
  void _scrollListener() {
    setState(() {
      _showScrollToTopButton = _scrollController.offset >= 400;
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

  /// Triggers a re-calculation of filtered and sorted data and refreshes the UI.
  void _filterAndSortResep() {
    setState(() {
      // The getter _filteredAndSortedData will be re-calculated automatically
    });
  }

  /// Filters and sorts the prescription list based on current filters and sort order.
  List<Map<String, dynamic>> get _filteredAndSortedData {
    List<Map<String, dynamic>> data = List.from(_mockResepList);

    // Filter by status
    if (_statusFilter != "Semua") {
      final targetStatus = _statusFilterMap[_statusFilter];
      data = data.where((resep) => resep['status'] == targetStatus).toList();
    }

    // Filter by search text (gunakan _headerSearchController.text juga)
    if (_searchText.isNotEmpty || _headerSearchController.text.isNotEmpty) {
      final lowerSearch =
          (_searchText.isNotEmpty ? _searchText : _headerSearchController.text)
              .toLowerCase();
      data = data.where((resep) {
        return (resep['id_pendaftaran']?.toLowerCase().contains(lowerSearch) ??
                false) ||
            (resep['nama_pasien']?.toLowerCase().contains(lowerSearch) ??
                false) ||
            (resep['nama_dokter']?.toLowerCase().contains(lowerSearch) ??
                false);
      }).toList();
    }

    // Sorting (Bagian ini tidak lagi relevan jika dropdown dihapus, tapi jika Anda ingin tetap
    // ada sorting default atau berdasarkan status, bisa dipertahankan atau diubah)
    data.sort((a, b) {
      final aPriority = _statusPriority[a['status']] ?? 999;
      final bPriority = _statusPriority[b['status']] ?? 999;
      if (aPriority != bPriority) return aPriority - bPriority;

      // Jika prioritas status sama, bisa ditambahkan sorting sekunder
      // Contoh: sorting berdasarkan ID pendaftaran (baru ke lama atau sebaliknya)
      // return (b['id_pendaftaran'] as String).compareTo(a['id_pendaftaran'] as String);
      return 0; // Tanpa sorting sekunder eksplisit jika dropdown dihapus
    });

    return data;
  }

  /// Updates the status of a prescription and refreshes the UI.
  void _updateResepStatus(String id, String newStatus) {
    setState(() {
      _mockResepList = _mockResepList.map((resep) {
        if (resep['id_pendaftaran'] == id) {
          return {...resep, 'status': newStatus};
        }
        return resep;
      }).toList();
      _filterAndSortResep(); // Re-call to refresh the view
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Status resep $id diubah menjadi ${_statusDisplayMap[newStatus]}')),
    );
  }

  /// Shows a detailed modal for a selected prescription.
  void _showResepDetailModal(Map<String, dynamic> resep) {
    final detailResep = resep['detail_resep'];
    final List<Map<String, dynamic>> daftarObat =
        List<Map<String, dynamic>>.from(detailResep['daftarObat'] ?? []);

    double totalHarga = 0;
    for (var obat in daftarObat) {
      totalHarga += (obat['kuantitas'] ?? 0) * (obat['harga_satuan'] ?? 0);
    }

    // Format total harga ke mata uang Rupiah
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
          backgroundColor:
              Colors.transparent, // Make dialog background transparent
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Close Button (Optional, can be put in AppBar if using AlertDialog)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    "Detail E-Resep",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  const SizedBox(height: 20),

                  // Patient and Prescription Info Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3.5, // Adjust as needed
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildDetailItem("Nama Pasien", resep['nama_pasien']),
                      _buildDetailItem("ID Resep", detailResep['id_resep']),
                      _buildDetailItem("Umur", detailResep['umur']),
                      _buildDetailItem(
                          "Berat Badan", detailResep['beratBadan'].toString()),
                      _buildDetailItem("Poli", detailResep['poli']),
                      _buildDetailItem(
                          "Tanggal E-Resep", resep['tanggal_resep']),
                      _buildDetailItem("Dokter", resep['nama_dokter']),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Diagnosa Section
                  _buildSectionCard(
                    title: "Diagnosa",
                    content: detailResep['diagnosa'] ?? '-',
                    icon: Icons.medical_information,
                  ),
                  const SizedBox(height: 20),

                  // Daftar Obat Table
                  Text(
                    "Daftar Obat:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3), // Nama Obat
                        1: FlexColumnWidth(4), // Aturan Pakai
                        2: FlexColumnWidth(2), // Kuantitas
                        3: FlexColumnWidth(3), // Harga Satuan
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(7)),
                          ),
                          children: [
                            _buildTableHeaderCell("Nama Obat"),
                            _buildTableHeaderCell("Aturan Pakai"),
                            _buildTableHeaderCell("Qty"), // Shortened
                            _buildTableHeaderCell("Harga"), // Shortened
                          ],
                        ),
                        ...(daftarObat.isEmpty
                            ? [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          "Tidak ada obat terdaftar.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),
                                      ),
                                    ),
                                    TableCell(child: Container()),
                                    TableCell(child: Container()),
                                    TableCell(child: Container()),
                                  ],
                                )
                              ]
                            : daftarObat.map((obat) {
                                return TableRow(
                                  children: [
                                    _buildTableCell(obat['nama_obat']),
                                    _buildTableCell(obat['aturan_pakai']),
                                    _buildTableCell(
                                        obat['kuantitas']?.toString() ?? '-'),
                                    _buildTableCell(formatCurrency
                                        .format(obat['harga_satuan'] ?? 0)),
                                  ],
                                );
                              }).toList()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Catatan Section
                  _buildSectionCard(
                    title: "Catatan",
                    content: detailResep['catatan'] ?? '-',
                    icon: Icons.notes,
                  ),
                  const SizedBox(height: 20),

                  // Total Harga Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryColor, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Harga Obat",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          formatCurrency.format(totalHarga),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Print Resep Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement print functionality
                        _showSimpleModal("Fungsi Cetak",
                            "Fitur cetak resep akan segera hadir!");
                      },
                      icon: const Icon(Icons.print, color: Colors.white),
                      label: const Text(
                        "Cetak E-Resep",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper for building an individual detail item with a label and value.
  Widget _buildDetailItem(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value ?? "-",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: primaryColor),
        ),
      ],
    );
  }

  /// Helper for building a section card with a title, content, and icon.
  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  /// Helper for building table header cells.
  static Widget _buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  /// Helper for building table content cells.
  static Widget _buildTableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedData = _showAll
        ? _filteredAndSortedData
        : _filteredAndSortedData.take(12).toList();

    // Calculate queue number for 'Diproses' status
    final Map<String, int> antreanMap = {};
    int antreanCounter = 0;
    for (var item in _filteredAndSortedData) {
      if (item['status'] == "Diproses") {
        antreanCounter++;
        antreanMap[item['id_pendaftaran']] = antreanCounter;
      }
      // Reset counter if there's a different status, or if you only want to count 'Diproses' consecutively
      // For this implementation, it counts 'Diproses' globally in the filtered list.
    }

    return Scaffold(
      backgroundColor: accentColor,
      appBar: CustomHeader(
        primaryColor: primaryColor,
        onNotificationPressed: () {
          // --- Mengubah navigasi menjadi pop-up ---
          _showSimpleModal(
              'Notifikasi', 'Anda memiliki beberapa notifikasi baru.');
        },
        searchController:
            _headerSearchController, // Menggunakan controller baru untuk header
        onSearchChanged: (text) {
          // Mengupdate filter pencarian utama ketika teks di header berubah
          setState(() {
            _searchText = text;
            _filterAndSortResep();
          });
        },
        searchHintText:
            'Cari E-Resep di sini...', // Hint text khusus untuk EresepPage
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'E-Resep',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Menampilkan daftar E-Resep pasien.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // Categories / Status Filter Buttons
                      _buildCategoriesSection(),
                      const SizedBox(height: 16),

                      // List Resep Cards
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : displayedData.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Text(
                                      'Tidak ada E-Resep ditemukan.',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: displayedData.map((resep) {
                                    return _buildResepCard(resep,
                                        antreanMap[resep['id_pendaftaran']]);
                                  }).toList(),
                                ),

                      // "Lihat Semua" button if more data
                      if (_filteredAndSortedData.length > 12 && !_showAll)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showAll = !_showAll;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                  _showAll ? "Sembunyikan" : "Lihat Semua"),
                            ),
                          ),
                        ),
                      // "Sembunyikan" button if showing all
                      if (_filteredAndSortedData.length > 12 && _showAll)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _showAll = !_showAll;
                                  _scrollController.animateTo(0,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: BorderSide(color: primaryColor),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Sembunyikan"),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Information & Tip Section
                      _buildInfoTipSection(),

                      const SizedBox(height: 24),

                      // View E-Prescription Guide
                      _buildPetunjukSection(),

                      const SizedBox(height: 50), // Spacing at the bottom
                    ],
                  ),
                ),
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
          // Logika navigasi yang sama seperti di DashboardPetugas dan ObatPage
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPetugas()),
            );
          } else if (index == 1) {
            // Sudah di halaman Eresep, jadi tidak perlu navigasi ulang
            print("Sudah di halaman E-Resep.");
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObatPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunPage()),
            );
          } else if (index == 4) {
            // Asumsi ada 5 item di menu
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (Route<dynamic> route) => false,
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

  /// Builds the categories/status filter section.
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori', // Tetap "Kategori" sesuai kode Anda sebelumnya
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 65, // Tinggi yang cukup untuk ikon
          child: SingleChildScrollView(
            // Menggunakan SingleChildScrollView
            scrollDirection: Axis.horizontal,
            child: Row(
              // Menggunakan Row untuk menampung item secara berurutan dari kiri ke kanan
              children: _categoryOptions.map((status) {
                final bool isSelected = _statusFilter == status;

                IconData iconData;
                Color iconColor;

                switch (status) {
                  case "Antrian E-Resep":
                    iconData = Icons.receipt_long;
                    iconColor = primaryColor;
                    break;
                  case "Menunggu Pembayaran":
                    iconData = Icons.payment;
                    iconColor = Colors.orange;
                    break;
                  case "Menunggu Panggilan":
                    iconData = Icons.call;
                    iconColor = Colors.blue;
                    break;
                  case "Selesai":
                    iconData = Icons.check_circle;
                    iconColor = Colors.green;
                    break;
                  case "Semua":
                    iconData = Icons.list;
                    iconColor = Colors.grey;
                    break;
                  default:
                    iconData = Icons.grid_view;
                    iconColor = Colors.grey;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0), // Padding horizontal
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _statusFilter = status;
                        _filterAndSortResep(); // Re-call when filter changes
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? primaryColor : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            iconData,
                            color: isSelected ? Colors.white : iconColor,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the search input field.
  Widget _buildSearchInput() {
    // Search input ini dihapus karena sudah ada search bar di CustomHeader.
    // Jika Anda ingin dua search bar, Anda bisa tambahkan kembali widget ini.
    return const SizedBox.shrink(); // Mengembalikan widget kosong
  }

  /// Builds a single prescription card.
  Widget _buildResepCard(Map<String, dynamic> resep, int? antreanNo) {
    String displayStatus =
        _statusDisplayMap[resep['status']] ?? resep['status'];
    Color statusColor;
    IconData statusIcon;

    // Determine status color and icon
    if (resep['status'] == "Menunggu Pembayaran") {
      statusColor = Colors.orange;
      statusIcon = Icons.payment;
    } else if (resep['status'] == "Sudah Bayar") {
      statusColor = Colors.blue;
      statusIcon = Icons.call;
    } else if (resep['status'] == "Diproses") {
      statusColor = primaryColor;
      statusIcon = Icons.receipt_long;
    } else if (resep['status'] == "Selesai") {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info_outline;
    }

    // Action for "Detail" button
    void onDetailTap() {
      _showResepDetailModal(resep);
    }

    Widget actionButtons;

    if (resep['status'] == "Menunggu Pembayaran") {
      actionButtons = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onDetailTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text("Detail"),
        ),
      );
    } else if (resep['status'] == "Sudah Bayar") {
      actionButtons = Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _updateResepStatus(resep['id_pendaftaran'], "Diproses");
                _showSimpleModal("Panggilan Pasien",
                    "Pasien ${resep['nama_pasien']} dengan ID ${resep['id_pendaftaran']} akan dipanggil. Status diubah menjadi Antrian E-Resep.");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text("Panggil"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: onDetailTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text("Detail"),
            ),
          ),
        ],
      );
    } else if (resep['status'] == "Diproses") {
      actionButtons = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _updateResepStatus(resep['id_pendaftaran'], "Selesai");
            _showSimpleModal("Resep Selesai",
                "E-Resep ${resep['id_pendaftaran']} telah Selesai.");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Warna hijau untuk Selesai
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text("Selesai"),
        ),
      );
    } else if (resep['status'] == "Selesai") {
      actionButtons = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onDetailTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text("Detail"),
        ),
      );
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info_outline;
      actionButtons = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onDetailTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text("Detail"),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3, // Increased elevation for a slightly more prominent look
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID Pendaftaran: ${resep['id_pendaftaran']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
                height: 20, thickness: 1), // Divider for visual separation

            // Patient and Doctor Information
            _buildInfoRow('Nama Pasien', resep['nama_pasien']),
            _buildInfoRow('Dokter', resep['nama_dokter']),

            if (resep['status'] == "Diproses" && antreanNo != null)
              _buildInfoRow('Antrian Ke', antreanNo.toString(),
                  valueColor: primaryColor, fontWeight: FontWeight.bold),

            const SizedBox(height: 15), // Increased spacing before buttons
            actionButtons,
          ],
        ),
      ),
    );
  }

  /// Builds a row for displaying information (label and value).
  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, FontWeight? fontWeight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width for label
            child: Text('$label',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const Text(' : '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: fontWeight),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the information and tip section.
  Widget _buildInfoTipSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Changed to white
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: primaryColor, width: 1.5), // Changed border color and width
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Butuh bantuan lebih lanjut? Pastikan ID dan nama pasien sesuai sebelum memanggil.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.grey[500], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Tip: Klik tombol ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    children: [
                      const TextSpan(
                        text:
                            '"Panggil"', // Perbaikan teks tip agar sesuai dengan tombol baru
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ' hanya jika pasien sudah menyelesaikan pembayaran. Jangan sampai salah ya ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      WidgetSpan(
                        child: Icon(Icons.sentiment_satisfied_alt,
                            color: Colors.amber, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the section for viewing the E-Prescription guide.
  Widget _buildPetunjukSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigasi ke halaman PdfViewerPage saat tombol diklik
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PdfViewerPage(
                  path: 'assets/pdf/petunjuk.pdf', // Path aset PDF
                  title: 'Petunjuk Penggunaan E-Resep',
                ),
              ),
            );
          },
          icon: Icon(Icons.description,
              color: primaryColor), // Using primaryColor
          label: Text(
            'Lihat Petunjuk Penggunaan E-Resep',
            style: TextStyle(color: primaryColor), // Using primaryColor
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor
                .withOpacity(0.1), // Transparent background with primaryColor
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            side: BorderSide(color: primaryColor), // Border with primaryColor
          ),
        ),
      ),
    );
  }
}
