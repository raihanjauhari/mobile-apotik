import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Import CustomHeader
import 'package:login_signup/widgets/menu.dart'; // Import CustomBottomNavBar
import 'package:login_signup/screens/signin_screen.dart';
import 'package:intl/intl.dart'; // Import for currency formatting
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'dart:convert'; // For JSON encoding/decoding

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
  // --- Colors (Consistent with other pages) ---
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color secondaryColor = const Color(0xFF6B8FB4);
  final Color accentColor =
      const Color(0xFFF0F4F8); // Warna latar belakang terang

  // --- Data from API ---
  List<Map<String, dynamic>> _resepList =
      []; // This will hold the combined data from API
  bool _isLoadingData = false; // To show loading indicator for API data
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

  // Priority map for sorting (still maintained for default sorting)
  final Map<String, int> _statusPriority = {
    "Diproses": 1, // Highest priority for "Antrian E-Resep"
    "Menunggu Pembayaran": 2,
    "Sudah Bayar": 3, // For "Menunggu Panggilan"
    "Selesai": 4, // Lowest priority
  };

  // --- UI State Variables untuk Header dan Menu ---
  int _selectedIndex =
      1; // Default selected index untuk EresepPage adalah 1 (0-Dashboard, 1-Eresep)
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  final TextEditingController _headerSearchController =
      TextEditingController(); // Controller untuk search bar di header

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _headerSearchController.addListener(() {
      setState(() {
        _searchText = _headerSearchController.text;
      });
    });
    _fetchEresepData(); // Initial data fetch from API
  }

  @override
  void dispose() {
    _scrollController
        .removeListener(_scrollListener); // FIXED: Pass the listener function
    _scrollController.dispose();
    _headerSearchController.dispose(); // Dispose header controller
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
      final responses = await Future.wait([
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/eresep')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/pasien')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/dokter')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/dilayani')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/memunculkan')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/obat')),
        http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/detail_eresep')),
      ]);

      for (var res in responses) {
        if (res.statusCode != 200) {
          throw Exception(
              'Failed to load data from API: ${res.request?.url.path} (Status: ${res.statusCode})');
        }
      }

      final List<dynamic> eresepData = json.decode(responses[0].body);
      final List<dynamic> pasienData = json.decode(responses[1].body);
      final List<dynamic> dokterData = json.decode(responses[2].body);
      final List<dynamic> dilayaniData = json.decode(responses[3].body);
      final List<dynamic> memunculkanData = json.decode(responses[4].body);
      final List<dynamic> obatData = json.decode(responses[5].body);
      final List<dynamic> detailEresepData = json.decode(responses[6].body);

      final Map<String, dynamic> pasienMap = {
        for (var p in pasienData) p['id_pendaftaran']: p
      };
      final Map<String, dynamic> dokterMap = {
        for (var d in dokterData) d['id_dokter'].toString(): d
      };
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
            : null;
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

  /// Updates the status of a prescription via API and refreshes the UI.
  Future<void> _updateResepStatus(String idResep, String newStatus) async {
    // <-- Parameter changed to idResep
    // Show loading indicator
    setState(() {
      _isLoadingData = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
            'https://ti054b05.agussbn.my.id/api/eresep/$idResep'), // <-- Using idResep here
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": newStatus}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Status resep $idResep diubah menjadi ${_statusDisplayMap[newStatus]}')), // <-- Message updated
          );
          // Re-fetch all data to ensure UI is fully consistent with the new state
          await _fetchEresepData();
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ??
            'Gagal update status resep. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false; // Hide loading
        });
      }
    }
  }

  /// Filters and sorts the prescription list based on current filters and search.
  List<Map<String, dynamic>> get _filteredAndSortedData {
    List<Map<String, dynamic>> data =
        List.from(_resepList); // Use _resepList from API

    // Filter by status
    if (_statusFilter != "Semua") {
      final targetStatus = _statusFilterMap[_statusFilter];
      data = data.where((resep) => resep['status'] == targetStatus).toList();
    }

    // Filter by search text
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

    // Sorting by status priority
    data.sort((a, b) {
      final aPriority = _statusPriority[a['status']] ?? 999;
      final bPriority = _statusPriority[b['status']] ?? 999;
      if (aPriority != bPriority) return aPriority.compareTo(bPriority);

      // Secondary sort by date (newest first)
      final aDate =
          DateTime.tryParse(a['tanggal_resep'] ?? '') ?? DateTime(1900);
      final bDate =
          DateTime.tryParse(b['tanggal_resep'] ?? '') ?? DateTime(1900);
      return bDate.compareTo(aDate);
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

                  // Print Resep Button (Petugas version might have different actions here)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
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

  // --- Widget Builders for Main Page Content ---

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
          _showSimpleModal(
              'Notifikasi', 'Anda memiliki beberapa notifikasi baru.');
        },
        searchController: _headerSearchController,
        onSearchChanged: (text) {
          setState(() {
            _searchText = text;
          });
        },
        searchHintText: 'Cari E-Resep di sini...',
      ),
      body: _isLoadingData
          ? Center(
              child: CircularProgressIndicator(
              color: primaryColor,
            ))
          : RefreshIndicator(
              onRefresh: _fetchEresepData,
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
                                'E-Resep',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Menampilkan daftar E-Resep pasien.',
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

                              const SizedBox(height: 24),

                              // Information & Tip Section
                              _buildInfoTipSection(),

                              const SizedBox(height: 24),

                              // View E-Prescription Guide
                              _buildPetunjukSection(),

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
          // Logika navigasi yang sama seperti di DashboardPetugas dan ObatPage
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPetugas()),
            );
          } else if (index == 1) {
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

  // --- Helper Methods (PASTIKAN SEMUA METHOD INI ADA DI DALAM KELAS _EresepPageState) ---

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

  /// Builds the categories/status filter section.
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 65, // Tinggi yang cukup untuk ikon
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _statusFilter = status;
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

  /// Builds a single prescription card for petugas.
  Widget _buildResepCard(Map<String, dynamic> resep, int? antreanNo) {
    String displayStatus =
        _statusDisplayMap[resep['status']] ?? resep['status'];
    Color statusColor;
    IconData statusIcon;

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

    Widget actionButtons;

    if (resep['status'] == "Menunggu Pembayaran") {
      actionButtons = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showResepDetailModal(resep),
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
                _updateResepStatus(resep['detail_resep']['id_resep'],
                    "Diproses"); // <-- Menggunakan id_eresep
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
      );
    } else if (resep['status'] == "Diproses") {
      actionButtons = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _updateResepStatus(resep['detail_resep']['id_resep'],
                "Selesai"); // <-- Menggunakan id_eresep
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
          onPressed: () => _showResepDetailModal(resep),
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
      actionButtons = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showResepDetailModal(resep),
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
