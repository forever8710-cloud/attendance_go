import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_client/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';

class WeatherData {
  final double temperature;
  final int weatherCode;
  final String emoji;
  final String description;

  const WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.emoji,
    required this.description,
  });
}

/// WMO Weather Code → 이모지 + 설명
({String emoji, String desc}) _weatherCodeToEmoji(int code) {
  return switch (code) {
    0 => (emoji: '☀️', desc: '맑음'),
    1 => (emoji: '🌤️', desc: '대체로 맑음'),
    2 => (emoji: '⛅', desc: '구름 조금'),
    3 => (emoji: '☁️', desc: '흐림'),
    45 || 48 => (emoji: '🌫️', desc: '안개'),
    51 || 53 || 55 => (emoji: '🌦️', desc: '이슬비'),
    56 || 57 => (emoji: '🌧️', desc: '얼어붙는 이슬비'),
    61 || 63 => (emoji: '🌧️', desc: '비'),
    65 => (emoji: '🌧️', desc: '강한 비'),
    66 || 67 => (emoji: '🌧️', desc: '얼어붙는 비'),
    71 || 73 => (emoji: '🌨️', desc: '눈'),
    75 => (emoji: '❄️', desc: '강한 눈'),
    77 => (emoji: '🌨️', desc: '싸락눈'),
    80 || 81 || 82 => (emoji: '🌧️', desc: '소나기'),
    85 || 86 => (emoji: '🌨️', desc: '눈소나기'),
    95 => (emoji: '⛈️', desc: '뇌우'),
    96 || 99 => (emoji: '⛈️', desc: '우박 뇌우'),
    _ => (emoji: '🌡️', desc: '날씨'),
  };
}

/// 사용자 사업장 좌표 기반 현재 날씨 조회 (Open-Meteo, 무료, API 키 불필요)
final weatherProvider = FutureProvider<WeatherData?>((ref) async {
  try {
    // 사용자의 사업장 좌표 조회
    final authState = ref.watch(authProvider);
    final siteId = authState.worker?.siteId;

    double lat = 37.5665; // 서울 기본값
    double lon = 126.978;

    if (siteId != null && siteId.isNotEmpty) {
      try {
        final site = await SupabaseService.instance
            .from('sites')
            .select('latitude, longitude')
            .eq('id', siteId)
            .maybeSingle();
        if (site != null) {
          lat = (site['latitude'] as num).toDouble();
          lon = (site['longitude'] as num).toDouble();
        }
      } catch (_) {}
    }

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current_weather=true'
      '&timezone=Asia%2FSeoul',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final current = data['current_weather'] as Map<String, dynamic>?;
    if (current == null) return null;

    final temp = (current['temperature'] as num).toDouble();
    final code = (current['weathercode'] as num).toInt();
    final result = _weatherCodeToEmoji(code);

    return WeatherData(
      temperature: temp,
      weatherCode: code,
      emoji: result.emoji,
      description: result.desc,
    );
  } catch (_) {
    return null;
  }
});
