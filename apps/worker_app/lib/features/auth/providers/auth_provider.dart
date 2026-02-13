import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsPhoneVerification,
  needsConsent,
  needsPermission,
  needsProfileCompletion,
  error,
}

enum LoginProvider { kakao, google, sms }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.worker,
    this.errorMessage,
    this.loginProvider,
  });

  final AuthStatus status;
  final Worker? worker;
  final String? errorMessage;
  final LoginProvider? loginProvider;

  AuthState copyWith({
    AuthStatus? status,
    Worker? worker,
    String? errorMessage,
    LoginProvider? loginProvider,
  }) {
    return AuthState(
      status: status ?? this.status,
      worker: worker ?? this.worker,
      errorMessage: errorMessage,
      loginProvider: loginProvider ?? this.loginProvider,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    restoreSession();
  }

  final WorkerAuthRepository _repository;

  /// 앱 시작 시 기존 세션 복원
  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final worker = await _repository.restoreSession();
      if (worker != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          worker: worker,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

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
      final profileComplete = await _repository.isProfileComplete(worker.id);
      state = state.copyWith(
        status: profileComplete ? AuthStatus.authenticated : AuthStatus.needsConsent,
        worker: worker,
        loginProvider: LoginProvider.sms,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// 카카오 로그인 (데모: 바로 인증 완료)
  Future<void> loginWithKakao() async {
    state = state.copyWith(status: AuthStatus.loading, loginProvider: LoginProvider.kakao);
    try {
      final worker = await _repository.loginWithKakao();
      final profileComplete = await _repository.isProfileComplete(worker.id);
      state = state.copyWith(
        status: profileComplete ? AuthStatus.authenticated : AuthStatus.needsConsent,
        worker: worker,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: '카카오 로그인에 실패했습니다');
    }
  }

  /// 구글 로그인 → 전화번호 인증 필요
  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, loginProvider: LoginProvider.google);
    try {
      await _repository.loginWithGoogle();
      state = state.copyWith(status: AuthStatus.needsPhoneVerification);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: '구글 로그인에 실패했습니다');
    }
  }

  /// 구글 로그인 후 전화번호 인증
  Future<void> verifyPhoneAfterGoogle(String phone, String otp) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final worker = await _repository.verifyPhoneAndMatch(phone, otp);
      final profileComplete = await _repository.isProfileComplete(worker.id);
      state = state.copyWith(
        status: profileComplete ? AuthStatus.authenticated : AuthStatus.needsConsent,
        worker: worker,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: '전화번호 인증에 실패했습니다');
    }
  }

  /// 추가정보 저장
  Future<void> saveProfile({
    required String site,
    required String ssn,
    required String address,
    required String detailAddress,
    required String bank,
    required String accountNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.saveProfile(
        workerId: state.worker!.id,
        site: site,
        ssn: ssn,
        address: '$address $detailAddress',
        bank: bank,
        accountNumber: accountNumber,
      );
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: '프로필 저장에 실패했습니다');
    }
  }

  /// 개인정보 동의 완료 → 권한 설정으로 이동
  void acceptConsent({required bool locationConsent}) {
    state = state.copyWith(status: AuthStatus.needsPermission);
  }

  /// 앱 권한 설정 완료 → 프로필 입력으로 이동
  void acceptPermissions() {
    state = state.copyWith(status: AuthStatus.needsProfileCompletion);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Demo login for testing without Supabase
  Future<void> demoLogin() async {
    final worker = Worker(
      id: 'demo-worker-id',
      siteId: 'demo-site-id',
      name: '김영수',
      phone: '010-1234-0001',
      role: 'worker',
    );
    // 로컬에도 저장하여 앱 재시작 시 자동 로그인
    await _repository.saveWorkerLocal(worker);
    state = AuthState(
      status: AuthStatus.authenticated,
      worker: worker,
      loginProvider: LoginProvider.kakao,
    );
  }
}

final workerAuthRepositoryProvider = Provider((ref) => WorkerAuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(workerAuthRepositoryProvider));
});
