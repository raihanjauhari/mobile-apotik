// mobile_app/lib/models/memunculkan.dart
class Memunculkan {
  final String kodeObat;
  final String idEresP; // id_eresep
  final String idDetail; // id_detail
  final int kuantitas;
  final String aturanPakai;

  Memunculkan({
    required this.kodeObat,
    required this.idDetail,
    required this.idEresP,
    required this.kuantitas,
    required this.aturanPakai,
  });

  factory Memunculkan.fromJson(Map<String, dynamic> json) {
    return Memunculkan(
      kodeObat: json['kode_obat'] as String,
      idEresP: json['id_eresep'] as String,
      idDetail: json['id_detail'] as String,
      kuantitas: json['kuantitas'] as int,
      aturanPakai: json['aturan_pakai'] as String,
    );
  }
}
