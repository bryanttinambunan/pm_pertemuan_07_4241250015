/// Model data untuk entitas Tugas Kuliah.
///
/// Memenuhi Spesifikasi Wajib 1 Tugas Rutin 7:
/// Atribut: [id], [judul], [mataKuliah], [tenggat] (DateTime), dan [selesai] (bool).
class TugasKuliah {
  final String id;
  final String judul;
  final String mataKuliah;
  final DateTime tenggat;
  final bool selesai;

  const TugasKuliah({
    required this.id,
    required this.judul,
    required this.mataKuliah,
    required this.tenggat,
    this.selesai = false,
  });

  /// Membuat salinan objek dengan modifikasi nilai tertentu (immutable pattern).
  TugasKuliah copyWith({
    String? id,
    String? judul,
    String? mataKuliah,
    DateTime? tenggat,
    bool? selesai,
  }) {
    return TugasKuliah(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      tenggat: tenggat ?? this.tenggat,
      selesai: selesai ?? this.selesai,
    );
  }

  /// Mengetahui apakah tenggat tugas sudah terlewat dan belum selesai dikerjakan.
  bool get isTerlewat {
    if (selesai) return false;
    return tenggat.isBefore(DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TugasKuliah &&
        other.id == id &&
        other.judul == judul &&
        other.mataKuliah == mataKuliah &&
        other.tenggat == tenggat &&
        other.selesai == selesai;
  }

  @override
  int get hashCode => Object.hash(id, judul, mataKuliah, tenggat, selesai);

  @override
  String toString() {
    return 'TugasKuliah(id: $id, judul: $judul, mataKuliah: $mataKuliah, tenggat: $tenggat, selesai: $selesai)';
  }
}
