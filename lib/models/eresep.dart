// mobile_app/lib/models/eresep.dart
class Eresep {
  final String idEresP; // id_eresep
  final String idPendaftaran; // id_pendaftaran
  final String status; // status

  Eresep({
    required this.idEresP,
    required this.idPendaftaran,
    required this.status,
  });

  factory Eresep.fromJson(Map<String, dynamic> json) {
    return Eresep(
      idEresP: json['id_eresep'] as String,
      idPendaftaran: json['id_pendaftaran'] as String,
      status: json['status'] as String,
    );
  }
}
