import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tugas_kuliah.dart';
import '../providers/tugas_provider.dart';

/// Widget kartu item tugas yang menampilkan informasi tugas, status penyelesaian,
/// dan aksi interaktif (toggle selesai & hapus).
class ItemTugasCard extends StatelessWidget {
  final TugasKuliah tugas;

  const ItemTugasCard({
    super.key,
    required this.tugas,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatter = DateFormat('EEE, d MMM yyyy • HH:mm', 'id_ID');

    // Format tanggal fallback jika locale id_ID belum terdaftar
    String formattedDate;
    try {
      formattedDate = formatter.format(tugas.tenggat);
    } catch (_) {
      formattedDate = DateFormat('EEE, d MMM yyyy • HH:mm').format(tugas.tenggat);
    }

    final isOverdue = tugas.isTerlewat;

    return Card(
      elevation: tugas.selesai ? 0 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: tugas.selesai
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isOverdue
              ? colorScheme.error.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Toggle status selesai menggunakan context.read (di dalam callback)
          context.read<TugasProvider>().tandaiSelesai(tugas.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox / Status Tombol Selesai
              Checkbox(
                value: tugas.selesai,
                activeColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (bool? val) {
                  context.read<TugasProvider>().tandaiSelesai(
                        tugas.id,
                        status: val,
                      );
                },
              ),
              const SizedBox(width: 8),

              // Detail Tugas (Judul, Mata Kuliah, Tenggat)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Mata Kuliah & Indikator Terlewat
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tugas.mataKuliah,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 12,
                                  color: colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Terlewat',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Judul Tugas
                    Text(
                      tugas.judul,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: tugas.selesai
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: tugas.selesai
                            ? colorScheme.outline
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tenggat Waktu
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: isOverdue ? colorScheme.error : colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Hapus Tugas
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: colorScheme.outline,
                tooltip: 'Hapus Tugas',
                onPressed: () {
                  _konfirmasiHapus(context, tugas);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context, TugasKuliah tugas) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('Apakah Anda yakin ingin menghapus "${tugas.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              // Membaca provider tanpa mendengarkan perubahan (context.read)
              context.read<TugasProvider>().hapus(tugas.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tugas "${tugas.judul}" berhasil dihapus.'),
                  action: SnackBarAction(
                    label: 'Urungkan',
                    onPressed: () {
                      context.read<TugasProvider>().tambah(tugas);
                    },
                  ),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
