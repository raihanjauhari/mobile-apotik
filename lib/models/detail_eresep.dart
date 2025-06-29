// mobile_app/lib/models/detail_eresep.dart
class DetailEresep {
  final String idDetail;
  final String idEresP; // id_eresep
  final String
      tanggalEresP; // tanggal_eresep (String, karena di API juga string format "17 Mei 2025")
  final String catatan;

  DetailEresep({
    required this.idDetail,
    required this.idEresP,
    required this.tanggalEresP,
    required this.catatan,
  });

  factory DetailEresep.fromJson(Map<String, dynamic> json) {
    return DetailEresep(
      idDetail: json['id_detail'] as String,
      idEresP: json['id_eresep'] as String,
      tanggalEresP: json['tanggal_eresep'] as String,
      catatan: json['catatan'] as String,
    );
  }
}
