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
  }

  final ManagerAuthRepository _repository;
  StreamSubscription? _authSubscription;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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
