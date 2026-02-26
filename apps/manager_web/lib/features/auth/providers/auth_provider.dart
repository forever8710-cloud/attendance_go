import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthException, Supabase;
import '../../../core/utils/permissions.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.worker,
    this.errorMessage,
    this.role = AppRole.worker,
    this.isPasswordRecovery = false,
  });

  final AuthStatus status;
  final Worker? worker;
  final String? errorMessage;
  final AppRole role;
  final bool isPasswordRecovery;

  AuthState copyWith({AuthStatus? status, Worker? worker, String? errorMessage, AppRole? role, bool? isPasswordRecovery}) {
    return AuthState(
      status: status ?? this.status,
      worker: worker ?? this.worker,
      errorMessage: errorMessage,
      role: role ?? this.role,
      isPasswordRecovery: isPasswordRecovery ?? this.isPasswordRecovery,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        state = state.copyWith(isPasswordRecovery: true);
      }
    });
    // 앱 시작 시 기존 세션 복원
    _restoreSession();
  }

  final ManagerAuthRepository _repository;
  StreamSubscription? _authSubscription;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// 앱 시작 시 기존 Supabase 세션 복원
  Future<void> _restoreSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      if (session == null || user == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // 세션이 만료됐으면 리프레시 시도
      if (session.isExpired) {
        try {
          await Supabase.instance.client.auth.refreshSession();
        } catch (_) {
          state = const AuthState(status: AuthStatus.unauthenticated);
          return;
        }
      }

      // workers 테이블에서 사용자 정보 조회
      final workerData = await Supabase.instance.client
          .from('workers')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (workerData == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      final worker = Worker.fromJson(workerData);
      final role = roleFromString(worker.role);

      if (!canAccessManagerWeb(role)) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      state = AuthState(
        status: AuthStatus.authenticated,
        worker: worker,
        role: role,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final worker = await _repository.signInWithEmail(email, password);
      final role = roleFromString(worker.role);
      if (!canAccessManagerWeb(role)) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: '관리자 권한이 없습니다',
        );
        return;
      }
      state = state.copyWith(status: AuthStatus.authenticated, worker: worker, role: role);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message == 'Invalid login credentials'
            ? '이메일 또는 비밀번호가 올바르지 않습니다'
            : e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '로그인 중 오류가 발생했습니다: $e',
      );
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> resetPassword(String email, {String? redirectTo}) async {
    await _repository.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  Future<void> updatePassword(String newPassword) async {
    await _repository.updatePassword(newPassword);
    state = state.copyWith(isPasswordRecovery: false);
  }

  void clearRecovery() {
    state = state.copyWith(isPasswordRecovery: false);
  }

  /// 현재 비밀번호 확인 후 새 비밀번호로 변경
  Future<void> verifyAndChangePassword(String currentPassword, String newPassword) async {
    await _repository.verifyAndChangePassword(currentPassword, newPassword);
  }

  void demoLogin(AppRole role) {
    final roleName = roleDisplayName(role);
    state = AuthState(
      status: AuthStatus.authenticated,
      role: role,
      worker: Worker(
        id: 'demo-${roleToString(role)}-id',
        siteId: role == AppRole.owner ? '' : 'demo-site-id',
        name: '데모 $roleName',
        phone: '010-0000-0000',
        role: roleToString(role),
      ),
    );
  }
}

final managerAuthRepositoryProvider = Provider((ref) => ManagerAuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(managerAuthRepositoryProvider));
});
