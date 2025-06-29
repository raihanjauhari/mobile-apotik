// mobile_app/lib/models/pasien.dart
class Pasien {
  final String idPendaftaran;
  final String namaPasien;
  final int umur;
  final String diagnosa;
  final double beratBadan;
  final String fotoPasien; // Asumsi path/URL gambar

  Pasien({
    required this.idPendaftaran,
    required this.namaPasien,
    required this.umur,
    required this.diagnosa,
    required this.beratBadan,
    required this.fotoPasien,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      idPendaftaran: json['id_pendaftaran'] as String,
      namaPasien: json['nama_pasien'] as String,
      umur: json['umur'] as int,
      diagnosa: json['diagnosa'] as String,
      beratBadan: (json['berat_badan'] as num).toDouble(),
      fotoPasien: json['foto_pasien'] as String,
    );
  }
}
