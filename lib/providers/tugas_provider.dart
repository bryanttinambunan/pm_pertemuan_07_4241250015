import 'package:flutter/foundation.dart';

import '../models/tugas_kuliah.dart';

/// State bersama (App State) pengelola daftar tugas kuliah menggunakan ChangeNotifier.
///
/// Memenuhi Spesifikasi Wajib 1 & 4 Tugas Rutin 7:
/// - Menyediakan operasi [tambah], [tandaiSelesai], dan [hapus].
/// - Menyediakan properti statistik: [jumlahTotal], [jumlahSelesai], [jumlahTugasAktif],
///   dan [persentaseSelesai] yang otomatis memicu pembaruan pada listener/widget.
class TugasProvider extends ChangeNotifier {
  final List<TugasKuliah> _daftarTugas = [];

  /// Inisialisasi TugasProvider.
  ///
  /// Jika [initialTugas] diberikan (misalnya saat pengujian unit test),
  /// daftar tugas akan diisi dengan data tersebut. Jika tidak, data awal
  /// simulasi tugas kuliah mahasiswa akan dimuat secara default.
  TugasProvider({List<TugasKuliah>? initialTugas}) {
    if (initialTugas != null) {
      _daftarTugas.addAll(initialTugas);
    } else {
      _muatDataAwal();
    }
  }

  /// Memuat data simulasi awal untuk demonstrasi aplikasi.
  void _muatDataAwal() {
    final now = DateTime.now();
    _daftarTugas.addAll([
      TugasKuliah(
        id: 'tugas-1',
        judul: 'Implementasi State Management Tugas Rutin 7',
        mataKuliah: 'Pemrograman Mobile',
        tenggat: now.add(const Duration(days: 2, hours: 4)),
        selesai: false,
      ),
      TugasKuliah(
        id: 'tugas-2',
        judul: 'Critical Book Review (CBR) Bab Flutter Lifecycle',
        mataKuliah: 'Pemrograman Mobile',
        tenggat: now.add(const Duration(days: 4)),
        selesai: true,
      ),
      TugasKuliah(
        id: 'tugas-3',
        judul: 'Makalah Representasi Pengetahuan dan Inferensi',
        mataKuliah: 'Kecerdasan Buatan',
        tenggat: now.add(const Duration(days: 6)),
        selesai: false,
      ),
      TugasKuliah(
        id: 'tugas-4',
        judul: 'Perancangan Diagram Kelas & Use Case Sistem',
        mataKuliah: 'Rekayasa Perangkat Lunak',
        tenggat: now.add(const Duration(days: 8)),
        selesai: false,
      ),
      TugasKuliah(
        id: 'tugas-5',
        judul: 'Normalisasi Database Relasional 1NF-3NF',
        mataKuliah: 'Basis Data Terdistribusi',
        tenggat: now.subtract(const Duration(days: 1)),
        selesai: true,
      ),
    ]);
  }

  /// Salinan daftar tugas yang tidak dapat dimutasi langsung dari luar (unmodifiable).
  List<TugasKuliah> get daftarTugas => List.unmodifiable(_daftarTugas);

  /// Jumlah total keseluruhan tugas yang tercatat.
  int get jumlahTotal => _daftarTugas.length;

  /// Jumlah tugas yang telah berstatus selesai.
  int get jumlahSelesai => _daftarTugas.where((t) => t.selesai).length;

  /// Jumlah tugas aktif yang belum selesai (pending).
  /// Properti ini dibaca oleh badge navigasi menggunakan `context.select`.
  int get jumlahTugasAktif => _daftarTugas.where((t) => !t.selesai).length;

  /// Persentase penyelesaian tugas (0.0 sampai 100.0).
  double get persentaseSelesai {
    if (_daftarTugas.isEmpty) return 0.0;
    return (jumlahSelesai / _daftarTugas.length) * 100.0;
  }

  /// Menambahkan tugas baru ke dalam daftar.
  void tambah(TugasKuliah tugas) {
    _daftarTugas.add(tugas);
    notifyListeners();
  }

  /// Menandai tugas sebagai selesai atau melakukan toggle status penyelesaian.
  ///
  /// Jika [status] disertakan, nilai status tugas diubah menjadi [status].
  /// Jika [status] null, nilai status penyelesaian di-toggle (negasi dari status saat ini).
  void tandaiSelesai(String id, {bool? status}) {
    final index = _daftarTugas.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tugasLama = _daftarTugas[index];
      final statusBaru = status ?? !tugasLama.selesai;
      _daftarTugas[index] = tugasLama.copyWith(selesai: statusBaru);
      notifyListeners();
    }
  }

  /// Menghapus tugas dari daftar berdasarkan [id].
  void hapus(String id) {
    final index = _daftarTugas.indexWhere((t) => t.id == id);
    if (index != -1) {
      _daftarTugas.removeAt(index);
      notifyListeners();
    }
  }

  /// Mencari tugas tertentu berdasarkan [id].
  TugasKuliah? cariBerdasarkanId(String id) {
    try {
      return _daftarTugas.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Menghapus semua tugas yang sudah berstatus selesai.
  void bersihkanTugasSelesai() {
    _daftarTugas.removeWhere((t) => t.selesai);
    notifyListeners();
  }
}
