import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/utils/permissions.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/workers/presentation/workers_screen.dart';
import 'features/attendance_records/presentation/attendance_records_screen.dart';
import 'features/payroll/presentation/payroll_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/providers/settings_provider.dart';
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
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workflow by TKholdings',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: settings.themeMode,
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
    final role = authState.role;

    // 현재 선택된 인덱스가 접근 불가하면 홈으로 리다이렉트
    if (!canAccessMenu(role, _selectedIndex)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedIndex = 0);
      });
    }

    return Scaffold(
      body: Row(
        children: [
          SideNavDrawer(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            role: role,
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
                      const Text('Workflow by TKholdings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // 역할 배지
                      _buildRoleBadge(role),
                      const SizedBox(width: 12),
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
                    child: _buildPage(role),
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

  Widget _buildRoleBadge(AppRole role) {
    final (color, bgColor) = switch (role) {
      AppRole.systemAdmin => (Colors.white, Colors.red[700]!),
      AppRole.owner => (Colors.white, Colors.indigo[700]!),
      AppRole.centerManager => (Colors.white, Colors.teal[700]!),
      AppRole.worker => (Colors.white, Colors.grey[600]!),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        roleDisplayName(role),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPage(AppRole role) {
    // 접근 불가 메뉴에 대한 방어
    if (!canAccessMenu(role, _selectedIndex)) {
      final userSiteId = ref.read(authProvider).worker?.siteId ?? '';
      return DashboardScreen(role: role, userSiteId: userSiteId);
    }

    final userSiteId = ref.read(authProvider).worker?.siteId ?? '';

    return switch (_selectedIndex) {
      0 => DashboardScreen(role: role, userSiteId: userSiteId),
      1 => WorkersScreen(role: role),
      2 => const AttendanceRecordsScreen(),
      3 => PayrollScreen(role: role),
      4 => const SettingsScreen(),
      _ => DashboardScreen(role: role, userSiteId: userSiteId),
    };
  }
}
