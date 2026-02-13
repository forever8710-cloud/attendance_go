import 'dart:convert';
import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/phone_utils.dart';

class WorkerAuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  static const _workerKey = 'cached_worker';

  // ─── 세션 복원 ───

  Future<Worker?> restoreSession() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        // auth uid로 workers 조회
        final rows = await _supabase
            .from('workers')
            .select()
            .eq('id', user.id)
            .limit(1);

        if (rows.isNotEmpty) {
          final worker = Worker.fromJson(rows.first);
          await saveWorkerLocal(worker);
          return worker;
        }

        // phone으로 시도
        final phone = user.phone;
        if (phone != null && phone.isNotEmpty) {
          final byPhone = await _supabase
              .from('workers')
              .select()
              .eq('phone', phone)
              .limit(1);
          if (byPhone.isNotEmpty) {
            final worker = Worker.fromJson(byPhone.first);
            await saveWorkerLocal(worker);
            return worker;
          }
        }
      } catch (_) {
        // DB 조회 실패 시 로컬 캐시 시도
      }
    }

    // 로컬 캐시 확인 (OAuth 로그인 후 매칭된 worker)
    return _loadWorkerLocal();
  }

  Future<void> saveWorkerLocal(Worker worker) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workerKey, jsonEncode(worker.toJson()));
  }

  Future<Worker?> _loadWorkerLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_workerKey);
    if (json == null) return null;
    try {
      return Worker.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_workerKey);
      return null;
    }
  }

  Future<void> _clearWorkerLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workerKey);
  }

  // ─── Supabase 세션 확인 ───

  /// OAuth 로그인 후 세션은 있으나 worker 매칭이 안 된 경우 판별
  bool get hasActiveSession => _supabase.auth.currentUser != null;

  // ─── OAuth 로그인 (실제 연동) ───

  Future<void> loginWithKakao() async {
    await _signInWithOAuth(OAuthProvider.kakao);
  }

  Future<void> loginWithGoogle() async {
    await _signInWithOAuth(OAuthProvider.google);
  }

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    // supabase_flutter v2: 자동으로 브라우저를 열고 딥링크 콜백을 처리
    await _supabase.auth.signInWithOAuth(
      provider,
      redirectTo: 'io.supabase.workflowapp://login-callback',
    );
  }

  // ─── OAuth 후 전화번호로 근로자 매칭 ───

  Future<Worker> matchWorkerByPhone(String phone) async {
    // 입력된 전화번호 형식 정리 (010-1234-5678 → 010-1234-5678)
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9\-]'), '');

    final rows = await _supabase
        .from('workers')
        .select()
        .eq('phone', cleanPhone)
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('등록되지 않은 전화번호입니다. 관리자에게 문의하세요.');
    }

    final worker = Worker.fromJson(rows.first);
    await saveWorkerLocal(worker);
    return worker;
  }

  // ─── Auth 상태 변경 리스너 ───

  void listenToAuthChanges(void Function() onSignedIn) {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        onSignedIn();
      }
    });
  }

  // ─── SMS 인증 ───

  Future<void> sendOtp(String phone) async {
    final e164 = toE164(phone);
    await _supabase.auth.signInWithOtp(phone: e164);
  }

  Future<Worker> verifyOtp(String phone, String token) async {
    final e164 = toE164(phone);
    final response = await _supabase.auth.verifyOTP(
      phone: e164,
      token: token,
      type: OtpType.sms,
    );

    final user = response.user;
    if (user == null) throw Exception('인증에 실패했습니다');

    final workerRows = await _supabase
        .from('workers')
        .select()
        .eq('phone', phone)
        .limit(1);

    if (workerRows.isEmpty) {
      final byId = await _supabase
          .from('workers')
          .select()
          .eq('id', user.id)
          .limit(1);

      if (byId.isEmpty) {
        throw Exception('등록되지 않은 전화번호입니다. 관리자에게 문의하세요.');
      }
      final worker = Worker.fromJson(byId.first);
      await saveWorkerLocal(worker);
      return worker;
    }

    final worker = Worker.fromJson(workerRows.first);
    await saveWorkerLocal(worker);
    return worker;
  }

  // ─── 프로필 ───

  Future<bool> isProfileComplete(String workerId) async {
    try {
      final rows = await _supabase
          .from('worker_profiles')
          .select('id, ssn, address')
          .eq('worker_id', workerId)
          .limit(1);

      if (rows.isEmpty) return false;
      final profile = rows.first;
      return profile['ssn'] != null && profile['address'] != null;
    } catch (_) {
      return false;
    }
  }

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

  // ─── 로그아웃 ───

  Future<void> signOut() async {
    await _clearWorkerLocal();
    await _supabase.auth.signOut();
  }
}
