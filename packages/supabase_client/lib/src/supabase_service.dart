import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService _instance = SupabaseService._();
  static SupabaseService get instance => _instance;

  bool _initialized = false;

  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_initialized) return;

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _initialized = true;
  }

  SupabaseClient get client => Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  SupabaseQueryBuilder from(String table) => client.from(table);

  RealtimeChannel channel(String name) => client.channel(name);
}
