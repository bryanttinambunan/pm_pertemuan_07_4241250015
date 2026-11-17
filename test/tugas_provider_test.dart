import 'package:flutter_test/flutter_test.dart';
import 'package:planner_tugas_kuliah/models/tugas_kuliah.dart';
import 'package:planner_tugas_kuliah/providers/tugas_provider.dart';

void main() {
  group('TugasProvider - Unit Test Logika State', () {
    late TugasProvider provider;
    final now = DateTime.now();

    final tugasUji1 = TugasKuliah(
      id: 'test-1',
      judul: 'Tugas Rutin 7 Pemrograman Mobile',
      mataKuliah: 'Pemrograman Mobile',
      tenggat: now.add(const Duration(days: 2)),
      selesai: false,
    );

    final tugasUji2 = TugasKuliah(
      id: 'test-2',
      judul: 'Makalah Representasi Pengetahuan',
      mataKuliah: 'Kecerdasan Buatan',
      tenggat: now.add(const Duration(days: 5)),
      selesai: false,
    );

    setUp(() {
      // Menginisialisasi provider dengan daftar kosong untuk pengujian terisolasi
      provider = TugasProvider(initialTugas: []);
    });

    // Test 1: Operasi Tambah Tugas
    test('1. tambah() memasukkan tugas baru dan memicu notifikasi listener', () {
      var listenerDipanggil = 0;
      provider.addListener(() => listenerDipanggil++);

      expect(provider.jumlahTotal, 0);
      expect(provider.jumlahTugasAktif, 0);

      provider.tambah(tugasUji1);

      expect(provider.jumlahTotal, 1);
      expect(provider.jumlahTugasAktif, 1);
      expect(provider.jumlahSelesai, 0);
      expect(provider.daftarTugas.first, tugasUji1);
      expect(listenerDipanggil, 1);
    });

    // Test 2: Operasi Tandai Selesai
    test('2. tandaiSelesai() memperbarui status selesai dan persentase penyelesaian', () {
      var listenerDipanggil = 0;
      provider.tambah(tugasUji1);
      provider.tambah(tugasUji2);

      provider.addListener(() => listenerDipanggil++);

      expect(provider.jumlahTotal, 2);
      expect(provider.jumlahSelesai, 0);
      expect(provider.jumlahTugasAktif, 2);
      expect(provider.persentaseSelesai, 0.0);

      // Tandai tugas 1 selesai
      provider.tandaiSelesai('test-1', status: true);

      expect(provider.jumlahSelesai, 1);
      expect(provider.jumlahTugasAktif, 1);
      expect(provider.persentaseSelesai, 50.0);
      expect(provider.cariBerdasarkanId('test-1')!.selesai, isTrue);
      expect(listenerDipanggil, 1);
    });

    // Test 3: Operasi Hapus Tugas
    test('3. hapus() menghapus tugas dari daftar berdasarkan ID dan memicu notifikasi', () {
      var listenerDipanggil = 0;
      provider.tambah(tugasUji1);
      provider.tambah(tugasUji2);

      provider.addListener(() => listenerDipanggil++);

      expect(provider.jumlahTotal, 2);

      provider.hapus('test-1');

      expect(provider.jumlahTotal, 1);
      expect(provider.cariBerdasarkanId('test-1'), isNull);
      expect(provider.daftarTugas.contains(tugasUji1), isFalse);
      expect(provider.daftarTugas.first, tugasUji2);
      expect(listenerDipanggil, 1);
    });

    // Test 4: Kalkulasi Statistik Persentase Selesai
    test('4. persentaseSelesai menghitung proporsi dengan akurat pada berbagai kondisi', () {
      // Kondisi kosong -> 0.0%
      expect(provider.persentaseSelesai, 0.0);

      // Kondisi 1 tugas belum selesai -> 0.0%
      provider.tambah(tugasUji1);
      expect(provider.persentaseSelesai, 0.0);

      // Kondisi 1 tugas selesai dari 2 tugas -> 50.0%
      provider.tambah(tugasUji2.copyWith(selesai: true));
      expect(provider.persentaseSelesai, 50.0);

      // Kondisi 2 tugas selesai dari 2 tugas -> 100.0%
      provider.tandaiSelesai('test-1', status: true);
      expect(provider.persentaseSelesai, 100.0);
    });

    // Test 5: Toggle Status Penyelesaian Tugas
    test('5. tandaiSelesai tanpa parameter status melakukan toggle boolean', () {
      provider.tambah(tugasUji1); // selesai = false
      expect(provider.cariBerdasarkanId('test-1')!.selesai, isFalse);

      provider.tandaiSelesai('test-1'); // toggle -> true
      expect(provider.cariBerdasarkanId('test-1')!.selesai, isTrue);

      provider.tandaiSelesai('test-1'); // toggle -> false
      expect(provider.cariBerdasarkanId('test-1')!.selesai, isFalse);
    });

    // Test 6: Pembersihan Tugas Selesai
    test('6. bersihkanTugasSelesai() hanya menghapus tugas berstatus selesai', () {
      provider.tambah(tugasUji1.copyWith(selesai: true));
      provider.tambah(tugasUji2.copyWith(selesai: false));

      expect(provider.jumlahTotal, 2);
      provider.bersihkanTugasSelesai();

      expect(provider.jumlahTotal, 1);
      expect(provider.daftarTugas.first.id, 'test-2');
      expect(provider.jumlahSelesai, 0);
    });
  });
}
