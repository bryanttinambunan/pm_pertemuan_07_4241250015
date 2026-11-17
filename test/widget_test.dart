import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:planner_tugas_kuliah/app.dart';
import 'package:planner_tugas_kuliah/providers/tugas_provider.dart';

void main() {
  testWidgets('Smoke test: Aplikasi menampilkan antarmuka Planner Tugas Kuliah', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TugasProvider(initialTugas: []),
        child: const PlannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi judul pada AppBar
    expect(find.text('Daftar Tugas Kuliah'), findsOneWidget);

    // Verifikasi keberadaan FilterChip
    expect(find.text('Semua (0)'), findsOneWidget);
    expect(find.text('Aktif (0)'), findsOneWidget);
    expect(find.text('Selesai (0)'), findsOneWidget);

    // Verifikasi empty state
    expect(find.byIcon(Icons.assignment_outlined), findsWidgets);
  });
}
