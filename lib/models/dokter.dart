// mobile_app/lib/models/dokter.dart
class Dokter {
  final String idDokter;
  final String namaDokter;
  final String poli;
  final String fotoDokter; // Asumsi path/URL gambar

  Dokter({
    required this.idDokter,
    required this.namaDokter,
    required this.poli,
    required this.fotoDokter,
  });

  factory Dokter.fromJson(Map<String, dynamic> json) {
    return Dokter(
      idDokter: json['id_dokter'] as String,
      namaDokter: json['nama_dokter'] as String,
      poli: json['poli'] as String,
      fotoDokter: json['foto_dokter'] as String,
    );
  }
}
