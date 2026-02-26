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
    // SECURITY DEFINER 함수로 RLS 우회하여 전화번호 검색
    final rows = await _supabase.client.rpc(
      'match_worker_by_phone',
      params: {'phone_input': phone},
    );

    if (rows == null || (rows as List).isEmpty) {
      throw Exception('등록되지 않은 전화번호입니다. 관리자에게 문의하세요.');
    }

    final matched = Worker.fromJson((rows as List).first as Map<String, dynamic>);

    // OAuth 사용자를 기존 worker에 연결 (worker.id → auth.uid()로 변경)
    // 이후 RLS가 정상 작동하도록 함
    final user = _supabase.auth.currentUser;
    if (user != null && matched.id != user.id) {
      try {
        await _supabase.client.rpc(
          'link_worker_to_auth',
          params: {'p_old_worker_id': matched.id},
        );
        // 연결 성공 → 새 ID(auth.uid())로 worker 재조회
        final updated = await _supabase.client.rpc(
          'match_worker_by_phone',
          params: {'phone_input': phone},
        );
        if (updated != null && (updated as List).isNotEmpty) {
          final worker = Worker.fromJson(updated.first as Map<String, dynamic>);
          await saveWorkerLocal(worker);
          return worker;
        }
      } catch (e) {
        debugPrint('link_worker_to_auth failed: $e');
      }
    }

    await saveWorkerLocal(matched);
    return matched;
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
    String? ssn,
    String? bank,
    String? accountNumber,
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
      'ssn': ssn,
      'bank': bank,
      'account_number': accountNumber,
    });
  }

  // ─── 프로필 ───

  Future<bool> isProfileComplete(String workerId) async {
    try {
      // SECURITY DEFINER 함수로 RLS 우회
      final result = await _supabase.client.rpc(
        'check_worker_profile_complete',
        params: {'p_worker_id': workerId},
      );
      return result == true;
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
    // SECURITY DEFINER 함수로 RLS 우회
    await _supabase.client.rpc(
      'upsert_worker_profile',
      params: {
        'p_worker_id': workerId,
        'p_ssn': ssn,
        'p_address': address,
        'p_bank': bank,
        'p_account_number': accountNumber,
      },
    );
  }

  // ─── 이메일/비밀번호 로그인 (테스트/관리자용) ───

  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
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
    await signInWithEmail(email, password);
  }

  // ─── 로그아웃 ───

  Future<void> signOut() async {
    await _clearWorkerLocal();
    await _supabase.auth.signOut();
  }
}
