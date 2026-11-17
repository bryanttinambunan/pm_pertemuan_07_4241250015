import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/daftar_tugas_screen.dart';
import '../screens/statistik_screen.dart';
import '../screens/tambah_tugas_screen.dart';
import '../widgets/navigation_scaffold.dart';

/// Konfigurasi routing deklaratif menggunakan go_router.
///
/// Memenuhi Spesifikasi Wajib 5 Tugas Rutin 7:
/// - Menggunakan [StatefulShellRoute.indexedStack] untuk mempertahankan state halaman antar-tab.
/// - Memiliki rute daftar tugas (`/`), statistik (`/statistik`), dan form tambah tugas (`/tambah`).
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // StatefulShellRoute untuk navigasi ber-tab (Daftar Tugas & Statistik)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Cabang 0: Halaman Daftar Tugas (/)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DaftarTugasScreen(),
              ),
            ],
          ),

          // Cabang 1: Halaman Statistik (/statistik)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistik',
                builder: (context, state) => const StatistikScreen(),
              ),
            ],
          ),
        ],
      ),

      // Rute Halaman Form Tambah Tugas (/tambah)
      // Diletakkan di atas rootNavigatorKey agar menutupi shell navigation bar saat dibuka
      GoRoute(
        path: '/tambah',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TambahTugasScreen(),
      ),
    ],
  );
}
