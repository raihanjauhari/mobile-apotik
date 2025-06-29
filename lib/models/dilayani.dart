// mobile_app/lib/models/dilayani.dart
class Dilayani {
  final String idPendaftaran;
  final String idDokter;

  Dilayani({
    required this.idPendaftaran,
    required this.idDokter,
  });

  factory Dilayani.fromJson(Map<String, dynamic> json) {
    return Dilayani(
      idPendaftaran: json['id_pendaftaran'] as String,
      idDokter: json['id_dokter'] as String,
    );
  }
}
