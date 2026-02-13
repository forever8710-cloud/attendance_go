import 'dart:convert';
import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import '../../../core/utils/phone_utils.dart';

class WorkerAuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  static const _workerKey = 'cached_worker';

  // ─── 세션 복원 ───

  /// 앱 시작 시 기존 세션 확인 → Worker 반환 (없으면 null)
  Future<Worker?> restoreSession() async {
    // 1) Supabase 세션 확인 (SMS OTP 로그인 시 자동 보존됨)
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        // auth uid 또는 phone으로 workers 테이블 조회
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

        // uid로 못 찾으면 phone으로 시도
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

    // 2) 로컬 캐시 확인 (데모/카카오/구글 로그인 용)
    return _loadWorkerLocal();
  }

  /// Worker 정보를 로컬에 저장
  Future<void> saveWorkerLocal(Worker worker) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workerKey, jsonEncode(worker.toJson()));
  }

  /// 로컬에서 Worker 정보 로드
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

  /// 로컬 캐시 삭제
  Future<void> _clearWorkerLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workerKey);
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

  // ─── 소셜 로그인 (데모) ───

  Future<Worker> loginWithKakao() async {
    await Future.delayed(const Duration(seconds: 1));
    final worker = Worker(
      id: 'kakao-worker-id',
      siteId: 'site-icheon',
      name: '김영수',
      phone: '010-1234-0001',
      role: 'worker',
    );
    await saveWorkerLocal(worker);
    return worker;
  }

  Future<void> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<Worker> verifyPhoneAndMatch(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    final worker = Worker(
      id: 'google-worker-id',
      siteId: 'site-icheon',
      name: '이민호',
      phone: phone,
      role: 'worker',
    );
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
