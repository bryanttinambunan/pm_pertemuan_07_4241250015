import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tugas_kuliah.dart';
import '../providers/tugas_provider.dart';

/// Halaman form untuk menambahkan tugas kuliah baru.
///
/// Memenuhi Spesifikasi Wajib 3 Tugas Rutin 7:
/// - Menggunakan [TextEditingController] yang diinisialisasi pada [initState]
///   dan wajib dibersihkan pada [dispose].
/// - Tombol simpan memvalidasi input, menambahkan tugas baru ke state bersama
///   ([TugasProvider]) menggunakan `context.read`, lalu kembali ke halaman sebelumnya ([context.pop]).
class TambahTugasScreen extends StatefulWidget {
  const TambahTugasScreen({super.key});

  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controller dikelola sesuai siklus hidup StatefulWidget
  late final TextEditingController _judulController;
  late final TextEditingController _mataKuliahController;

  // State lokal untuk tanggal dan jam tenggat pengumpulan
  late DateTime _tanggalTenggat;
  late TimeOfDay _waktuTenggat;

  // Daftar saran mata kuliah untuk kemudahan input mahasiswa
  final List<String> _saranMataKuliah = [
    'Pemrograman Mobile',
    'Kecerdasan Buatan',
    'Rekayasa Perangkat Lunak',
    'Basis Data Terdistribusi',
    'Jaringan Komputer',
    'Sistem Operasi',
  ];

  @override
  void initState() {
    super.initState();
    // 1. Inisialisasi controller sekali saat objek State dibuat
    _judulController = TextEditingController();
    _mataKuliahController = TextEditingController();

    // Default tenggat: besok pukul 23:59 WIB
    final now = DateTime.now();
    _tanggalTenggat = DateTime(now.year, now.month, now.day + 1);
    _waktuTenggat = const TimeOfDay(hour: 23, minute: 59);
  }

  @override
  void dispose() {
    // 2. Wajib membersihkan controller di dispose() untuk mencegah memory leak
    _judulController.dispose();
    _mataKuliahController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalTenggat,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Tenggat',
      confirmText: 'Pilih',
      cancelText: 'Batal',
    );
    if (picked != null && picked != _tanggalTenggat) {
      setState(() {
        _tanggalTenggat = picked;
      });
    }
  }

  Future<void> _pilihWaktu(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _waktuTenggat,
      helpText: 'Pilih Jam Tenggat',
      confirmText: 'Pilih',
      cancelText: 'Batal',
    );
    if (picked != null && picked != _waktuTenggat) {
      setState(() {
        _waktuTenggat = picked;
      });
    }
  }

  void _simpanTugas() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Gabungkan tanggal dan waktu menjadi DateTime lengkap
    final tenggatLengkap = DateTime(
      _tanggalTenggat.year,
      _tanggalTenggat.month,
      _tanggalTenggat.day,
      _waktuTenggat.hour,
      _waktuTenggat.minute,
    );

    final tugasBaru = TugasKuliah(
      id: 'tugas-${DateTime.now().millisecondsSinceEpoch}',
      judul: _judulController.text.trim(),
      mataKuliah: _mataKuliahController.text.trim(),
      tenggat: tenggatLengkap,
      selesai: false,
    );

    // Mengakses state bersama tanpa mendengarkan perubahan (context.read)
    context.read<TugasProvider>().tambah(tugasBaru);

    // Tampilkan notifikasi keberhasilan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tugas "${tugasBaru.judul}" berhasil disimpan!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Kembali ke halaman sebelumnya
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final formatTanggal = DateFormat('EEEE, d MMMM yyyy');
    final stringTanggal = formatTanggal.format(_tanggalTenggat);
    final stringWaktu =
        '${_waktuTenggat.hour.toString().padLeft(2, '0')}:${_waktuTenggat.minute.toString().padLeft(2, '0')} WIB';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Tugas Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Input Judul Tugas
              Text(
                'Judul Tugas',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _judulController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Contoh: Laporan Praktikum Pertemuan 7',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas tidak boleh kosong.';
                  }
                  if (value.trim().length < 3) {
                    return 'Judul tugas minimal 3 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Kolom Input Mata Kuliah
              Text(
                'Mata Kuliah',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mataKuliahController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Contoh: Pemrograman Mobile',
                  prefixIcon: const Icon(Icons.menu_book_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama mata kuliah tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Saran Cepat Mata Kuliah (Chips)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _saranMataKuliah.map((mk) {
                  return ActionChip(
                    label: Text(mk, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _mataKuliahController.text = mk;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Bagian Pemilihan Tenggat Waktu
              Text(
                'Tenggat Pengumpulan (Deadline)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_month_rounded),
                      title: const Text('Tanggal'),
                      subtitle: Text(stringTanggal),
                      trailing: const Icon(Icons.edit_calendar_rounded),
                      onTap: () => _pilihTanggal(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.schedule_rounded),
                      title: const Text('Jam / Waktu'),
                      subtitle: Text(stringWaktu),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () => _pilihWaktu(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan Tugas
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _simpanTugas,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Simpan Tugas ke Daftar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
