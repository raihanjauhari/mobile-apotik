// mobile_app/lib/models/obat.dart
class Obat {
  final int id;
  final String kodeObat;
  final String? idUser; // Bisa null
  final String namaObat;
  final double hargaSatuan;
  final int stok;
  final String deskripsi;

  Obat({
    required this.id,
    required this.kodeObat,
    this.idUser, // Nullable
    required this.namaObat,
    required this.hargaSatuan,
    required this.stok,
    required this.deskripsi,
  });

  factory Obat.fromJson(Map<String, dynamic> json) {
    return Obat(
      id: json['id'] as int,
      kodeObat: json['kode_obat'] as String,
      idUser: json['id_user'] as String?, // Handle nullable string
      namaObat: json['nama_obat'] as String,
      hargaSatuan: (json['harga_satuan'] as num).toDouble(),
      stok: json['stok'] as int,
      deskripsi: json['deskripsi'] as String,
    );
  }
}
