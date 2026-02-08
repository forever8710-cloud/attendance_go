import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/phone_verification_screen.dart';
import 'features/auth/presentation/profile_completion_screen.dart';
import 'features/attendance/presentation/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: WorkerApp()));
}

class WorkerApp extends ConsumerWidget {
  const WorkerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '출퇴근GO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      builder: (context, child) {
        // 웹에서도 모바일 기기처럼 보이게 프레임 추가
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
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.needsPhoneVerification:
        return const PhoneVerificationScreen();
      case AuthStatus.needsProfileCompletion:
        return const ProfileCompletionScreen();
      default:
        return const LoginScreen();
    }
  }
}
