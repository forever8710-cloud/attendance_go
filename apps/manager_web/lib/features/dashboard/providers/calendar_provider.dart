import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

class CalendarEvent {
  CalendarEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    this.description,
    this.color = '#3F51B5',
    this.category = '일정',
    this.location,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String title;
  final DateTime eventDate;
  final String? description;
  final String color;
  final String category;
  final String? location;
  final String? createdBy;
  final DateTime? createdAt;

  Color get displayColor {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF8D99AE);
    }
  }
}

class CalendarRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<CalendarEvent>> getEvents(DateTime start, DateTime end) async {
    final rows = await _supabase
        .from('calendar_events')
        .select()
        .gte('event_date', start.toIso8601String().substring(0, 10))
        .lte('event_date', end.toIso8601String().substring(0, 10))
        .order('event_date');

    return (rows as List).map((row) => CalendarEvent(
      id: row['id'] as String,
      title: row['title'] as String,
      eventDate: DateTime.parse(row['event_date'] as String),
      description: row['description'] as String?,
      color: row['color'] as String? ?? '#3F51B5',
      category: row['category'] as String? ?? '일정',
      location: row['location'] as String?,
      createdBy: row['created_by'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'] as String)
          : null,
    )).toList();
  }

  Future<void> addEvent({
    required String title,
    required DateTime eventDate,
    String? description,
    String color = '#3F51B5',
    String category = '일정',
    String? location,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    await _supabase.from('calendar_events').insert({
      'title': title,
      'event_date': eventDate.toIso8601String().substring(0, 10),
      'description': description,
      'color': color,
      'category': category,
      'location': location,
      'created_by': userId,
    });
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required DateTime eventDate,
    String? description,
    String color = '#3F51B5',
    String category = '일정',
    String? location,
  }) async {
    await _supabase.from('calendar_events').update({
      'title': title,
      'event_date': eventDate.toIso8601String().substring(0, 10),
      'description': description,
      'color': color,
      'category': category,
      'location': location,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deleteEvent(String id) async {
    await _supabase.from('calendar_events').delete().eq('id', id);
  }
}

final calendarRepositoryProvider = Provider((ref) => CalendarRepository());

/// 현재 보이는 월의 이벤트들
final calendarMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) {
  final month = ref.watch(calendarMonthProvider);
  final start = DateTime(month.year, month.month - 1, 1);
  final end = DateTime(month.year, month.month + 2, 0);
  return ref.watch(calendarRepositoryProvider).getEvents(start, end);
});

/// 오늘 날짜의 이벤트만 반환 (헤더 알림 배너용)
final todayEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final today = DateTime.now();
  final events = await ref.watch(calendarRepositoryProvider).getEvents(
    DateTime(today.year, today.month, today.day),
    DateTime(today.year, today.month, today.day),
  );
  return events;
});
