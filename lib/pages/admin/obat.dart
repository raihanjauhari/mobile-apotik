import 'package:flutter/material.dart';
import 'package:login_signup/widgets/header.dart'; // Import CustomHeader
import 'package:login_signup/widgets/menu.dart'; // Import CustomBottomNavBar
import 'package:login_signup/screens/signin_screen.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'dart:convert'; // For JSON encoding/decoding

// Import halaman-halaman admin lainnya untuk navigasi BottomNavBar
import 'package:login_signup/pages/admin/dashboard_admin.dart';
import 'package:login_signup/pages/admin/eresep.dart'; // Sesuaikan nama kelas jika berbeda
import 'package:login_signup/pages/admin/akun.dart'; // Sesuaikan nama kelas jika berbeda

// Definisi warna konsisten
const Color primaryColor = Color(0xFF2A4D69);
const Color secondaryColor = Color(0xFF6B8FB4);
const Color accentColor = Color(0xFFF0F4F8);
const Color greenAccent = Color(0xFF8BC34A);

// --- Widget untuk Form Tambah Obat (AddObatForm) ---
class AddObatForm extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onSuccess;

  const AddObatForm(
      {super.key, required this.onClose, required this.onSuccess});

  @override
  State<AddObatForm> createState() => _AddObatFormState();
}

