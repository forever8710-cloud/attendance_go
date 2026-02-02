import 'package:core/core.dart';

class WorkerAuthRepository {
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

  Future<void> signOut() async {
    // TODO: Supabase auth.signOut()
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Worker? get currentUser {
    // TODO: Check Supabase auth state
    return null;
  }
}
