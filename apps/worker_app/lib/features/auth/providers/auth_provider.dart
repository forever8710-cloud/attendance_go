import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsPhoneVerification,
  pendingApproval,
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
    _setupAuthListener();
  }

  final WorkerAuthRepository _repository;
  bool _isRestoring = false;
  StreamSubscription? _authSubscription;

  /// OAuth 딥링크 콜백 수신 리스너
  void _setupAuthListener() {
    _authSubscription = _repository.listenToAuthChanges(() {
      // OAuth 리디렉트로 돌아온 경우에만 처리 (재진입 방지)
      if (!_isRestoring &&
          (state.status == AuthStatus.unauthenticated ||
           state.status == AuthStatus.initial)) {
        restoreSession();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// 앱 시작 시 기존 세션 복원
  Future<void> restoreSession() async {
    if (_isRestoring) return;
    _isRestoring = true;
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final worker = await _repository.restoreSession();
      if (worker != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          worker: worker,
        );
      } else if (_repository.hasActiveSession) {
        // OAuth 세션은 있으나 worker 매칭이 안 된 상태
        // → 가입 요청이 pending인지 확인
        final hasPending = await _repository.checkPendingRegistration();
        if (hasPending) {
          state = state.copyWith(status: AuthStatus.pendingApproval);
        } else {
          // 신규 사용자: 동의 → 등록폼 → 대기
          state = state.copyWith(status: AuthStatus.needsConsent);
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } finally {
      _isRestoring = false;
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.sendOtp(phone);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
      rethrow;
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

  /// 카카오 OAuth 로그인 (브라우저 → 리디렉트 → 자동 처리)
  Future<void> loginWithKakao() async {
    state = state.copyWith(status: AuthStatus.loading, loginProvider: LoginProvider.kakao);
    try {
      await _repository.loginWithKakao();
      // 브라우저로 이동됨. 돌아오면 onAuthStateChange → restoreSession 처리
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: '카카오 로그인에 실패했습니다');
    }
  }

  /// 구글 OAuth 로그인 (브라우저 → 리디렉트 → 자동 처리)
  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, loginProvider: LoginProvider.google);
    try {
      await _repository.loginWithGoogle();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: '구글 로그인에 실패했습니다');
    }
  }

  /// OAuth 후 전화번호로 근로자 매칭
  Future<void> verifyPhoneAfterOAuth(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final worker = await _repository.matchWorkerByPhone(phone);
      final profileComplete = await _repository.isProfileComplete(worker.id);
      state = state.copyWith(
        status: profileComplete ? AuthStatus.authenticated : AuthStatus.needsConsent,
        worker: worker,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.needsPhoneVerification,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// 가입 요청 제출
  Future<void> submitRegistration({
    required String name,
    required String phone,
    required String company,
    String? address,
    String? detailAddress,
    String? ssn,
    String? bank,
    String? accountNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.submitRegistration(
        name: name,
        phone: phone,
        company: company,
        address: address,
        detailAddress: detailAddress,
        ssn: ssn,
        bank: bank,
        accountNumber: accountNumber,
      );
      state = state.copyWith(status: AuthStatus.pendingApproval);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.needsProfileCompletion,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// 승인 상태 새로고침
  Future<void> refreshApprovalStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final worker = await _repository.restoreSession();
      if (worker != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          worker: worker,
        );
      } else {
        final hasPending = await _repository.checkPendingRegistration();
        if (hasPending) {
          state = state.copyWith(status: AuthStatus.pendingApproval);
        } else {
          // 거절됨 → 다시 동의 → 등록폼으로
          state = state.copyWith(status: AuthStatus.needsConsent);
        }
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.pendingApproval);
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
    if (state.worker == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '근로자 정보를 찾을 수 없습니다. 다시 로그인해주세요.',
      );
      return;
    }
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

  /// 개인정보 동의 완료
  void acceptConsent({required bool locationConsent}) {
    if (state.worker != null) {
      // 기존 근로자 (SMS OTP 매칭) → 권한 설정으로 이동
      state = state.copyWith(status: AuthStatus.needsPermission);
    } else {
      // 신규 사용자 (OAuth, worker 없음) → 등록폼으로 이동
      state = state.copyWith(status: AuthStatus.needsProfileCompletion);
    }
  }

  /// 앱 권한 설정 완료 → 프로필 입력으로 이동
  void acceptPermissions() {
    state = state.copyWith(status: AuthStatus.needsProfileCompletion);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Demo login — Supabase 실제 인증 (RLS 통과를 위해 auth 세션 필요)
  Future<void> demoLogin() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.demoSignIn();
      await restoreSession();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '데모 로그인 실패: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  /// 이메일/비밀번호 테스트 로그인 (개발·테스트 전용)
  Future<void> testLogin(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.signInWithEmail(email, password);
      await restoreSession();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '로그인 실패: ${e.toString().replaceAll('AuthException: ', '').replaceAll('Exception: ', '')}',
      );
    }
  }
}

final workerAuthRepositoryProvider = Provider((ref) => WorkerAuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(workerAuthRepositoryProvider));
});
