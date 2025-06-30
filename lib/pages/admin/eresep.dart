import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Import CustomHeader
import 'package:login_signup/widgets/menu.dart'; // Import CustomBottomNavBar
import 'package:login_signup/screens/signin_screen.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

// Import halaman-halaman admin lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/admin/dashboard_admin.dart';
import 'package:login_signup/pages/admin/obat.dart';
import 'package:login_signup/pages/admin/akun.dart';

class EresepAdminPage extends StatefulWidget {
  const EresepAdminPage({super.key});

  @override
  State<EresepAdminPage> createState() => _EresepAdminPageState();
}

class _EresepAdminPageState extends State<EresepAdminPage> {
  // --- Colors (Consistent with other pages) ---
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color secondaryColor = const Color(0xFF6B8FB4);
  final Color accentColor = const Color(0xFFF0F4F8); // Light background color

  // --- Mock Data (Copied from EresepPage for consistency) ---
  List<Map<String, dynamic>> _mockResepList = [
    {
      "id_pendaftaran": "PD001",
      "nama_pasien": "Anisa Aulya",
      "nama_dokter": "dr. Lestari Wardhani",
      "status": "Diproses", // This will appear as "Antrian E-Resep"
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
      "status": "Sudah Bayar", // This will appear as "Menunggu Panggilan"
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
      "nama_pasien": "Mabel Pines",
      "nama_dokter": "Dr. Atta",
      "status": "Menunggu Pembayaran",
      "tanggal_resep": "2025-05-05",
      "detail_resep": {
        "id_resep": "ER005",
        "poli": "Poli KIA",
        "umur": "34",
        "beratBadan": "58.7",
        "diagnosa": "Alergi Musim",
        "keterangan": "Gunakan sabun muka khusus.",
        "daftarObat": [
          {
            "nama_obat": "Amoxicillin",
            "aturan_pakai": "3x sehari setelah makan",
            "kuantitas": 8,
            "harga_satuan": 15000
          },
        ],
        "catatan": "Obat alergi musim",
      },
    },
  ];

  // --- Filter and Sort State ---
  String _statusFilter = "Semua"; // Currently active filter
  String _searchText = ""; // Search text
  bool _showAll = false; // To show all items if there are more than 12

  final List<String> _categoryOptions = [
    "Semua", // Pindahkan "Semua" ke awal
    "Antrian E-Resep",
    "Menunggu Pembayaran",
    "Menunggu Panggilan",
    "Selesai",
  ];

  // Map for converting from button status (display name) to internal data status
  final Map<String, String> _statusFilterMap = {
    "Antrian E-Resep": "Diproses",
    "Menunggu Pembayaran": "Menunggu Pembayaran",
    "Menunggu Panggilan": "Sudah Bayar",
    "Selesai": "Selesai",
    "Semua": "Semua", // "Semua" status doesn't need conversion, used directly
  };

  // Map for converting from internal data status to UI display
  final Map<String, String> _statusDisplayMap = {
    "Diproses": "Antrian E-Resep",
    "Menunggu Pembayaran": "Menunggu Pembayaran",
    "Sudah Bayar": "Menunggu Panggilan",
    "Selesai": "Selesai",
  };

  // Priority map for sorting (still maintained for default sorting)
  final Map<String, int> _statusPriority = {
    "Diproses": 1, // Highest priority for "Antrian E-Resep"
    "Menunggu Pembayaran": 2,
    "Sudah Bayar": 3, // For "Menunggu Panggilan"
    "Selesai": 4, // Lowest priority
  };

