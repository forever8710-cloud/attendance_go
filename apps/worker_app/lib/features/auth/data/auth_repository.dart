import 'package:core/core.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import '../../../core/utils/phone_utils.dart';

class WorkerAuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// SMS OTP 전송
  Future<void> sendOtp(String phone) async {
    final e164 = toE164(phone);
    await _supabase.auth.signInWithOtp(phone: e164);
  }

  /// SMS OTP 검증 → workers 테이블에서 Worker 조회
  Future<Worker> verifyOtp(String phone, String token) async {
    final e164 = toE164(phone);
    final response = await _supabase.auth.verifyOTP(
      phone: e164,
      token: token,
      type: OtpType.sms,
    );

    final user = response.user;
    if (user == null) throw Exception('인증에 실패했습니다');

    // workers 테이블에서 해당 전화번호로 조회
    final workerRows = await _supabase
        .from('workers')
        .select()
        .eq('phone', phone)
        .limit(1);

    if (workerRows.isEmpty) {
      // 전화번호로 못 찾으면 auth uid로 시도
      final byId = await _supabase
          .from('workers')
          .select()
          .eq('id', user.id)
          .limit(1);

      if (byId.isEmpty) {
        throw Exception('등록되지 않은 전화번호입니다. 관리자에게 문의하세요.');
      }
      return Worker.fromJson(byId.first);
    }

    return Worker.fromJson(workerRows.first);
  }

  /// 카카오 로그인 (데모 유지 — OAuth 추후)
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

  /// 구글 로그인 (데모 유지 — OAuth 추후)
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

  /// 프로필 완료 여부 확인
  Future<bool> isProfileComplete(String workerId) async {
    try {
      final rows = await _supabase
          .from('worker_profiles')
          .select('id, ssn, address')
          .eq('worker_id', workerId)
          .limit(1);

      if (rows.isEmpty) return false;
      final profile = rows.first;
      // ssn과 address가 입력되어 있으면 완료로 간주
      return profile['ssn'] != null && profile['address'] != null;
    } catch (_) {
      return false;
    }
  }

  /// 추가정보(프로필) 저장
  Future<void> saveProfile({
    required String workerId,
    required String site,
    required String ssn,
    required String address,
    required String bank,
    required String accountNumber,
  }) async {
    await _supabase.from('worker_profiles').upsert({
      'worker_id': workerId,
      'ssn': ssn,
      'address': address,
      'bank': bank,
      'account_number': accountNumber,
    }, onConflict: 'worker_id');
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Worker? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return null; // Will be resolved via verifyOtp flow
  }
}
