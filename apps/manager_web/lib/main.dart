import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/workers/presentation/workers_screen.dart';
import 'features/attendance_records/presentation/attendance_records_screen.dart';
import 'features/payroll/presentation/payroll_screen.dart';
import 'core/widgets/side_nav_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');
  runApp(const ProviderScope(child: ManagerApp()));
}

class ManagerApp extends ConsumerWidget {
  const ManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '출퇴근GO Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: authState.status == AuthStatus.authenticated
          ? const ManagerShell()
          : const ManagerLoginScreen(),
    );
  }
}

class ManagerShell extends ConsumerStatefulWidget {
  const ManagerShell({super.key});

  @override
  ConsumerState<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends ConsumerState<ManagerShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Row(
        children: [
          SideNavDrawer(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: Colors.black12),
          Expanded(
            child: Column(
              children: [
                // Top header
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      const Text('출퇴근GO Admin', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('(주) 티케이홀딩스', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      Text(authState.worker?.name ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 18)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 20),
                        tooltip: '로그아웃',
                        onPressed: () => ref.read(authProvider.notifier).signOut(),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: _buildPage(),
                  ),
                ),
                // Footer
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Center(
                    child: Text(
                      '© since 2026- Taekyungholdings All Rights Reserved.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    return switch (_selectedIndex) {
      0 => const DashboardScreen(),
      1 => const WorkersScreen(),
      2 => const AttendanceRecordsScreen(),
      3 => const PayrollScreen(),
      _ => const DashboardScreen(),
    };
  }
}