class _AddObatFormState extends State<AddObatForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kodeObatController = TextEditingController();
  final TextEditingController _namaObatController = TextEditingController();
  final TextEditingController _hargaSatuanController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _kodeObatController.dispose();
    _namaObatController.dispose();
    _hargaSatuanController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final formData = {
      "kode_obat": _kodeObatController.text,
      "nama_obat": _namaObatController.text,
      "harga_satuan": int.parse(_hargaSatuanController.text),
      "stok": int.parse(_stokController.text),
      "deskripsi": _deskripsiController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("https://ti054b05api.agussbn.my.id/api/obat"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obat berhasil ditambahkan!')),
        );
        widget.onSuccess();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menambahkan obat');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_errorMessage')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
    IconData? prefixIcon, // New parameter for prefix icon
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style:
          const TextStyle(color: primaryColor), // Text color inside the field
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: primaryColor.withOpacity(0.7))
            : null,
        alignLabelWithHint: true,
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Remove default border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: readOnly ? Colors.grey : primaryColor.withOpacity(0.3),
              width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: primaryColor.withOpacity(0.8)),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)), // Sudut lebih membulat
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: accentColor, // Latar belakang form
        appBar: AppBar(
          title: Text(
            'Tambah Data Obat',
            style: TextStyle(
                color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 2, // Sedikit bayangan
          leading: IconButton(
            icon: Icon(Icons.close, color: primaryColor),
            onPressed: widget.onClose,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              24.0, 24.0, 24.0, 16.0), // Padding bawah dikurangi
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize:
                  MainAxisSize.min, // Penting untuk meminimalkan tinggi
              children: [
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _buildTextField(
                  controller: _kodeObatController,
                  labelText: 'Kode Obat',
                  hintText: 'Cth: OBT001',
                  prefixIcon: Icons.vpn_key_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode Obat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _namaObatController,
                  labelText: 'Nama Obat',
                  hintText: 'Cth: Paracetamol 500mg',
                  prefixIcon: Icons.local_pharmacy_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Obat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _hargaSatuanController,
                  labelText: 'Harga Satuan',
                  hintText: 'Cth: 6000',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga Satuan tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Harga harus angka positif';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _stokController,
                  labelText: 'Stok',
                  hintText: 'Cth: 150',
                  prefixIcon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Stok harus angka positif';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _deskripsiController,
                  labelText: 'Deskripsi',
                  hintText: 'Cth: Obat pereda nyeri dan demam.',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 24), // Mengurangi jarak sebelum tombol
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // Sudut tombol lebih besar
                    ),
                    elevation: 5, // Efek bayangan tombol
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Simpan Obat',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                ),
                const SizedBox(height: 8), // Mengurangi jarak setelah tombol
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Widget untuk Form Edit Obat (EditObatForm) ---
class EditObatForm extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSuccess;
  final Map<String, dynamic> dataObat;

  const EditObatForm({
    super.key,
    required this.onClose,
    required this.onSuccess,
    required this.dataObat,
  });

  @override
  State<EditObatForm> createState() => _EditObatFormState();
}

class _EditObatFormState extends State<EditObatForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeObatController;
  late TextEditingController _namaObatController;
  late TextEditingController _hargaSatuanController;
  late TextEditingController _stokController;
  late TextEditingController _deskripsiController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _kodeObatController =
        TextEditingController(text: widget.dataObat['kode_obat']);
    _namaObatController =
        TextEditingController(text: widget.dataObat['nama_obat']);
    _hargaSatuanController =
        TextEditingController(text: widget.dataObat['harga_satuan'].toString());
    _stokController =
        TextEditingController(text: widget.dataObat['stok'].toString());
    _deskripsiController =
        TextEditingController(text: widget.dataObat['deskripsi']);
  }

  @override
  void dispose() {
    _kodeObatController.dispose();
    _namaObatController.dispose();
    _hargaSatuanController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final formData = {
      "id": widget.dataObat['id'], // Pastikan ID dikirim untuk identifikasi
      "kode_obat": _kodeObatController.text,
      "nama_obat": _namaObatController.text,
      "harga_satuan": int.parse(_hargaSatuanController.text),
      "stok": int.parse(_stokController.text),
      "deskripsi": _deskripsiController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(
            "https://ti054b05api.agussbn.my.id/api/obat/${formData['kode_obat']}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obat berhasil diupdate!')),
        );
        widget.onSuccess(formData); // Pass updated data back
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengupdate obat');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_errorMessage')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
    IconData? prefixIcon, // New parameter for prefix icon
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style:
          const TextStyle(color: primaryColor), // Text color inside the field
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: primaryColor.withOpacity(0.7))
            : null,
        alignLabelWithHint: true,
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Remove default border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: readOnly ? Colors.grey : primaryColor.withOpacity(0.3),
              width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: primaryColor.withOpacity(0.8)),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)), // Sudut lebih membulat
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: accentColor, // Latar belakang form
        appBar: AppBar(
          title: Text(
            'Edit Data Obat',
            style: TextStyle(
                color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 2, // Sedikit bayangan
          leading: IconButton(
            icon: Icon(Icons.close, color: primaryColor),
            onPressed: widget.onClose,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              24.0, 24.0, 24.0, 16.0), // Padding bawah dikurangi
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize:
                  MainAxisSize.min, // Penting untuk meminimalkan tinggi
              children: [
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _buildTextField(
                  controller: _kodeObatController,
                  labelText: 'Kode Obat',
                  hintText: 'Kode tidak dapat diubah',
                  prefixIcon:
                      Icons.vpn_key_off_rounded, // Ganti ikon untuk readOnly
                  readOnly: true, // Kode Obat tidak bisa diubah
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _namaObatController,
                  labelText: 'Nama Obat',
                  hintText: 'Cth: Amoxicillin 250mg',
                  prefixIcon: Icons.local_pharmacy_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Obat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _hargaSatuanController,
                  labelText: 'Harga Satuan',
                  hintText: 'Cth: 3000',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga Satuan tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Harga harus angka positif';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _stokController,
                  labelText: 'Stok',
                  hintText: 'Cth: 80',
                  prefixIcon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Stok harus angka positif';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _deskripsiController,
                  labelText: 'Deskripsi',
                  hintText: 'Cth: Antibiotik untuk infeksi bakteri.',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 24), // Mengurangi jarak sebelum tombol
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // Sudut tombol lebih besar
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                ),
                const SizedBox(height: 8), // Mengurangi jarak setelah tombol
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Main ObatAdminPage Widget ---
class ObatAdminPage extends StatefulWidget {
  const ObatAdminPage({super.key});

  @override
  State<ObatAdminPage> createState() => _ObatAdminPageState();
}

class _ObatAdminPageState extends State<ObatAdminPage> {
  List<Map<String, dynamic>> _originalObatList = [];
  String _statusFilter = "Semua";
  String _searchText = "";
  bool _showAll = false;
  bool _isLoadingData = false;

  int _selectedIndex = 2; // Index untuk Obat di BottomNavBar
  final TextEditingController _headerSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  // --- Mock Data Obat (sesuaikan jika Anda sudah punya API) ---
  final List<Map<String, dynamic>> _mockObatList = [
    {
      "id": "1", // Tambahkan ID untuk operasi edit/hapus
      "kode_obat": "OBT001",
      "nama_obat": "Paracetamol 500mg",
      "stok": 150,
      "harga_satuan": 6000,
      "deskripsi": "Obat pereda nyeri dan demam."
    },
    {
      "id": "2",
      "kode_obat": "OBT002",
      "nama_obat": "Amoxicillin 250mg",
      "stok": 80,
      "harga_satuan": 3000,
      "deskripsi": "Antibiotik untuk infeksi bakteri."
    },
    {
      "id": "3",
      "kode_obat": "OBT003",
      "nama_obat": "Vitamin C 1000mg",
      "stok": 200,
      "harga_satuan": 75000,
      "deskripsi": "Suplemen untuk daya tahan tubuh."
    },
    {
      "id": "4",
      "kode_obat": "OBT004",
      "nama_obat": "Ibuprofen 250mg",
      "stok": 0, // Stok Habis
      "harga_satuan": 12000,
      "deskripsi": "Obat anti-inflamasi non-steroid."
    },
    {
      "id": "5",
      "kode_obat": "OBT005",
      "nama_obat": "Dexamethasone 0.5mg",
      "stok": 120,
      "harga_satuan": 1000,
      "deskripsi": "Obat kortikosteroid untuk alergi dan radang."
    },
    {
      "id": "6",
      "kode_obat": "OBT006",
      "nama_obat": "Lansoprazole 30 mg",
      "stok": 90,
      "harga_satuan": 15000,
      "deskripsi": "Obat untuk meredakan gejala asam lambung."
    },
    {
      "id": "7",
      "kode_obat": "OBT007",
      "nama_obat": "Betadine Solution",
      "stok": 50,
      "harga_satuan": 8000,
      "deskripsi": "Antiseptik untuk luka."
    },
    {
      "id": "8",
      "kode_obat": "OBT008",
      "nama_obat": "Counterpain Cream",
      "stok": 0, // Stok Habis
      "harga_satuan": 12000,
      "deskripsi": "Krim pereda nyeri otot."
    },
    {
      "id": "9",
      "kode_obat": "OBT009",
      "nama_obat": "Diapet",
      "stok": 75,
      "harga_satuan": 1500,
      "deskripsi": "Obat diare herbal."
    },
    {
      "id": "10",
      "kode_obat": "OBT010",
      "nama_obat": "Bodrex Migra",
      "stok": 110,
      "harga_satuan": 1800,
      "deskripsi": "Obat untuk sakit kepala migrain."
    },
    {
      "id": "11",
      "kode_obat": "OBT011",
      "nama_obat": "Promag",
      "stok": 0, // Stok Habis
      "harga_satuan": 1200,
      "deskripsi": "Obat sakit maag."
    },
    {
      "id": "12",
      "kode_obat": "OBT012",
      "nama_obat": "Biogesic",
      "stok": 130,
      "harga_satuan": 1400,
      "deskripsi": "Paracetamol merek lain."
    },
    {
      "id": "13",
      "kode_obat": "OBT013",
      "nama_obat": "Sanmol",
      "stok": 95,
      "harga_satuan": 1600,
      "deskripsi": "Obat penurun panas dan pereda nyeri."
    },
    {
      "id": "14",
      "kode_obat": "OBT014",
      "nama_obat": "OBH Combi",
      "stok": 60,
      "harga_satuan": 7000,
      "deskripsi": "Obat batuk berdahak dan pilek."
    },
    {
      "id": "15",
      "kode_obat": "OBT015",
      "nama_obat": "FreshCare Roll On",
      "stok": 25,
      "harga_satuan": 9500,
      "deskripsi": "Minyak angin aroma terapi."
    },
  ];

  @override
  void initState() {
    super.initState();
    _originalObatList = List<Map<String, dynamic>>.from(
        _mockObatList); // Initialize with mock data
    _scrollController.addListener(_scrollListener);
    _headerSearchController.addListener(() {
      setState(() {
        _searchText = _headerSearchController.text;
      });
    });
    _fetchObat(); // Initial fetch
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _headerSearchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _showScrollToTopButton = _scrollController.offset >= 400;
    });
  }

  void _showSimpleModal(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: primaryColor)),
          content: SingleChildScrollView(
            child: Text(content),
          ),
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

  // --- Simulate API calls ---
  Future<void> _fetchObat() async {
    setState(() {
      _isLoadingData = true;
    });
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    setState(() {
      _originalObatList =
          List<Map<String, dynamic>>.from(_mockObatList); // Reload mock data
      _isLoadingData = false;
    });
  }

  Future<void> _addObat(Map<String, dynamic> newObat) async {
    setState(() {
      newObat['id'] = (_originalObatList.length + 1).toString();
      _originalObatList.add(newObat);
    });
    await _fetchObat(); // Re-fetch to apply sort/filter on new data
  }

  Future<void> _editObat(Map<String, dynamic> updatedObat) async {
    setState(() {
      final index =
          _originalObatList.indexWhere((o) => o['id'] == updatedObat['id']);
      if (index != -1) {
        _originalObatList[index] = updatedObat;
      }
    });
    await _fetchObat(); // Re-fetch to apply sort/filter on updated data
  }

  // METHOD _deleteObat DIHAPUS SEPENUHNYA SESUAI PERMINTAAN

  List<Map<String, dynamic>> get _filteredAndSortedData {
    List<Map<String, dynamic>> data = List.from(_originalObatList);

    if (_statusFilter == "Stok Habis") {
      data = data.where((obat) => obat['stok'] == 0).toList();
    }

    if (_searchText.isNotEmpty) {
      final lowerSearch = _searchText.toLowerCase();
      data = data.where((obat) {
        return (obat['kode_obat']?.toLowerCase().contains(lowerSearch) ??
                false) ||
            (obat['nama_obat']?.toLowerCase().contains(lowerSearch) ?? false);
      }).toList();
    }

    data.sort((a, b) {
      return (a['nama_obat'] as String)
          .toLowerCase()
          .compareTo((b['nama_obat'] as String).toLowerCase());
    });

    return data;
  }

  void _handleShowAddForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddObatForm(
          onClose: () => Navigator.of(context).pop(),
          onSuccess: () {
            _fetchObat(); // Refresh data after adding
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _handleEditObat(Map<String, dynamic> obat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditObatForm(
          dataObat: obat,
          onClose: () => Navigator.of(context).pop(),
          onSuccess: (updatedData) {
            _fetchObat(); // Refresh data after editing
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // --- Widget untuk menampilkan detail di modal ---
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)), // Sudut lebih membulat
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Sudut lebih membulat
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15), // Bayangan lebih halus
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24), // Padding lebih besar
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Center(
                    child: Text(
                      obat['nama_obat'] ?? 'Detail Obat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24, // Ukuran font lebih besar
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                  ),
                  const Divider(
                      height: 25,
                      thickness: 1.5,
                      color: accentColor), // Divider lebih tebal
                  const SizedBox(height: 15),
                  Center(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(15), // Sudut gambar membulat
                      child: Image.asset(
                        'assets/images/obat.jpg', // Pastikan path asset ini benar di pubspec.yaml
                        width: 180, // Ukuran gambar lebih besar
                        height: 180, // Ukuran gambar lebih besar
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                              'ERROR: Gagal memuat aset gambar: assets/images/obat.jpg');
                          return Icon(Icons.broken_image,
                              size: 120,
                              color: Colors
                                  .grey[300]); // Ukuran ikon error lebih besar
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
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
                    valueColor: obat['stok'] == 0
                        ? Colors.red
                        : primaryColor, // Warna stok sesuai
                  ),
                  _buildDetailRow("Lokasi", "Banjarmasin", Icons.location_on),
                  const SizedBox(height: 25),
                  _buildSectionCard(
                    title: "Deskripsi Obat",
                    content: obat['deskripsi'] ?? '-',
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(); // Tutup modal detail
                        _handleEditObat(obat); // Buka modal edit
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit Obat',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                            vertical: 14), // Padding lebih besar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Sudut tombol membulat
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14), // Padding lebih besar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Sudut tombol membulat
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

  /// Helper untuk membangun baris detail dengan ikon, label, dan nilai.
  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: primaryColor), // Ukuran ikon lebih besar
          const SizedBox(width: 15), // Jarak lebih besar
          Expanded(
            // Wrap with Expanded for better text handling
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 14, // Ukuran font label
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                const SizedBox(height: 4), // Jarak lebih besar
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 17, // Ukuran font nilai
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk membangun kartu bagian dengan judul, konten, dan ikon.
  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18), // Padding lebih besar
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(15), // Sudut lebih membulat
        border: Border.all(
            color: Colors.grey.shade300, width: 1.0), // Border lebih terlihat
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 22, color: primaryColor), // Ukuran ikon lebih besar
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 17, // Ukuran font judul
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.5), // Line height
          ),
        ],
      ),
    );
  }

  // --- Widget untuk Kartu Grid Obat ---
  Widget _buildMedicineGridCards(List<Map<String, dynamic>> data) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Tidak ada data obat ditemukan.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18.0, // Jarak antar kartu
        mainAxisSpacing: 18.0, // Jarak antar kartu
        childAspectRatio:
            0.8, // Sesuaikan rasio untuk tampilan yang lebih baik, sedikit lebih tinggi
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final obat = data[index];
        final isStokHabis = obat['stok'] == 0;

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(15)), // Sudut kartu lebih membulat
          elevation: 4, // Bayangan kartu lebih terlihat
          child: InkWell(
            onTap: () {
              _showObatDetailModal(obat); // Menampilkan modal detail obat
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Warna latar belakang gambar
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(
                              15)), // Sudut atas gambar membulat
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/obat.jpg', // Pastikan asset ini ada
                        width: double.infinity, // Mengisi lebar container
                        height: double.infinity, // Mengisi tinggi container
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                              'ERROR: Gagal memuat aset gambar: assets/images/obat.jpg');
                          return Icon(Icons.broken_image,
                              size: 60,
                              color: Colors
                                  .grey[400]); // Ukuran ikon error lebih besar
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0), // Padding lebih besar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          obat['nama_obat'] ?? 'Nama Obat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17, // Ukuran font lebih besar
                            color: primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6), // Jarak lebih besar
                        Text(
                          formatCurrency.format(obat['harga_satuan']),
                          style: TextStyle(
                            fontSize: 19, // Ukuran font harga lebih besar
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 18,
                                    color:
                                        Colors.grey[600]), // Ukuran ikon lokasi
                                const SizedBox(width: 6),
                                const Text(
                                  "Banjarmasin", // Lokasi hardcoded "Banjarmasin"
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                            if (isStokHabis) // Tampilkan badge "Stok Habis"
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4), // Padding badge
                                decoration: BoxDecoration(
                                  color:
                                      Colors.red[600], // Warna merah lebih kuat
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Stok Habis',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11, // Ukuran font badge
                                      fontWeight: FontWeight.bold),
                                ),
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

  // --- Widget for the "Track Your Meds!" Banner ---
  Widget _buildTrackYourMedsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0), // Padding lebih besar
      decoration: BoxDecoration(
        color: primaryColor, // Warna latar belakang banner
        borderRadius: BorderRadius.circular(15), // Sudut lebih membulat
        image: const DecorationImage(
          image: AssetImage(
              'assets/images/banner_bg.png'), // Pastikan path ini benar di pubspec.yaml
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pantau Obatmu!', // Teks lebih menarik
            style: TextStyle(
              color: Colors.white,
              fontSize: 22, // Ukuran font lebih besar
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8, // Sedikit letter spacing
            ),
          ),
          const SizedBox(height: 6), // Jarak lebih besar
          const Text(
            'Simpan obat di tempat sejuk dan kering untuk menjaga kualitasnya.', // Teks lebih informatif
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _showSimpleModal(
                  "Pantau Obat", "Fitur pelacakan obat akan datang!");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  secondaryColor, // Gunakan warna kontras untuk tombol
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Sudut tombol membulat
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14), // Padding lebih besar
              elevation: 3,
            ),
            child: const Text('Pelajari Lebih Lanjut',
                style: TextStyle(fontSize: 16)), // Teks tombol lebih jelas
          ),
        ],
      ),
    );
  }

  // --- Widget for Filter Status Buttons (Semua, Stok Habis) ---
  Widget _buildFilterStatusButtons() {
    final List<String> filterOptions = ["Semua", "Stok Habis"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: filterOptions.map((label) {
          return Padding(
            padding: const EdgeInsets.only(right: 10.0), // Jarak antar chip
            child: ChoiceChip(
              label: Text(
                label,
                style: TextStyle(
                  color: _statusFilter == label ? Colors.white : primaryColor,
                  fontWeight: _statusFilter == label
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              selected: _statusFilter == label,
              selectedColor: label == "Semua" ? greenAccent : primaryColor,
              backgroundColor: Colors.white,
              side: BorderSide(
                  color: _statusFilter == label
                      ? Colors.transparent
                      : primaryColor.withOpacity(0.5)),
              onSelected: (selected) {
                setState(() {
                  _statusFilter = label;
                });
              },
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12), // Padding chip
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // Sudut chip membulat
              ),
              elevation: 3, // Bayangan chip
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedData = _showAll
        ? _filteredAndSortedData
        : _filteredAndSortedData
            .take(4)
            .toList(); // Show first 4 by default, then all

    return Scaffold(
      backgroundColor: accentColor,
      appBar: CustomHeader(
        searchController: _headerSearchController,
        onSearchChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        primaryColor:
            primaryColor, // Pastikan CustomHeader menerima primaryColor
        onNotificationPressed: () {
          _showSimpleModal(
              'Notifikasi', 'Anda memiliki beberapa notifikasi baru.');
        },
        searchHintText: 'Cari obat...',
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchObat,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20.0), // Padding halaman utama
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Obat', // Judul lebih relevan
                    style: TextStyle(
                        fontSize: 28, // Ukuran font lebih besar
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kelola semua data obat yang tersedia di inventaris Anda dengan mudah.', // Subtitle lebih deskriptif
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  _buildTrackYourMedsBanner(), // Banner
                  const SizedBox(height: 30), // Jarak lebih besar

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Obat Tersedia', // Judul bagian
                        style: TextStyle(
                            fontSize: 22, // Ukuran font lebih besar
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      ElevatedButton.icon(
                        onPressed: _handleShowAddForm,
                        icon: const Icon(
                            Icons.add_circle_outline, // Ikon lebih deskriptif
                            size: 22,
                            color: Colors.white),
                        label: const Text('Tambah Obat',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16)), // Teks tombol lebih ringkas
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildFilterStatusButtons(), // Filter status
                  const SizedBox(height: 24), // Jarak lebih besar

                  _isLoadingData
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMedicineGridCards(displayedData), // Grid Obat

                  if (_filteredAndSortedData.length >
                      4) // Show "Lihat Semua" only if there are more than 4 items
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showAll = !_showAll;
                            });
                            // Scroll to top or bottom when toggling "Lihat Semua"
                            if (_showAll) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14), // Padding lebih besar
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                              _showAll
                                  ? "Sembunyikan Daftar"
                                  : "Lihat Semua Obat",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  const SizedBox(
                      height:
                          60), // Spasi di bagian bawah agar tidak terpotong BottomNavBar
                ],
              ),
            ),
          ),
          if (_showScrollToTopButton)
            Positioned(
              bottom: 80.0, // Di atas BottomNavBar
              right: 20.0, // Jarak dari kanan
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: primaryColor,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex, // Menggunakan currentIndex
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardAdmin()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const EresepAdminPage()),
              );
              break;
            case 2:
              // Current page, do nothing or refresh
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AkunAdminPage()),
              );
              break;
            case 4: // Misal index 4 untuk logout
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (Route<dynamic> route) => false,
              );
              break;
          }
        },
        // Pastikan parameter-parameter ini diterima oleh CustomBottomNavBar
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600]!,
        primaryColor: primaryColor,
      ),
    );
  }
}
