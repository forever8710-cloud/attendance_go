import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_client/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/main_scaffold.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/phone_verification_screen.dart';
import 'features/auth/presentation/consent_screen.dart';
import 'features/auth/presentation/permission_screen.dart';
import 'features/auth/presentation/profile_completion_screen.dart';
import 'features/auth/presentation/pending_approval_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('ko');
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
    runApp(const ProviderScope(child: WorkerApp()));
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('앱 초기화 오류:\n$e', style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
  }
}

class WorkerApp extends ConsumerWidget {
  const WorkerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkFlow',
      theme: AppTheme.light,
      builder: (context, child) {
        // 웹에서만 폰 프레임 목업 적용, 실기기에서는 전체 화면
        final platform = Theme.of(context).platform;
        final isNativeMobile = platform == TargetPlatform.android ||
            platform == TargetPlatform.iOS;
        if (isNativeMobile) return child!;
        // 웹/데스크톱: 폰 프레임 목업
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(38),
                child: child,
              ),
            ),
          ),
        );
      },
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        return const MainScaffold();
      case AuthStatus.needsPhoneVerification:
        return const PhoneVerificationScreen();
      case AuthStatus.pendingApproval:
        return const PendingApprovalScreen();
      case AuthStatus.needsConsent:
        return const ConsentScreen();
      case AuthStatus.needsPermission:
        return const PermissionScreen();
      case AuthStatus.needsProfileCompletion:
        return const ProfileCompletionScreen();
      default:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('WorkFlow', style: AppTheme.brandTitle),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
