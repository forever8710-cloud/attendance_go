import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel, PostgresChangeEvent;
import 'core/utils/permissions.dart';
import 'core/services/web_tts_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/password_reset_dialog.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/workers/presentation/workers_screen.dart';
import 'features/attendance_records/presentation/attendance_records_screen.dart';
import 'features/payroll/presentation/payroll_screen.dart';
import 'features/accounts/presentation/accounts_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/providers/settings_provider.dart';
import 'core/widgets/side_nav_drawer.dart';
import 'core/widgets/privacy_policy_dialog.dart';
import 'features/worker_detail/presentation/worker_detail_screen.dart';
import 'features/workers/providers/registration_provider.dart';
import 'features/workers/presentation/widgets/pending_requests_dialog.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('.env 파일에 SUPABASE_URL 또는 SUPABASE_ANON_KEY가 설정되지 않았습니다.');
    }
    await SupabaseService.instance.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    await initializeDateFormatting('ko');
    runApp(const ProviderScope(child: ManagerApp()));
  } catch (e, st) {
    debugPrint('INIT ERROR: $e');
    debugPrint('STACK: $st');
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Init Error:\n$e',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
  }
}

final _navigatorKey = GlobalKey<NavigatorState>();

class ManagerApp extends ConsumerStatefulWidget {
  const ManagerApp({super.key});

  @override
  ConsumerState<ManagerApp> createState() => _ManagerAppState();
}

class _ManagerAppState extends ConsumerState<ManagerApp> {
  bool _recoveryDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final settings = ref.watch(appSettingsProvider);

    // Recovery 이벤트 감지 → 비밀번호 변경 다이얼로그 표시
    if (authState.isPasswordRecovery && !_recoveryDialogShown) {
      _recoveryDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navContext = _navigatorKey.currentContext;
        if (navContext != null) {
          showDialog(
            context: navContext,
            barrierDismissible: false,
            builder: (_) => const PasswordChangeDialog(),
          ).then((_) => _recoveryDialogShown = false);
        } else {
          _recoveryDialogShown = false;
        }
      });
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Workflow by TKholdings',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8D99AE)),
        textTheme: GoogleFonts.notoSansKrTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D99AE),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E2E),
          onSurface: const Color(0xFFE0E0E8),
        ),
        textTheme: GoogleFonts.notoSansKrTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
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
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _setupRealtime();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    _realtimeChannel = SupabaseService.instance
        .channel('dashboard-attendance')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'attendances',
          callback: _onAttendanceInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'attendances',
          callback: _onAttendanceUpdate,
        )
        .subscribe();
  }

  /// 새 출근 기록 감지 → TTS "XXX 출근완료" + 대시보드 새로고침
  void _onAttendanceInsert(dynamic payload) async {
    if (!mounted) return;
    // 대시보드 데이터 리프레시
    ref.read(dashboardRefreshProvider.notifier).state++;

    // TTS 알림
    final ttsEnabled = ref.read(ttsEnabledProvider);
    if (!ttsEnabled) return;

    try {
      final newRecord = (payload as dynamic).newRecord as Map<String, dynamic>?;
      final workerId = newRecord?['worker_id'] as String?;
      if (workerId == null) return;

      final worker = await SupabaseService.instance
          .from('workers')
          .select('name')
          .eq('id', workerId)
          .maybeSingle();
      if (!mounted) return;

      final name = worker?['name'] as String?;
      if (name != null && name.isNotEmpty) {
        WebTtsService.speak('$name 출근완료');
      }
    } catch (_) {}
  }

  /// 퇴근/수정 감지 → 대시보드 새로고침 (TTS 없음)
  void _onAttendanceUpdate(dynamic payload) {
    if (!mounted) return;
    ref.read(dashboardRefreshProvider.notifier).state++;
  }

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
            pendingRegistrationCount: ref.watch(pendingCountProvider).valueOrNull ?? 0,
          ),
          VerticalDivider(width: 1, thickness: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          Expanded(
            child: Column(
              children: [
                // Top header (사이드 네비 로고와 동일 높이)
                Container(
                  height: 112,
                  padding: const EdgeInsets.only(left: 28, right: 20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(DateTime.now()),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface),
                      ),
                      const SizedBox(width: 16),
                      // 가입 요청 알림 — 클릭 시 근로자 등록 탭으로 이동
                      _buildRegistrationAlert(context),
                      const Spacer(),
                      // TTS 음성 알림 토글
                      _buildTtsToggle(),
                      const SizedBox(width: 8),
                      // 역할 배지
                      _buildRoleBadge(role),
                      const SizedBox(width: 12),
                      Text('(주) 티케이홀딩스', style: TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(width: 16),
                      Text(authState.worker?.name ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      const SizedBox(width: 10),
                      CircleAvatar(radius: 18, backgroundColor: cs.primaryContainer, child: Icon(Icons.person, size: 22, color: cs.onPrimaryContainer)),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.logout, size: 24, color: cs.onSurface.withValues(alpha: 0.7)),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => showDialog(context: context, builder: (_) => const PrivacyPolicyDialog()),
                        child: Text(
                          '개인정보처리방침',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.primary, decoration: TextDecoration.underline, decorationColor: cs.primary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('|', style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.3))),
                      ),
                      Text(
                        'COPYRIGHT © 2026 TaekyungHoldings. ALL RIGHTS RESERVED.',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationAlert(BuildContext context) {
    final countAsync = ref.watch(pendingCountProvider);
    final count = countAsync.valueOrNull ?? 0;

    if (count == 0) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // 근로자 등록 탭(index 2)으로 이동
          setState(() {
            _selectedIndex = 2;
            _detailWorkerId = null;
            _detailWorkerName = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_rounded, size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                '근로자 등록 요청 $count건',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTtsToggle() {
    final ttsEnabled = ref.watch(ttsEnabledProvider);
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: ttsEnabled ? '출근 음성 알림 끄기' : '출근 음성 알림 켜기',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => ref.read(ttsEnabledProvider.notifier).state = !ttsEnabled,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: ttsEnabled
                ? Colors.green.withValues(alpha: 0.1)
                : cs.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ttsEnabled
                  ? Colors.green.withValues(alpha: 0.4)
                  : cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                size: 18,
                color: ttsEnabled ? Colors.green[700] : cs.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 4),
              Text(
                ttsEnabled ? '알림 ON' : '알림 OFF',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ttsEnabled ? Colors.green[700] : cs.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(AppRole role) {
    final (color, bgColor) = switch (role) {
      AppRole.systemAdmin => (Colors.white, Colors.red[700]!),
      AppRole.owner => (Colors.white, const Color(0xFF2B2D42)),
      AppRole.centerManager => (Colors.white, Colors.teal[700]!),
      AppRole.worker => (Colors.white, Colors.grey[600]!),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        roleDisplayName(role),
        style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
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
      1 => AttendanceRecordsScreen(role: role, onWorkerTap: _openWorkerDetail),
      2 => WorkersScreen(role: role, userSiteId: userSiteId, onWorkerTap: _openWorkerDetail),
      3 => PayrollScreen(role: role, onWorkerTap: _openWorkerDetail),
      4 => const SettingsScreen(),
      5 => const AccountsScreen(),
      _ => DashboardScreen(role: role, userSiteId: userSiteId, onWorkerTap: _openWorkerDetail),
    };
  }
}
