import 'package:core/core.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

class ManagerAuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<Worker> signInWithEmail(String email, String password) async {
    // Supabase Auth 로그인
    final authResponse = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('로그인 실패: 사용자 정보를 가져올 수 없습니다');
    }

    // workers 테이블에서 해당 유저 정보 조회
    final workerData = await _supabase
        .from('workers')
        .select()
        .eq('id', user.id)
        .single();

    return Worker.fromJson(workerData);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// 비밀번호 재설정 이메일 발송
  Future<void> resetPasswordForEmail(String email, {String? redirectTo}) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }

  /// 비밀번호 변경 (recovery 후 호출)
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      supabase_flutter.UserAttributes(password: newPassword),
    );
  }
}
