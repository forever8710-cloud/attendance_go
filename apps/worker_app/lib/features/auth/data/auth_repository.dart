import 'dart:async';
import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

        // DB에서 worker를 찾지 못하면 로컬 캐시 확인
        final cached = await _loadWorkerLocal();
        if (cached != null) return cached;

        // 세션은 있으나 worker 매칭 안 됨 → null 반환 (needsPhoneVerification)
        return null;
      } catch (e) {
        debugPrint('restoreSession error: $e');
        // DB 조회 실패 시 로컬 캐시 시도
      }
    }

    // 세션 없음 → 로컬 캐시 확인 (OAuth 로그인 후 매칭된 worker)
    return _loadWorkerLocal();
  }

  Future<void> saveWorkerLocal(Worker worker) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workerKey, jsonEncode(worker.toJson()));
  }

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<Worker?> _loadWorkerLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_workerKey);
    if (json == null) return null;
    try {
      final worker = Worker.fromJson(jsonDecode(json) as Map<String, dynamic>);
      // 유효하지 않은 ID(예: "demo-worker-id")가 캐시된 경우 제거
      if (!_uuidRegex.hasMatch(worker.id)) {
        await prefs.remove(_workerKey);
        return null;
      }
      return worker;
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
    // 웹: 현재 URL로 리다이렉트, 모바일: 딥링크 사용
    final redirectUrl = kIsWeb
        ? Uri.base.origin
        : 'io.supabase.workflowapp://login-callback';
    await _supabase.auth.signInWithOAuth(
      provider,
      redirectTo: redirectUrl,
    );
  }

  // ─── OAuth 후 전화번호로 근로자 매칭 ───

  Future<Worker> matchWorkerByPhone(String phone) async {
    // 숫자만 추출 (010-1234-5678 → 01012345678)
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // DB에 대시 포함/미포함 형식이 혼재 → 두 형식 모두 검색
    String withDashes = digitsOnly;
    if (digitsOnly.length == 11) {
      withDashes =
          '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
    }

    final rows = await _supabase
        .from('workers')
        .select()
        .or('phone.eq.$digitsOnly,phone.eq.$withDashes')
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('등록되지 않은 전화번호입니다. 관리자에게 문의하세요.');
    }

    final worker = Worker.fromJson(rows.first);
    await saveWorkerLocal(worker);
    return worker;
  }

  // ─── Auth 상태 변경 리스너 ───

  StreamSubscription listenToAuthChanges(void Function() onSignedIn) {
    return _supabase.auth.onAuthStateChange.listen((data) {
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

  // ─── 가입 요청 ───

  /// auth.uid()로 pending 상태의 registration_requests가 있는지 확인
  Future<bool> checkPendingRegistration() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    try {
      final rows = await _supabase
          .from('registration_requests')
          .select('id')
          .eq('auth_user_id', user.id)
          .eq('status', 'pending')
          .limit(1);
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// 가입 요청 제출
  Future<void> submitRegistration({
    required String name,
    required String phone,
    required String company,
    String? address,
    String? detailAddress,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('로그인 세션이 없습니다.');

    // 이미 pending 요청이 있는지 확인
    final existing = await _supabase
        .from('registration_requests')
        .select('id')
        .eq('auth_user_id', user.id)
        .eq('status', 'pending')
        .limit(1);

    if (existing.isNotEmpty) {
      throw Exception('이미 가입 요청이 접수되어 있습니다.');
    }

    await _supabase.from('registration_requests').insert({
      'auth_user_id': user.id,
      'name': name,
      'phone': phone,
      'company': company,
      'address': address,
      'detail_address': detailAddress,
    });
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

  // ─── 데모 로그인 (테스트용, 디버그 빌드 전용) ───

  Future<void> demoSignIn() async {
    if (!kDebugMode) {
      throw Exception('데모 로그인은 디버그 모드에서만 사용 가능합니다.');
    }
    final email = dotenv.env['DEMO_EMAIL'];
    final password = dotenv.env['DEMO_PASSWORD'];
    if (email == null || password == null) {
      throw Exception('.env에 DEMO_EMAIL/DEMO_PASSWORD가 설정되지 않았습니다.');
    }
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ─── 로그아웃 ───

  Future<void> signOut() async {
    await _clearWorkerLocal();
    await _supabase.auth.signOut();
  }
}
