import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tugas_provider.dart';

/// Halaman statistik yang menampilkan ringkasan data tugas kuliah.
///
/// Memenuhi Spesifikasi Wajib 4 Tugas Rutin 7:
/// - Menampilkan jumlah total tugas, jumlah tugas selesai, tugas aktif,
///   dan persentase penyelesaian.
/// - Otomatis terperbarui secara reaktif setiap kali state bersama ([TugasProvider]) berubah.
class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mendengarkan perubahan pada App State (TugasProvider) menggunakan context.watch
    final provider = context.watch<TugasProvider>();
    final total = provider.jumlahTotal;
    final selesai = provider.jumlahSelesai;
    final aktif = provider.jumlahTugasAktif;
    final persentase = provider.persentaseSelesai;
    final daftarTugas = provider.daftarTugas;

    // Hitung ringkasan per mata kuliah
    final Map<String, int> totalPerMk = {};
    final Map<String, int> selesaiPerMk = {};
    for (final t in daftarTugas) {
      totalPerMk.update(t.mataKuliah, (val) => val + 1, ifAbsent: () => 1);
      if (t.selesai) {
        selesaiPerMk.update(t.mataKuliah, (val) => val + 1, ifAbsent: () => 1);
      }
    }

    // Hitung tugas yang terlewat
    final terlewat = daftarTugas.where((t) => t.isTerlewat).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistik Tugas Kuliah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (selesai > 0)
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              tooltip: 'Bersihkan Tugas Selesai',
              onPressed: () {
                _konfirmasiBersihkan(context);
              },
            ),
        ],
      ),
      body: total == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.query_stats_rounded,
                    size: 72,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data tugas untuk dianalisis.',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Persentase Penyelesaian Utama
                  Card(
                    elevation: 0,
                    color: colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progres Penyelesaian',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${persentase.toStringAsFixed(1)}%',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0.0 : persentase / 100.0,
                              minHeight: 12,
                              backgroundColor: colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$selesai dari $total tugas telah berhasil diselesaikan.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid Kartu Ringkasan (Total, Selesai, Aktif, Terlewat)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context: context,
                          judul: 'Total Tugas',
                          nilai: '$total',
                          icon: Icons.list_alt_rounded,
                          warna: colorScheme.primary,
                          warnaContainer: colorScheme.primaryContainer.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          context: context,
                          judul: 'Selesai',
                          nilai: '$selesai',
                          icon: Icons.check_circle_outline_rounded,
                          warna: Colors.green,
                          warnaContainer: Colors.green.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context: context,
                          judul: 'Tugas Aktif',
                          nilai: '$aktif',
                          icon: Icons.pending_actions_rounded,
                          warna: Colors.orange,
                          warnaContainer: Colors.orange.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          context: context,
                          judul: 'Terlewat',
                          nilai: '$terlewat',
                          icon: Icons.warning_amber_rounded,
                          warna: colorScheme.error,
                          warnaContainer: colorScheme.errorContainer.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Rincian Berdasarkan Mata Kuliah
                  Text(
                    'Distribusi per Mata Kuliah',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...totalPerMk.entries.map((entry) {
                    final mk = entry.key;
                    final totalMk = entry.value;
                    final selesaiMk = selesaiPerMk[mk] ?? 0;
                    final persenMk = (selesaiMk / totalMk) * 100.0;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    mk,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '$selesaiMk / $totalMk tugas',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: totalMk == 0 ? 0.0 : selesaiMk / totalMk,
                                minHeight: 6,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  persenMk == 100.0 ? Colors.green : colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String judul,
    required String nilai,
    required IconData icon,
    required Color warna,
    required Color warnaContainer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warnaContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: warna, size: 28),
          const SizedBox(height: 10),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: warna,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            judul,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiBersihkan(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Bersihkan Tugas Selesai?'),
        content: const Text(
          'Semua tugas yang telah ditandai selesai akan dihapus permanen dari daftar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<TugasProvider>().bersihkanTugasSelesai();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tugas yang selesai berhasil dibersihkan.'),
                ),
              );
            },
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }
}
