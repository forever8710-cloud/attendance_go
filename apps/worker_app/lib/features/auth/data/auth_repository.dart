import 'package:core/core.dart';

class WorkerAuthRepository {
  // 인메모리 프로필 완료 여부
  final Set<String> _completedProfiles = {};

  Future<void> sendOtp(String phone) async {
    // TODO: Supabase auth.signInWithOtp(phone: phone)
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<Worker> verifyOtp(String phone, String token) async {
    // TODO: Supabase auth.verifyOTP(phone: phone, token: token)
    await Future.delayed(const Duration(seconds: 1));
    return Worker(
      id: 'demo-worker-id',
      siteId: 'demo-site-id',
      name: '김영수',
      phone: phone,
      role: 'worker',
    );
  }

  /// 카카오 로그인 (데모: 전화번호가 카카오 계정에 연동되어 있어 바로 Worker 매칭)
  Future<Worker> loginWithKakao() async {
    await Future.delayed(const Duration(seconds: 1));
    return Worker(
      id: 'kakao-worker-id',
      siteId: 'site-icheon',
      name: '김영수',
      phone: '010-1234-0001',
      role: 'worker',
    );
  }

  /// 구글 로그인 (데모: 성공하지만 전화번호 없음)
  Future<void> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  /// 구글 로그인 후 전화번호 인증 → Worker 매칭
  Future<Worker> verifyPhoneAndMatch(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    return Worker(
      id: 'google-worker-id',
      siteId: 'site-icheon',
      name: '이민호',
      phone: phone,
      role: 'worker',
    );
  }

  /// 프로필 완료 여부 (데모: 최초 false)
  Future<bool> isProfileComplete(String workerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _completedProfiles.contains(workerId);
  }

  /// 추가정보(프로필) 저장
  Future<void> saveProfile({
    required String workerId,
    required String ssn,
    required String address,
    required String bank,
    required String accountNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _completedProfiles.add(workerId);
  }

  Future<void> signOut() async {
    // TODO: Supabase auth.signOut()
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Worker? get currentUser {
    // TODO: Check Supabase auth state
    return null;
  }
}
