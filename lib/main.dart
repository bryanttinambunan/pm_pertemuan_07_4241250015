import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/tugas_provider.dart';

/// Titik masuk utama aplikasi Planner Tugas Kuliah (Tugas Rutin 7).
///
/// Menyediakan [TugasProvider] di puncak pohon widget menggunakan [ChangeNotifierProvider],
/// sehingga seluruh subtree (halaman daftar, form tambah, dan statistik) dapat
/// mengakses state bersama melalui [BuildContext].
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TugasProvider(), // Satu objek state bersama untuk seluruh aplikasi
      child: const PlannerApp(),
    ),
  );
}