  // --- UI State Variables for Header and Menu ---
  int _selectedIndex = 1; // Index for E-Resep Admin on BottomNavBar
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _headerSearchController =
      TextEditingController(); // Controller for search bar in header

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _headerSearchController.addListener(() {
      if (_headerSearchController.text != _searchText) {
        setState(() {
          _searchText = _headerSearchController.text;
          _filterAndSortResep();
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterAndSortResep(); // Initial filter and sort on load
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _headerSearchController.dispose(); // Dispose header controller
    super.dispose();
  }

  // --- Methods ---

  /// Listens to scroll events (currently not used for FAB, but can be for other scroll effects).
  void _scrollListener() {
    // Implement if needed for scroll-based UI changes
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
      // when _searchText or _statusFilter changes.
    });
  }

  /// Filters and sorts the prescription list based on current filters and search.
  List<Map<String, dynamic>> get _filteredAndSortedData {
    List<Map<String, dynamic>> data = List.from(_mockResepList);

    // 1. Filter by status
    if (_statusFilter != "Semua") {
      final targetStatus = _statusFilterMap[_statusFilter];
      data = data.where((resep) => resep['status'] == targetStatus).toList();
    }

    // 2. Filter by search text
    if (_searchText.isNotEmpty) {
      final lowerSearch = _searchText.toLowerCase();
      data = data.where((resep) {
        return (resep['id_pendaftaran']?.toLowerCase().contains(lowerSearch) ??
                false) ||
            (resep['nama_pasien']?.toLowerCase().contains(lowerSearch) ??
                false) ||
            (resep['nama_dokter']?.toLowerCase().contains(lowerSearch) ??
                false);
      }).toList();
    }

    // 3. Sorting by status priority (from low number = high priority)
    data.sort((a, b) {
      final aPriority = _statusPriority[a['status']] ?? 999;
      final bPriority = _statusPriority[b['status']] ?? 999;
      if (aPriority != bPriority)
        return aPriority.compareTo(bPriority); // Ascending order for priority

      // Secondary sort by date (newest first)
      final aDate =
          DateTime.tryParse(a['tanggal_resep'] ?? '') ?? DateTime(1900);
      final bDate =
          DateTime.tryParse(b['tanggal_resep'] ?? '') ?? DateTime(1900);
      return bDate.compareTo(aDate); // Descending order for date
    });

    return data;
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
                  // Title and Close Button
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

                  // Patient and Prescription Info Section
                  _buildSectionContainer(
                    title: "Informasi Pasien & Resep",
                    children: [
                      _buildDetailItem("Nama Pasien", resep['nama_pasien']),
                      _buildDetailItem("ID Resep", detailResep['id_resep']),
                      _buildDetailItem("Umur", detailResep['umur']),
                      _buildDetailItem("Berat Badan",
                          detailResep['beratBadan'].toString() + " Kg"),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Main Build Method ---
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
    }

    return Scaffold(
      backgroundColor: accentColor,
      appBar: CustomHeader(
        primaryColor: primaryColor,
        onNotificationPressed: () {
          _showSimpleModal('Notifikasi',
              'Anda memiliki beberapa notifikasi baru di halaman E-Resep Admin.');
        },
        searchController: _headerSearchController,
        onSearchChanged: (text) {
          setState(() {
            _searchText = text;
            _filterAndSortResep();
          });
        },
        searchHintText: 'Cari E-Resep...',
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
                        'Pantau E-Resep', // Judul khusus untuk Admin
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Menampilkan daftar E-Resep.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // Categories / Status Filter Buttons
                      _buildCategoriesSection(),
                      const SizedBox(height: 16),

                      // List Resep Cards
                      displayedData.isEmpty
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
                                // Pass antreanNo if status is 'Diproses'
                                final int? currentAntreanNo =
                                    resep['status'] == 'Diproses'
                                        ? antreanMap[resep['id_pendaftaran']]
                                        : null;
                                return _buildResepCard(resep, currentAntreanNo);
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
          // Logika navigasi untuk Admin
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardAdmin()),
            );
          } else if (index == 1) {
            print("Sudah di halaman E-Resep Admin.");
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObatAdminPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunAdminPage()),
            );
          } else if (index == 4) {
            // Sign Out / Kembali ke Sign In Screen
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
    );
  }

  /// Helper for building a detail item (label and value).
  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds a section container with a title and child widgets arranged in a grid.
  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
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
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const Divider(height: 20, thickness: 1),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.5, // Adjust as needed
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: children,
          ),
        ],
      ),
    );
  }

  // --- Helper Methods (PENTING: Pastikan semua metode ini ada di sini, di dalam kelas _EresepAdminPageState) ---

  /// Builds a single prescription card for admin (no action buttons).
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

            const SizedBox(height: 15), // Increased spacing before button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Admin hanya bisa melihat detail, tidak ada aksi lain
                onPressed: () => _showResepDetailModal(resep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Lihat Detail"), // Tombol hanya untuk melihat
              ),
            ),
          ],
        ),
      ),
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
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categoryOptions.length,
            itemBuilder: (context, index) {
              final status = _categoryOptions[index];
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
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _statusFilter = status;
                      _filterAndSortResep(); // Re-call when filter changes
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center horizontally
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
            },
          ),
        ),
      ],
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
}
