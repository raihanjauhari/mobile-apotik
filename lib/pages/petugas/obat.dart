import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang
import 'package:login_signup/widgets/header.dart';
import 'package:login_signup/widgets/menu.dart';
import 'package:login_signup/screens/signin_screen.dart';

// Import halaman-halaman utama lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/petugas/dashboard_petugas.dart';
import 'package:login_signup/pages/petugas/eresep.dart';
import 'package:login_signup/pages/petugas/akun.dart';

class ObatPage extends StatefulWidget {
  const ObatPage({super.key});

  @override
  State<ObatPage> createState() => _ObatPageState();
}

class _ObatPageState extends State<ObatPage> {
  // --- Colors (Salin dari DashboardPetugas agar konsisten) ---
  final Color primaryColor = const Color(0xFF2A4D69);
  final Color secondaryColor = const Color(0xFF6B8FB4);
  final Color accentColor =
      const Color(0xFFF0F4F8); // Warna latar belakang terang
  final Color greenAccent = const Color(0xFF8BC34A); // Warna hijau untuk "All"

  // --- Mock Data Obat ---
  List<Map<String, dynamic>> _mockObatList = [
    {
      "kode_obat": "OBT001",
      "nama_obat": "Paracetamol 500mg",
      "stok": 150,
      "harga_satuan": 6000,
      "deskripsi": "Obat pereda nyeri dan demam.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT002",
      "nama_obat": "Amoxicillin 250mg",
      "stok": 80,
      "harga_satuan": 3000,
      "deskripsi": "Antibiotik untuk infeksi bakteri.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT003",
      "nama_obat": "Vitamin C 1000mg",
      "stok": 200,
      "harga_satuan": 75000,
      "deskripsi": "Suplemen untuk daya tahan tubuh.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT004",
      "nama_obat": "Ibuprofen 250mg",
      "stok": 0, // Stok Habis
      "harga_satuan": 12000,
      "deskripsi": "Obat anti-inflamasi non-steroid.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT005",
      "nama_obat": "Dexamethasone 0.5mg",
      "stok": 120,
      "harga_satuan": 1000,
      "deskripsi": "Obat kortikosteroid untuk alergi dan radang.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT006",
      "nama_obat": "Lansoprazole 30 mg",
      "stok": 90,
      "harga_satuan": 15000,
      "deskripsi": "Obat untuk meredakan gejala asam lambung.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT007",
      "nama_obat": "Betadine Solution",
      "stok": 50,
      "harga_satuan": 8000,
      "deskripsi": "Antiseptik untuk luka.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT008",
      "nama_obat": "Counterpain Cream",
      "stok": 0, // Stok Habis
      "harga_satuan": 12000,
      "deskripsi": "Krim pereda nyeri otot.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT009",
      "nama_obat": "Diapet",
      "stok": 75,
      "harga_satuan": 1500,
      "deskripsi": "Obat diare herbal.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT010",
      "nama_obat": "Bodrex Migra",
      "stok": 110,
      "harga_satuan": 1800,
      "deskripsi": "Obat untuk sakit kepala migrain.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT011",
      "nama_obat": "Promag",
      "stok": 0, // Stok Habis
      "harga_satuan": 1200,
      "deskripsi": "Obat sakit maag.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT012",
      "nama_obat": "Biogesic",
      "stok": 130,
      "harga_satuan": 1400,
      "deskripsi": "Paracetamol merek lain.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT013",
      "nama_obat": "Sanmol",
      "stok": 95,
      "harga_satuan": 1600,
      "deskripsi": "Obat penurun panas dan pereda nyeri.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT014",
      "nama_obat": "OBH Combi",
      "stok": 60,
      "harga_satuan": 7000,
      "deskripsi": "Obat batuk berdahak dan pilek.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
    {
      "kode_obat": "OBT015",
      "nama_obat": "FreshCare Roll On",
      "stok": 25,
      "harga_satuan": 9500,
      "deskripsi": "Minyak angin aroma terapi.",
      // "location": "Banjarmasin" // LOKASI DIHAPUS DARI DATA MOCK
    },
  ];

  // --- Filter and Search State ---
  String _statusFilter = "Semua"; // Mengubah default menjadi "Semua"
  String _searchText = ""; // Search text from header
  bool _showAll = false; // To show all items if there are more than 12

  // --- UI State Variables ---
  int _selectedIndex =
      2; // Default selected index untuk ObatPage adalah 2 (asumsi: 0-Dashboard, 1-Eresep, 2-Obat)
  final TextEditingController _headerSearchController =
      TextEditingController(); // Menggunakan controller ini untuk search bar di header

  @override
  void initState() {
    super.initState();
    _headerSearchController.addListener(() {
      if (_headerSearchController.text != _searchText) {
        setState(() {
          _searchText = _headerSearchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _headerSearchController.dispose();
    super.dispose();
  }

  // --- Methods ---

  /// Shows a simple modal dialog with a title and content.
  void _showSimpleModal(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
              child: Text(content)), // Wrap content in SingleChildScrollView
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

  /// Filters and sorts the medicine list based on current filters and search.
  List<Map<String, dynamic>> get _filteredData {
    List<Map<String, dynamic>> data = List.from(_mockObatList);

    // 1. Filter by status (Semua, Stok Habis)
    if (_statusFilter == "Stok Habis") {
      data = data.where((obat) => obat['stok'] == 0).toList();
    } // Jika _statusFilter adalah "Semua", tidak ada filter tambahan

    // 2. Filter by search text (using the header's search controller text)
    if (_searchText.isNotEmpty) {
      final lowerSearch = _searchText.toLowerCase();
      data = data.where((obat) {
        return (obat['kode_obat']?.toLowerCase().contains(lowerSearch) ??
                false) ||
            (obat['nama_obat']?.toLowerCase().contains(lowerSearch) ?? false);
      }).toList();
    }

    // Untuk tampilan obat yang fokus pada gambar dan harga, sortir berdasarkan nama obat default
    data.sort((a, b) {
      return (a['nama_obat'] as String)
          .toLowerCase()
          .compareTo((b['nama_obat'] as String).toLowerCase());
    });

    return data;
  }

  /// Shows a detailed modal for a selected medicine.
  void _showObatDetailModal(Map<String, dynamic> obat) {
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
          backgroundColor: Colors.transparent,
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
                  // Judul dan tidak ada tombol 'x'
                  Center(
                    child: Text(
                      obat['nama_obat'] ?? 'Detail Obat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                  ),
                  const Divider(height: 20, thickness: 1),
                  const SizedBox(height: 10),

                  // Image (if applicable)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        '../../assets/images/obat.jpg', // Placeholder image
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.medication,
                              size: 100, color: Colors.grey[300]);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildDetailRow(
                      "Kode Obat", obat['kode_obat'] ?? '-', Icons.qr_code),
                  _buildDetailRow(
                      "Harga Satuan",
                      formatCurrency.format(obat['harga_satuan'] ?? 0),
                      Icons.money),
                  _buildDetailRow(
                      "Stok Tersedia",
                      obat['stok'] != null ? '${obat['stok']} Unit' : '-',
                      Icons.inventory,
                      valueColor: obat['stok'] == 0 ? Colors.red : null),
                  _buildDetailRow("Lokasi", "Banjarmasin",
                      Icons.location_on), // Hardcoded location
                  const SizedBox(height: 20),

                  _buildSectionCard(
                    title: "Deskripsi Obat",
                    content: obat['deskripsi'] ?? '-',
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Tutup",
                        style: TextStyle(fontSize: 16),
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

  /// Helper for building a detail row with an icon, label, and value.
  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87),
              ),
            ],
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

  // --- New Widgets for the Visual Design ---

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedData = _showAll
        ? _filteredData
        : _filteredData
            .take(4)
            .toList(); // Hanya tampilkan 4 item awal seperti di gambar

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
        searchHintText: 'Cari Obat di sini...',
      ),
      body: CustomScrollView(
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
                        'Obat',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      const SizedBox(height: 16),

                      // Banner "Track your meds!"
                      _buildTrackYourMedsBanner(),
                      const SizedBox(height: 24),

                      // Filter Status Buttons (Semua, Stok Habis)
                      _buildFilterStatusButtons(),
                      const SizedBox(height: 24),

                      // Medicine List Cards in a Grid
                      _buildMedicineGridCards(displayedData),

                      // "Lihat Semua" button if more data
                      if (_filteredData.length >
                          4) // Sesuaikan dengan 4 item awal
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
                      const SizedBox(height: 50), // Spasi di bagian bawah
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
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPetugas()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EresepPage()),
            );
          } else if (index == 2) {
            print("Sudah di halaman Obat.");
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
    );
  }

  Widget _buildTrackYourMedsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: primaryColor, // Warna latar belakang banner
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage(
              '../../assets/images/banner_bg.png'), // Path relatif diperbarui
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pantau obatmu!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Simpan obat di tempat sejuk dan kering',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _showSimpleModal(
                  "Track Your Meds", "Fitur pelacakan obat akan datang!");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  primaryColor, // Tombol banner sekarang primaryColor
              foregroundColor: Colors.white, // Teks tombol putih
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Lihat'),
          ),
        ],
      ),
    );
  }

  // Mengganti _buildCategoryFilterButtons menjadi _buildFilterStatusButtons (nama method baru)
  // Logikanya disederhanakan hanya untuk "Semua" dan "Stok Habis"
  Widget _buildFilterStatusButtons() {
    final List<String> filterOptions = [
      "Semua",
      "Stok Habis"
    ]; // Hanya dua opsi ini

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: filterOptions.map((label) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0), // Spasi antar chip
            child: _buildStatusChip(label), // Memanggil fungsi chip
          );
        }).toList(),
      ),
    );
  }

  // Mengganti _buildCategoryChip menjadi _buildStatusChip (nama method baru)
  Widget _buildStatusChip(String label) {
    final bool isSelected = _statusFilter == label; // Menggunakan _statusFilter
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : primaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: label == "Semua"
          ? greenAccent
          : primaryColor, // Warna hijau untuk "Semua"
      backgroundColor: Colors.white,
      side: BorderSide(
          color:
              isSelected ? Colors.transparent : primaryColor.withOpacity(0.5)),
      onSelected: (selected) {
        setState(() {
          _statusFilter = label; // Update _statusFilter
        });
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2, // Tambahkan sedikit elevasi
    );
  }

  Widget _buildMedicineGridCards(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Tidak ada data obat ditemukan untuk filter ini.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true, // Agar tinggi mengikuti konten
      physics:
          const NeverScrollableScrollPhysics(), // Nonaktifkan scroll internal GridView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 kolom
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio:
            0.85, // Rasio lebar/tinggi kartu, disesuaikan untuk mengatasi overflow
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final obat = data[index];

        return Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: InkWell(
            // Kembali menggunakan InkWell untuk aksi klik modal
            onTap: () {
              // Tampilkan modal dengan detail penuh saat kartu diklik
              _showObatDetailModal(obat); // Menggunakan modal baru
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Obat
                Expanded(
                  flex: 3, // Mengambil 3/5 tinggi kartu untuk gambar
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[
                          200], // Warna latar belakang jika gambar tidak ada
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Image.asset(
                        '../../assets/images/obat.jpg', // LANGSUNG MENGGUNAKAN OBAT.JPG
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Debugging gambar: Cetak path aset yang dicoba dimuat
                          debugPrint(
                              'ERROR: Gagal memuat aset gambar: ../../assets/images/obat.jpg');
                          return const Icon(
                              Icons
                                  .broken_image, // Ikon jika gambar gagal dimuat
                              size: 50,
                              color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                ),
                // Detail Obat (Nama, Harga, Lokasi) - Langsung di kartu, sesuai gambar
                Expanded(
                  flex: 2, // Mengambil 2/5 tinggi kartu untuk detail teks
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Padding disesuaikan
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Jaga agar konten merata
                      children: [
                        Text(
                          obat['nama_obat'] ?? 'Nama Obat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp. ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(obat['harga_satuan'])}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const Spacer(), // Dorong konten ke bawah
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "Banjarmasin", // Lokasi hardcode "Banjarmasin"
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
