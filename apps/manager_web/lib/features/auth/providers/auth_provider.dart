import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.worker,
    this.errorMessage,
  });

  final AuthStatus status;
  final Worker? worker;
  final String? errorMessage;

  AuthState copyWith({AuthStatus? status, Worker? worker, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      worker: worker ?? this.worker,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final ManagerAuthRepository _repository;

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final worker = await _repository.signInWithEmail(email, password);
      if (worker.role != 'manager') {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: '관리자 권한이 없습니다',
        );
        return;
      }
      state = state.copyWith(status: AuthStatus.authenticated, worker: worker);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '이메일 또는 비밀번호가 올바르지 않습니다',
      );
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void demoLogin() {
    state = AuthState(
      status: AuthStatus.authenticated,
      worker: Worker(
        id: 'demo-manager-id',
        siteId: 'demo-site-id',
        name: '정우성',
        phone: '010-1234-0005',
        role: 'manager',
      ),
    );
  }
}

final managerAuthRepositoryProvider = Provider((ref) => ManagerAuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(managerAuthRepositoryProvider));
});
