import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Import CustomHeader
import 'package:login_signup/widgets/menu.dart'; // Import CustomBottomNavBar
import 'package:login_signup/screens/signin_screen.dart';
import 'package:intl/intl.dart'; // Import for currency formatting
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'dart:convert'; // For JSON encoding/decoding

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

  // --- Data from API (will replace mock data) ---
  List<Map<String, dynamic>> _resepList =
      []; // This will hold the combined data
  bool _isLoadingData = false; // To show loading indicator
  String? _apiErrorMessage; // To display API errors

  // --- Filter and Sort State ---
  String _statusFilter = "Semua"; // Currently active filter
  String _searchText = ""; // Search text
  bool _showAll = false; // To show all items if there are more than 12

  final List<String> _categoryOptions = [
    "Semua",
    "Antrian E-Resep",
    "Menunggu Pembayaran",
    "Menunggu Panggilan",
    "Selesai",
  ];

  final Map<String, String> _statusFilterMap = {
    "Antrian E-Resep": "Diproses", // Mapping UI display to actual data status
    "Menunggu Pembayaran": "Menunggu Pembayaran",
    "Menunggu Panggilan": "Sudah Bayar",
    "Selesai": "Selesai",
    "Semua": "Semua",
  };

  final Map<String, String> _statusDisplayMap = {
    "Diproses": "Antrian E-Resep",
    "Menunggu Pembayaran": "Menunggu Pembayaran",
    "Sudah Bayar": "Menunggu Panggilan",
    "Selesai": "Selesai",
  };

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
        });
      }
    });
    _fetchEresepData(); // Initial data fetch from API
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
          title: Text(title, style: TextStyle(color: primaryColor)),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  /// Fetches and combines e-resep data from multiple APIs.
  Future<void> _fetchEresepData() async {
    setState(() {
      _isLoadingData = true;
      _apiErrorMessage = null;
    });

    try {
      // Fetch all necessary data concurrently
      final responses = await Future.wait([
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/eresep')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/pasien')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/dokter')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/dilayani')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/memunculkan')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/obat')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/detail_eresep')),
      ]);

      // Check all responses for success
      for (var res in responses) {
        if (res.statusCode != 200) {
          throw Exception(
              'Failed to load data from API: ${res.request?.url.path} (Status: ${res.statusCode})');
        }
      }

      // Decode JSON data
      final List<dynamic> eresepData = json.decode(responses[0].body);
      final List<dynamic> pasienData = json.decode(responses[1].body);
      final List<dynamic> dokterData = json.decode(responses[2].body);
      final List<dynamic> dilayaniData = json.decode(responses[3].body);
      final List<dynamic> memunculkanData = json.decode(responses[4].body);
      final List<dynamic> obatData = json.decode(responses[5].body);
      final List<dynamic> detailEresepData = json.decode(responses[6].body);

      // Create maps for faster lookup
      final Map<String, dynamic> pasienMap = {
        for (var p in pasienData) p['id_pendaftaran']: p
      };
      final Map<String, dynamic> dokterMap = {
        for (var d in dokterData) d['id_dokter'].toString(): d
      }; // Ensure ID is string
      final Map<String, dynamic> dilayaniMap = {
        for (var d in dilayaniData) d['id_pendaftaran']: d
      };
      final Map<String, dynamic> detailEresepMap = {
        for (var d in detailEresepData) d['id_eresep']: d
      };
      final Map<String, dynamic> obatMap = {
        for (var o in obatData) o['kode_obat']: o
      };

      List<Map<String, dynamic>> combinedResepList = [];

      for (var resep in eresepData) {
        final String idResep = resep['id_eresep'];
        final String idPendaftaran = resep['id_pendaftaran'];

        final pasien = pasienMap[idPendaftaran];
        final dilayani = dilayaniMap[idPendaftaran];
        final dokter = dilayani != null
            ? dokterMap[dilayani['id_dokter'].toString()]
            : null; // Convert id_dokter to string
        final detailResep = detailEresepMap[idResep];

        List<Map<String, dynamic>> daftarObat = [];
        final filteredMemunculkan =
            memunculkanData.where((m) => m['id_eresep'] == idResep).toList();

        for (var m in filteredMemunculkan) {
          final obat = obatMap[m['kode_obat']];
          if (obat != null) {
            daftarObat.add({
              "nama_obat": obat['nama_obat'] ?? "-",
              "aturan_pakai": m['aturan_pakai'] ?? "-",
              "kuantitas": m['kuantitas'] ?? 0,
              "harga_satuan": obat['harga_satuan'] ?? 0,
            });
          }
        }

        combinedResepList.add({
          "id_pendaftaran": idPendaftaran,
          "nama_pasien": pasien?['nama_pasien'] ?? "N/A",
          "nama_dokter": dokter?['nama_dokter'] ?? "N/A",
          "status": resep['status'] ?? "N/A",
          "tanggal_resep": detailResep?['tanggal_eresep'] ?? "N/A",
          "detail_resep": {
            "id_resep": idResep,
            "poli": dokter?['poli'] ?? "N/A",
            "umur": pasien?['umur']?.toString() ?? "N/A",
            "beratBadan": pasien?['berat_badan']?.toString() ?? "N/A",
            "diagnosa": pasien?['diagnosa'] ?? "N/A",
            "keterangan": detailResep?['catatan'] ??
                "N/A", // Use 'catatan' from detail_eresep
            "daftarObat": daftarObat,
            "catatan": detailResep?['catatan'] ??
                "N/A", // Redundant if 'keterangan' is the same
          },
        });
      }

      if (mounted) {
        setState(() {
          _resepList = combinedResepList;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiErrorMessage = e.toString().contains("Failed host lookup")
              ? "Tidak ada koneksi internet atau server tidak dapat dijangkau."
              : e.toString();
          _resepList = []; // Clear list on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching E-Resep: $_apiErrorMessage')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  /// Filters and sorts the prescription list based on current filters and search.
  List<Map<String, dynamic>> get _filteredAndSortedData {
    List<Map<String, dynamic>> data =
        List.from(_resepList); // Use data from API

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
                    content: detailResep['catatan'] ?? '-', // Use 'catatan'
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

  // --- Main Build Method (PASTIKAN INI ADA DI DALAM KELAS _EresepAdminPageState) ---
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
          });
        },
        searchHintText: 'Cari E-Resep...',
      ),
      body: _isLoadingData
          ? Center(
              child: CircularProgressIndicator(
              color: primaryColor,
            ))
          : RefreshIndicator(
              onRefresh: _fetchEresepData, // Allow pull to refresh
              child: CustomScrollView(
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),

                              // Categories / Status Filter Buttons
                              _buildCategoriesSection(),
                              const SizedBox(height: 16),

                              // List Resep Cards
                              displayedData.isEmpty && !_isLoadingData
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Text(
                                          _apiErrorMessage != null
                                              ? 'Error: $_apiErrorMessage'
                                              : 'Tidak ada E-Resep ditemukan.',
                                          textAlign: TextAlign.center,
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
                                                ? antreanMap[
                                                    resep['id_pendaftaran']]
                                                : null;
                                        return _buildResepCard(
                                            resep, currentAntreanNo);
                                      }).toList(),
                                    ),

                              // "Lihat Semua" button if more data
                              if (_filteredAndSortedData.length > 12 &&
                                  !_showAll)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(_showAll
                                          ? "Sembunyikan"
                                          : "Lihat Semua"),
                                    ),
                                  ),
                                ),
                              // "Sembunyikan" button if showing all
                              if (_filteredAndSortedData.length > 12 &&
                                  _showAll)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Center(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _showAll = !_showAll;
                                          _scrollController.animateTo(0,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeInOut);
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primaryColor,
                                        side: BorderSide(color: primaryColor),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text("Sembunyikan"),
                                    ),
                                  ),
                                ),

                              const SizedBox(
                                  height: 50), // Spacing at the bottom
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  // --- Helper Methods (THIS SECTION MUST BE WITHIN THE _EresepAdminPageState CLASS) ---

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
