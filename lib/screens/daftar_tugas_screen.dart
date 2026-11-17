import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/tugas_kuliah.dart';
import '../providers/tugas_provider.dart';
import '../widgets/item_tugas_card.dart';

/// Opsi pilihan filter daftar tugas.
enum FilterTugas { semua, aktif, selesai }

/// Halaman utama yang menampilkan daftar tugas kuliah dengan filter chip.
///
/// Memenuhi Spesifikasi Wajib 2 Tugas Rutin 7:
/// - Menggunakan [FilterChip] untuk pilihan filter: Semua, Aktif, dan Selesai.
/// - Filter status merupakan ephemeral state (state lokal) yang dikelola
///   secara eksklusif menggunakan [setState].
/// - Daftar tugas diambil dari App State ([TugasProvider]) menggunakan `context.watch`.
class DaftarTugasScreen extends StatefulWidget {
  const DaftarTugasScreen({super.key});

  @override
  State<DaftarTugasScreen> createState() => _DaftarTugasScreenState();
}

class _DaftarTugasScreenState extends State<DaftarTugasScreen> {
  // Ephemeral State: status filter hanya dibutuhkan di dalam widget ini saja.
  FilterTugas _filterDipilih = FilterTugas.semua;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mendengarkan perubahan pada App State (TugasProvider) menggunakan context.watch
    final provider = context.watch<TugasProvider>();
    final semuaTugas = provider.daftarTugas;

    // Filter daftar tugas berdasarkan ephemeral state (_filterDipilih)
    final List<TugasKuliah> daftarDitampilkan;
    switch (_filterDipilih) {
      case FilterTugas.semua:
        daftarDitampilkan = semuaTugas;
        break;
      case FilterTugas.aktif:
        daftarDitampilkan = semuaTugas.where((t) => !t.selesai).toList();
        break;
      case FilterTugas.selesai:
        daftarDitampilkan = semuaTugas.where((t) => t.selesai).toList();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Tugas Kuliah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Tambah Tugas Baru',
            onPressed: () => context.push('/tambah'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Baris FilterChip (Ephemeral State dikelola dengan setState)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  count: provider.jumlahTotal,
                  filter: FilterTugas.semua,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Aktif',
                  count: provider.jumlahTugasAktif,
                  filter: FilterTugas.aktif,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Selesai',
                  count: provider.jumlahSelesai,
                  filter: FilterTugas.selesai,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Daftar Tugas atau Tampilan Kosong
          Expanded(
            child: daftarDitampilkan.isEmpty
                ? _buildEmptyState(context, colorScheme)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: daftarDitampilkan.length,
                    itemBuilder: (context, index) {
                      final tugas = daftarDitampilkan[index];
                      return ItemTugasCard(
                        key: ValueKey(tugas.id),
                        tugas: tugas,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tambah'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
    );
  }

  /// Membuat widget [FilterChip] yang mengubah ephemeral state melalui [setState].
  Widget _buildFilterChip({
    required String label,
    required int count,
    required FilterTugas filter,
  }) {
    final isSelected = _filterDipilih == filter;
    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      avatar: isSelected ? const Icon(Icons.check, size: 16) : null,
      onSelected: (bool selected) {
        // Mengelola ephemeral state lokal dengan setState sesuai spesifikasi
        setState(() {
          _filterDipilih = filter;
        });
      },
    );
  }

  /// Tampilan placeholder ketika tidak ada tugas yang sesuai dengan filter.
  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    String pesan;
    IconData iconData;

    switch (_filterDipilih) {
      case FilterTugas.semua:
        pesan = 'Belum ada tugas kuliah yang dicatat.\nYuk mulai tambahkan tugas baru!';
        iconData = Icons.assignment_outlined;
        break;
      case FilterTugas.aktif:
        pesan = 'Hebat! Tidak ada tugas aktif yang tersisa.\nSemua tugas sudah selesai dikerjakan.';
        iconData = Icons.task_alt_outlined;
        break;
      case FilterTugas.selesai:
        pesan = 'Belum ada tugas yang selesai.\nSelesaikan tugas dan tandai centang di daftar!';
        iconData = Icons.pending_actions_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 72,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
