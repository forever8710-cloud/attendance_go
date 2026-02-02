import 'package:core/core.dart';

class ManagerAuthRepository {
  Future<Worker> signInWithEmail(String email, String password) async {
    // TODO: Supabase auth.signInWithPassword(email, password)
    await Future.delayed(const Duration(seconds: 1));
    return Worker(
      id: 'demo-manager-id',
      siteId: 'demo-site-id',
      name: '정우성',
      phone: '010-1234-0005',
      role: 'manager',
    );
  }

  Future<void> signOut() async {
    // TODO: Supabase auth.signOut()
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
