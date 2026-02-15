import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_client/supabase_client.dart';
import 'core/utils/permissions.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/workers/presentation/workers_screen.dart';
import 'features/attendance_records/presentation/attendance_records_screen.dart';
import 'features/payroll/presentation/payroll_screen.dart';
import 'features/accounts/presentation/accounts_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/providers/settings_provider.dart';
import 'core/widgets/side_nav_drawer.dart';
import 'features/worker_detail/presentation/worker_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SupabaseService.instance.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E2E),
          onSurface: const Color(0xFFE0E0E8),
        ),
        scaffoldBackgroundColor: const Color(0xFF161624),
        cardColor: const Color(0xFF252538),
        dividerColor: const Color(0xFF3A3A50),
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
  String? _detailWorkerId;
  String? _detailWorkerName;

  void _openWorkerDetail(String id, String name) {
    setState(() {
      _detailWorkerId = id;
      _detailWorkerName = name;
    });
  }

  void _closeWorkerDetail() {
    setState(() {
      _detailWorkerId = null;
      _detailWorkerName = null;
    });
  }

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

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          SideNavDrawer(
            selectedIndex: _detailWorkerId != null ? -1 : _selectedIndex,
            onDestinationSelected: (i) => setState(() {
              _selectedIndex = i;
              _detailWorkerId = null;
              _detailWorkerName = null;
            }),
            role: role,
          ),
          VerticalDivider(width: 1, thickness: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          Expanded(
            child: Column(
              children: [
                // Top header
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
                  ),
                  child: Row(
                    children: [
                      Text('Workflow by TKholdings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      const Spacer(),
                      // 역할 배지
                      _buildRoleBadge(role),
                      const SizedBox(width: 12),
                      Text('(주) 티케이홀딩스', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(width: 16),
                      Text(authState.worker?.name ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      const SizedBox(width: 8),
                      CircleAvatar(radius: 15, backgroundColor: cs.primaryContainer, child: Icon(Icons.person, size: 18, color: cs.onPrimaryContainer)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.logout, size: 20, color: cs.onSurface.withValues(alpha: 0.7)),
                        tooltip: '로그아웃',
                        onPressed: () => ref.read(authProvider.notifier).signOut(),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Container(
                    color: isDark ? const Color(0xFF161624) : Colors.grey[50],
                    child: _buildPage(role),
                  ),
                ),
                // Footer
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
                  ),
                  child: Center(
                    child: Text(
                      '© since 2026- Taekyungholdings All Rights Reserved.',
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4)),
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
    // 상세 페이지 표시
    if (_detailWorkerId != null) {
      return WorkerDetailScreen(
        workerId: _detailWorkerId!,
        workerName: _detailWorkerName ?? '',
        onBack: _closeWorkerDetail,
      );
    }

    // 접근 불가 메뉴에 대한 방어
    if (!canAccessMenu(role, _selectedIndex)) {
      final userSiteId = ref.read(authProvider).worker?.siteId ?? '';
      return DashboardScreen(role: role, userSiteId: userSiteId, onWorkerTap: _openWorkerDetail);
    }

    final userSiteId = ref.read(authProvider).worker?.siteId ?? '';

    return switch (_selectedIndex) {
      0 => DashboardScreen(role: role, userSiteId: userSiteId, onWorkerTap: _openWorkerDetail),
      1 => WorkersScreen(role: role, onWorkerTap: _openWorkerDetail),
      2 => AttendanceRecordsScreen(role: role, onWorkerTap: _openWorkerDetail),
      3 => PayrollScreen(role: role, onWorkerTap: _openWorkerDetail),
      4 => const SettingsScreen(),
      5 => const AccountsScreen(),
      _ => DashboardScreen(role: role, userSiteId: userSiteId, onWorkerTap: _openWorkerDetail),
    };
  }
}
