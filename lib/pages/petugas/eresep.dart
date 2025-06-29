import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Pastikan CustomHeader Anda ada
import 'package:login_signup/widgets/menu.dart'; // Pastikan CustomBottomNavBar Anda ada
import 'package:login_signup/screens/signin_screen.dart'; // Untuk navigasi Signin

// Import halaman-halaman utama lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/petugas/dashboard_petugas.dart'; // Penting untuk navigasi antar menu
import 'package:login_signup/pages/petugas/obat.dart'; // Penting untuk navigasi antar menu
import 'package:login_signup/pages/petugas/akun.dart'; // Penting untuk navigasi antar menu

// URL Launcher (Jika Anda ingin mencoba meluncurkan URL atau file, tapi untuk assets PDF lebih baik pakai PDF viewer library)
// import 'package:url_launcher/url_launcher.dart'; // Uncomment jika sudah di pubspec.yaml dan ingin pakai ini

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
        "poli": "Umum",
        "umur": "28 Tahun",
        "beratBadan": "60 Kg",
        "diagnosa": "Influenza",
        "keterangan": "Istirahat cukup, hindari makanan pedas.",
        "daftarObat": [
          {
            "nama_obat": "Paracetamol 500mg",
            "aturan_pakai": "3x sehari 1 tablet",
            "kuantitas": 10
          },
          {
            "nama_obat": "Amoxicillin 250mg",
            "aturan_pakai": "3x sehari 1 kapsul",
            "kuantitas": 7
          },
        ],
      },
    },
    {
      "id_pendaftaran": "PD002",
      "nama_pasien": "Setya Adjie",
      "nama_dokter": "dr. Dewa Mahendra",
      "status": "Menunggu Pembayaran",
      "tanggal_resep": "2024-05-21",
      "detail_resep": {
        "poli": "Anak",
        "umur": "5 Tahun",
        "beratBadan": "20 Kg",
        "diagnosa": "Demam Tinggi",
        "keterangan": "Pantau suhu tubuh anak.",
        "daftarObat": [
          {
            "nama_obat": "Tempra Sirup",
            "aturan_pakai": "3x sehari 5ml",
            "kuantitas": 1
          },
        ],
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
        "poli": "Gigi",
        "umur": "35 Tahun",
        "beratBadan": "75 Kg",
        "diagnosa": "Sakit Gigi",
        "keterangan": "Jaga kebersihan gigi.",
        "daftarObat": [
          {
            "nama_obat": "Mefenamic Acid",
            "aturan_pakai": "2x sehari 1 tablet",
            "kuantitas": 5
          },
        ],
      },
    },
    {
      "id_pendaftaran": "PD004",
      "nama_pasien": "Budi Santoso",
      "nama_dokter": "dr. Ahmad Subardjo",
      "status": "Selesai",
      "tanggal_resep": "2024-05-18",
      "detail_resep": {
        "poli": "Umum",
        "umur": "40 Tahun",
        "beratBadan": "70 Kg",
        "diagnosa": "Flu",
        "keterangan": "Banyak minum air putih.",
        "daftarObat": [
          {
            "nama_obat": "Bodrex",
            "aturan_pakai": "3x sehari 1 tablet",
            "kuantitas": 10
          },
        ],
      },
    },
    {
      "id_pendaftaran": "PD005",
      "nama_pasien": "Cindy Permata",
      "nama_dokter": "dr. Sari Wulandari",
      "status": "Menunggu Pembayaran",
      "tanggal_resep": "2024-05-22",
      "detail_resep": {
        "poli": "Kulit",
        "umur": "22 Tahun",
        "beratBadan": "55 Kg",
        "diagnosa": "Jerawat",
        "keterangan": "Gunakan sabun muka khusus.",
        "daftarObat": [
          {
            "nama_obat": "Acne Cream",
            "aturan_pakai": "2x sehari oleskan tipis",
            "kuantitas": 1
          },
        ],
      },
    },
  ];

  // --- Filter and Sort State ---
  String _statusFilter = "Semua"; // Currently active filter
  String _searchText = ""; // Search text
  bool _showAll = false; // To show all items if there are more than 12
  // Map<String, dynamic>? _selectedResep; // Not currently used, can be removed if not needed for future modals
  bool _isLoading = false; // Simulate data loading

  final List<String> _categoryOptions = [
    "Antrian E-Resep",
    "Menunggu Pembayaran",
    "Menunggu Panggilan",
    "Selesai",
    "Semua",
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Detail E-Resep ${resep['id_pendaftaran']}"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow("ID Pendaftaran", resep['id_pendaftaran']),
                _buildDetailRow("Nama Pasien", resep['nama_pasien']),
                _buildDetailRow("Nama Dokter", resep['nama_dokter']),
                _buildDetailRow("Poli", resep['detail_resep']['poli']),
                _buildDetailRow("Umur", resep['detail_resep']['umur']),
                _buildDetailRow(
                    "Berat Badan", resep['detail_resep']['beratBadan']),
                _buildDetailRow("Tanggal Resep", resep['tanggal_resep']),
                _buildDetailRow("Diagnosa", resep['detail_resep']['diagnosa']),
                _buildDetailRow(
                    "Keterangan", resep['detail_resep']['keterangan']),
                const SizedBox(height: 10),
                const Text("Daftar Obat:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (resep['detail_resep']['daftarObat'] != null)
                  ...(resep['detail_resep']['daftarObat'] as List)
                      .map((obat) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Text(
                                "${obat['nama_obat']} (${obat['kuantitas']}) - ${obat['aturan_pakai']}"),
                          ))
                      .toList(),
              ],
            ),
          ),
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

  /// Builds a row for displaying detail information in the modal.
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label :",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? "-"),
          ),
        ],
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
                        'Menampilkan E-resep',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // Categories / Status Filter Buttons
                      _buildCategoriesSection(),
                      // --- PERUBAHAN DI SINI: Mengurangi SizedBox dari 24 menjadi 16 ---
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
                      if (_filteredAndSortedData.length > 12)
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
          height: 65, // Tinggi sedikit dikurangi karena tidak ada label teks
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0), // Padding horizontal sedikit lebih besar
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
                        CrossAxisAlignment.center, // Pusatkan secara horizontal
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
                      // SizedBox(height: 4), // Dihapus karena tidak ada teks label
                      // Text(
                      //   status,
                      //   textAlign: TextAlign.center, // Dihapus karena tidak ada teks label
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: isSelected ? primaryColor : Colors.black87,
                      //     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      //   ),
                      // ),
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

  /// Builds the sort by dropdown.
  // Widget _buildSortByDropdown() { // Seluruh fungsi ini dihapus
  //   return DropdownButtonFormField<String>(
  //     decoration: InputDecoration(
  //       labelText: 'Urutkan',
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide(color: Colors.grey[400]!),
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide(color: Colors.grey[400]!),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide(color: primaryColor, width: 2),
  //       ),
  //       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     ),
  //     value: _sortBy.isEmpty ? null : _sortBy,
  //     hint: const Text("Urutkan"),
  //     items: const [
  //       DropdownMenuItem(value: "nama", child: Text("Nama Pasien (A-Z)")),
  //       DropdownMenuItem(value: "dokter", child: Text("Nama Dokter (A-Z)")),
  //       DropdownMenuItem(value: "id", child: Text("ID Pendaftaran (A-Z)")),
  //     ],
  //     onChanged: (value) {
  //       setState(() {
  //         _sortBy = value ?? "";
  //         _filterAndSortResep(); // Re-call when sorting changes
  //       });
  //     },
  //   );
  // }

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
    String actionText;
    Color actionColor;
    VoidCallback onActionTap;

    // Perubahan logika untuk tombol aksi
    if (resep['status'] == "Diproses") {
      statusColor = primaryColor; // Color for "Antrian E-Resep"
      actionText = "Terima"; // Tombol "Terima" untuk status "Diproses"
      actionColor = Colors.green;
      onActionTap = () {
        _showSimpleModal("Resep Diterima",
            "E-Resep ${resep['id_pendaftaran']} telah diterima (Diproses).");
        // Di sini Anda bisa menambahkan logika untuk benar-benar mengubah status jika diperlukan
        // _updateResepStatus(resep['id_pendaftaran'], "Selesai"); // Contoh: Jika Terima berarti Selesai
      };
    } else if (resep['status'] == "Sudah Bayar") {
      statusColor = Colors.blue; // Color for "Menunggu Panggilan"
      actionText = "Panggil"; // Tombol "Panggil" untuk status "Sudah Bayar"
      actionColor = Colors.blueAccent; // Warna untuk tombol Panggil
      onActionTap = () {
        _showSimpleModal("Panggilan Pasien",
            "Pasien ${resep['nama_pasien']} dengan ID ${resep['id_pendaftaran']} akan dipanggil.");
        // Di sini Anda bisa menambahkan logika untuk mengubah status menjadi "Diproses" setelah dipanggil
        // _updateResepStatus(resep['id_pendaftaran'], "Diproses");
      };
    } else {
      statusColor = Colors
          .orange; // Default for other statuses (e.g., Menunggu Pembayaran)
      actionText = "Lihat"; // Tombol default jika tidak ada aksi spesifik
      actionColor = Colors.grey;
      onActionTap = () {
        _showSimpleModal("Aksi Tidak Diizinkan",
            "Resep ini masih berstatus '${resep['status']}'.");
      };
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID Pendaftaran', resep['id_pendaftaran']),
            _buildInfoRow('Nama Pasien', resep['nama_pasien']),
            _buildInfoRow('Dokter', resep['nama_dokter']),
            _buildInfoRow('Status', displayStatus,
                valueColor: statusColor, fontWeight: FontWeight.bold),
            if (resep['status'] == "Diproses" && antreanNo != null)
              _buildInfoRow('Antrian Ke', antreanNo.toString(),
                  valueColor: primaryColor, fontWeight: FontWeight.bold),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onActionTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(actionText),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showResepDetailModal(resep),
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
            ),
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
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
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
            // Placeholder: Menampilkan modal daripada mencoba membuka PDF
            // karena url_launcher tidak mendukung PDF dari assets secara langsung.
            _showSimpleModal(
              "Fitur Petunjuk",
              "Fitur ini akan menampilkan petunjuk penggunaan E-Resep. "
                  "Implementasi pembaca PDF dari assets memerlukan library khusus "
                  "(misal: `flutter_pdfview`) atau penyimpanan file ke direktori "
                  "sementara untuk dibuka aplikasi eksternal.",
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
