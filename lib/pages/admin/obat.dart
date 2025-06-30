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

// Definisi warna konsisten (tetap global)
const Color primaryColor = Color(0xFF2A4D69);
const Color secondaryColor = Color(0xFF6B8FB4);
const Color accentColor = Color(0xFFF0F4F8);
const Color greenAccent = Color(0xFF8BC34A);
const Color redColor = Color(0xFFD32F2F); // Untuk error messages

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
      "id_user": "U002" // Hardcoded ID User sesuai data API yang diberikan
    };

    try {
      final response = await http.post(
        Uri.parse("https://ti054b05.agussbn.my.id/api/obat"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Obat berhasil ditambahkan!')),
          );
          widget.onSuccess();
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menambahkan obat');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains("Failed host lookup")
              ? "Tidak ada koneksi internet atau server tidak dapat dijangkau."
              : e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: primaryColor),
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
          borderSide: BorderSide.none,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: accentColor,
        appBar: AppBar(
          title: Text(
            'Tambah Data Obat',
            style: TextStyle(
                color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: Icon(Icons.close, color: primaryColor),
            onPressed: widget.onClose,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
                          'Simpan Obat',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                ),
                const SizedBox(height: 8),
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
      "kode_obat": _kodeObatController.text,
      "nama_obat": _namaObatController.text,
      "harga_satuan": int.parse(_hargaSatuanController.text),
      "stok": int.parse(_stokController.text),
      "deskripsi": _deskripsiController.text,
      "id_user": widget.dataObat['id_user'] ??
          "U002" // Pastikan id_user tetap ada atau default
    };

    try {
      final response = await http.put(
        Uri.parse(
            "https://ti054b05.agussbn.my.id/api/obat/${widget.dataObat['kode_obat']}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Obat berhasil diupdate!')),
          );
          widget.onSuccess({
            ...widget.dataObat, // Pertahankan ID asli jika ada
            ...formData, // Timpa dengan data yang diupdate
          });
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengupdate obat');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains("Failed host lookup")
              ? "Tidak ada koneksi internet atau server tidak dapat dijangkau."
              : e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: primaryColor),
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
          borderSide: BorderSide.none,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: accentColor,
        appBar: AppBar(
          title: Text(
            'Edit Data Obat',
            style: TextStyle(
                color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: Icon(Icons.close, color: primaryColor),
            onPressed: widget.onClose,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
                const SizedBox(height: 8),
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
  // Gunakan List ini untuk menyimpan data dari API
  List<Map<String, dynamic>> _obatList = [];
  String _statusFilter = "Semua";
  String _searchText = "";
  bool _showAll = false;
  bool _isLoadingData = false; // Status loading untuk data utama
  String? _apiErrorMessage; // Untuk error dari fetch data

  int _selectedIndex = 2; // Index untuk Obat di BottomNavBar
  final TextEditingController _headerSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _headerSearchController.addListener(() {
      setState(() {
        _searchText = _headerSearchController.text;
      });
    });
    _fetchObat(); // Panggil fungsi untuk mengambil data obat dari API
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

  // --- API Calls ---

  /// Mengambil data obat dari API
  Future<void> _fetchObat() async {
    setState(() {
      _isLoadingData = true;
      _apiErrorMessage = null; // Clear previous errors
    });
    try {
      final response =
          await http.get(Uri.parse('https://ti054b05.agussbn.my.id/api/obat'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _obatList = data.cast<Map<String, dynamic>>();
        });
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ??
            'Gagal memuat data obat. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiErrorMessage = e.toString().contains("Failed host lookup")
              ? "Tidak ada koneksi internet atau server tidak dapat dijangkau."
              : e.toString();
          _obatList = []; // Clear list on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_apiErrorMessage')),
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

  // LOGIKA DAN TOMBOL DELETE DIHAPUS SEPENUHNYA SESUAI PERMINTAAN KAREN

  // --- Filter and Search Logic ---
  List<Map<String, dynamic>> get _filteredAndSortedData {
    List<Map<String, dynamic>> data =
        List.from(_obatList); // Gunakan data dari API

    if (_statusFilter == "Stok Habis") {
      data = data.where((obat) => (obat['stok'] ?? 0) == 0).toList();
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

  // --- Form Handling ---
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

  // --- Widget for displaying details in a modal ---
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                // Corrected from box boxShadow:
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                  ),
                  const Divider(height: 25, thickness: 1.5, color: accentColor),
                  const SizedBox(height: 15),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/obat.jpg',
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                              'ERROR: Gagal memuat aset gambar: assets/images/obat.jpg');
                          return Icon(Icons.broken_image,
                              size: 120, color: Colors.grey[300]);
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
                    valueColor:
                        (obat['stok'] ?? 0) == 0 ? Colors.red : primaryColor,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
          Icon(icon, size: 22, color: primaryColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 17,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
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
              Icon(icon, size: 22, color: primaryColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style:
                TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
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

    if (data.isEmpty && !_isLoadingData) {
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18.0,
        mainAxisSpacing: 18.0,
        childAspectRatio: 0.78, // Adjusted for better fit, try 0.78 or 0.75
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final obat = data[index];
        final isStokHabis = (obat['stok'] ?? 0) == 0;

        return Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: InkWell(
            onTap: () {
              _showObatDetailModal(obat);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/obat.jpg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                              'ERROR: Gagal memuat aset gambar: assets/images/obat.jpg');
                          return Icon(Icons.broken_image,
                              size: 60, color: Colors.grey[400]);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          obat['nama_obat'] ?? 'Nama Obat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatCurrency.format(obat['harga_satuan'] ?? 0),
                          style: TextStyle(
                            fontSize: 19,
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
                                    size: 18, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                const Text(
                                  "Banjarmasin",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                            if (isStokHabis)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: redColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Stok Habis',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage('assets/images/banner_bg.png'),
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
            'Pantau Obatmu!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Simpan obat di tempat sejuk dan kering untuk menjaga kualitasnya.',
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
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              elevation: 3,
            ),
            child: const Text('Pelajari Lebih Lanjut',
                style: TextStyle(fontSize: 16)),
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
            padding: const EdgeInsets.only(right: 10.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 3,
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
        : _filteredAndSortedData.take(4).toList();

    return Scaffold(
      backgroundColor: accentColor,
      appBar: CustomHeader(
        searchController: _headerSearchController,
        onSearchChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        primaryColor: primaryColor,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Obat',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kelola semua data obat yang tersedia di inventaris Anda dengan mudah.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildTrackYourMedsBanner(),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Obat Tersedia',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      ElevatedButton.icon(
                        onPressed: _handleShowAddForm,
                        icon: const Icon(Icons.add_circle_outline,
                            size: 22, color: Colors.white),
                        label: const Text('Tambah Obat',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
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
                  _buildFilterStatusButtons(),
                  const SizedBox(height: 24),
                  _isLoadingData
                      ? Center(
                          child: CircularProgressIndicator(
                          color: primaryColor,
                        ))
                      : _buildMedicineGridCards(displayedData),
                  if (_filteredAndSortedData.length > 4)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showAll = !_showAll;
                            });
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
                                horizontal: 28, vertical: 14),
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
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          if (_showScrollToTopButton)
            Positioned(
              bottom: 80.0,
              right: 20.0,
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
        currentIndex: _selectedIndex,
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
            case 4:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (Route<dynamic> route) => false,
              );
              break;
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600]!,
        primaryColor: primaryColor,
      ),
    );
  }
}
