import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/tugas_provider.dart';

/// Kerangka navigasi adaptif menggunakan [StatefulNavigationShell].
///
/// Memenuhi Spesifikasi Wajib 4 & 5 Tugas Rutin 7:
/// - Menggunakan [StatefulShellRoute] dari `go_router` untuk persistensi state antar-halaman.
/// - Menampilkan [Badge.count] pada ikon navigasi yang dihubungkan ke [TugasProvider]
///   menggunakan [context.select] agar widget navigasi hanya dibangun ulang ketika
///   nilai [jumlahTugasAktif] berubah.
/// - Responsif: Menggunakan [NavigationRail] pada layar lebar (>= 640dp) dan
///   [NavigationBar] pada layar ponsel (< 640dp).
class NavigationScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    // Membaca hanya jumlah tugas aktif dengan context.select
    // Rebuild HANYA dipicu saat nilai properti jumlahTugasAktif berubah!
    final jumlahAktif = context.select<TugasProvider, int>(
      (provider) => provider.jumlahTugasAktif,
    );

    final isWideScreen = MediaQuery.sizeOf(context).width >= 640;

    final badgeDaftar = Badge.count(
      count: jumlahAktif,
      isLabelVisible: jumlahAktif > 0,
      child: const Icon(Icons.assignment_outlined),
    );

    final badgeDaftarSelected = Badge.count(
      count: jumlahAktif,
      isLabelVisible: jumlahAktif > 0,
      child: const Icon(Icons.assignment),
    );

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.school, size: 32),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: badgeDaftar,
                  selectedIcon: badgeDaftarSelected,
                  label: const Text('Daftar Tugas'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: Text('Statistik'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: badgeDaftar,
            selectedIcon: badgeDaftarSelected,
            label: 'Daftar Tugas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}
