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

  final WorkerAuthRepository _repository;

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.sendOtp(phone);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> verifyOtp(String phone, String token) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final worker = await _repository.verifyOtp(phone, token);
      state = state.copyWith(status: AuthStatus.authenticated, worker: worker);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: '인증에 실패했습니다');
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Demo login for testing without Supabase
  void demoLogin() {
    state = AuthState(
      status: AuthStatus.authenticated,
      worker: Worker(
        id: 'demo-worker-id',
        siteId: 'demo-site-id',
        name: '김영수',
        phone: '010-1234-0001',
        role: 'worker',
      ),
    );
  }
}

final workerAuthRepositoryProvider = Provider((ref) => WorkerAuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(workerAuthRepositoryProvider));
});
