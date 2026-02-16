import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/calendar_provider.dart';
import 'korean_holidays.dart';

/// ECOUNT ERP 스타일 테이블 그리드 캘린더
class DashboardCalendar extends ConsumerStatefulWidget {
  const DashboardCalendar({super.key});

  @override
  ConsumerState<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends ConsumerState<DashboardCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    ref.read(calendarMonthProvider.notifier).state = _currentMonth;
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    ref.read(calendarMonthProvider.notifier).state = _currentMonth;
  }

  List<CalendarEvent> _getEventsForDay(DateTime day, List<CalendarEvent> allEvents) {
    return allEvents.where((e) =>
      e.eventDate.year == day.year &&
      e.eventDate.month == day.month &&
      e.eventDate.day == day.day,
    ).toList();
  }

  /// 달력에 표시할 주 단위 날짜 리스트 생성
  List<List<DateTime>> _buildWeeks() {
    final first = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    // 일요일 = 0 기준으로 시작 요일 계산
    final startWeekday = first.weekday % 7; // DateTime: Mon=1..Sun=7 → Sun=0

    final List<DateTime> days = [];

    // 이전 달 채우기
    for (int i = startWeekday - 1; i >= 0; i--) {
      days.add(first.subtract(Duration(days: i + 1)));
    }

    // 현재 달
    for (int d = 1; d <= lastDay; d++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, d));
    }

    // 다음 달 채우기 (6주 = 42일)
    while (days.length < 42) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    // 주 단위로 분할
    final List<List<DateTime>> weeks = [];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }

    // 마지막 주가 전부 다음 달이면 제거
    if (weeks.length > 5) {
      final lastWeek = weeks.last;
      if (lastWeek.every((d) => d.month != _currentMonth.month)) {
        weeks.removeLast();
      }
    }

    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final eventsAsync = ref.watch(calendarEventsProvider);
    final allEvents = eventsAsync.valueOrNull ?? [];
    final weeks = _buildWeeks();
    final now = DateTime.now();

    return SizedBox(
      width: 884,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 헤더: < 2026/02 > 일정관리 ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              InkWell(
                onTap: _prevMonth,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(Icons.chevron_left, size: 20, color: cs.onSurface),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '${_currentMonth.year}/${_currentMonth.month.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 2),
              InkWell(
                onTap: _nextMonth,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(Icons.chevron_right, size: 20, color: cs.onSurface),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '일정관리',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),

        // ── 캘린더 테이블 ──
        Table(
          border: TableBorder.all(color: cs.outlineVariant.withValues(alpha: 0.4), width: 1),
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            // 요일 헤더
            TableRow(
              decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5)),
              children: ['일', '월', '화', '수', '목', '금', '토'].asMap().entries.map((entry) {
                final i = entry.key;
                final day = entry.value;
                Color textColor;
                if (i == 0) {
                  textColor = Colors.red;
                } else if (i == 6) {
                  textColor = Colors.blue;
                } else {
                  textColor = cs.onSurface.withValues(alpha: 0.7);
                }
                return TableCell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // 날짜 행
            ...weeks.map((week) => TableRow(
              children: week.asMap().entries.map((entry) {
                final colIndex = entry.key;
                final date = entry.value;
                final isCurrentMonth = date.month == _currentMonth.month;
                final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                final holiday = KoreanHolidays.getHolidayName(date);
                final isHoliday = holiday != null;
                final isSunday = colIndex == 0;
                final isSaturday = colIndex == 6;
                final events = isCurrentMonth ? _getEventsForDay(date, allEvents) : <CalendarEvent>[];

                // 날짜 숫자 색상
                Color dayColor;
                if (!isCurrentMonth) {
                  dayColor = cs.onSurface.withValues(alpha: 0.25);
                } else if (isHoliday || isSunday) {
                  dayColor = Colors.red;
                } else if (isSaturday) {
                  dayColor = Colors.blue;
                } else {
                  dayColor = cs.onSurface;
                }

                return TableCell(
                  child: InkWell(
                    onTap: isCurrentMonth ? () => _showDayPopup(context, date, allEvents) : null,
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.fromLTRB(4, 3, 4, 2),
                      color: isToday ? cs.primary.withValues(alpha: 0.05) : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 날짜 숫자
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // 공휴일 이름 (좌측)
                              if (isCurrentMonth && isHoliday) ...[
                                Expanded(
                                  child: Text(
                                    holiday,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else
                                const Spacer(),
                              // 날짜 숫자 (우측)
                              if (isToday)
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: dayColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          // 이벤트 태그 (최대 2개)
                          ...events.take(2).map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _EventTag(event: e),
                            ),
                          )),
                          // 더보기 표시
                          if (events.length > 2)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '+${events.length - 2}건 더보기',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: cs.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
          ],
        ),
      ],
      ),
    );
  }

  Future<void> _showDayPopup(BuildContext context, DateTime day, List<CalendarEvent> allEvents) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _DayEventsPopup(day: day),
    );
    if (result == true) {
      ref.invalidate(calendarEventsProvider);
    }
  }
}

/// 이벤트 태그 (ECOUNT 스타일: 색상뱃지 + 텍스트)
class _EventTag extends StatelessWidget {
  const _EventTag({required this.event});
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: event.displayColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            event.category.isNotEmpty ? event.category : '일정',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            event.title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.3,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

// ── 날짜 클릭 팝업: 일정 목록 + 추가 ──
class _DayEventsPopup extends ConsumerStatefulWidget {
  const _DayEventsPopup({required this.day});
  final DateTime day;

  @override
  ConsumerState<_DayEventsPopup> createState() => _DayEventsPopupState();
}

class _DayEventsPopupState extends ConsumerState<_DayEventsPopup> {
  bool _changed = false;

  List<CalendarEvent> get _events {
    final all = ref.watch(calendarEventsProvider).valueOrNull ?? [];
    return all.where((e) =>
      e.eventDate.year == widget.day.year &&
      e.eventDate.month == widget.day.month &&
      e.eventDate.day == widget.day.day,
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final events = _events;
    final holiday = KoreanHolidays.getHolidayName(widget.day);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 바 (ECOUNT 스타일 인디고)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.indigo,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('yyyy년 M월 d일 (E)', 'ko').format(widget.day),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (holiday != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(holiday, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context, _changed),
                    child: const Icon(Icons.close, size: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // 내용
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 추가 버튼
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => _addEvent(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('일정 추가', style: TextStyle(fontSize: 13)),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 일정 목록
                    if (events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.event_available, size: 40, color: cs.onSurface.withValues(alpha: 0.15)),
                            const SizedBox(height: 8),
                            Text(
                              '등록된 일정이 없습니다',
                              style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.4)),
                            ),
                          ],
                        ),
                      )
                    else
                      ...events.map((event) => _buildEventRow(context, event)),
                  ],
                ),
              ),
            ),
            // 하단
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, _changed),
                    child: const Text('닫기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(BuildContext context, CalendarEvent event) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // 카테고리 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: event.displayColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.category.isNotEmpty ? event.category : '일정',
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.description!,
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () => _editEvent(context, event),
              icon: Icon(Icons.edit_outlined, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: '수정',
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _deleteEvent(event),
              icon: Icon(Icons.delete_outline, size: 16, color: Colors.red.withValues(alpha: 0.5)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: '삭제',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEvent(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _EventFormDialog(date: widget.day),
    );
    if (result == true) {
      _changed = true;
      ref.invalidate(calendarEventsProvider);
    }
  }

  Future<void> _editEvent(BuildContext context, CalendarEvent event) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _EventFormDialog(date: widget.day, event: event),
    );
    if (result == true) {
      _changed = true;
      ref.invalidate(calendarEventsProvider);
    }
  }

  Future<void> _deleteEvent(CalendarEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 삭제', style: TextStyle(fontSize: 16)),
        content: Text('"${event.title}" 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(calendarRepositoryProvider).deleteEvent(event.id);
      _changed = true;
      ref.invalidate(calendarEventsProvider);
    }
  }
}

// ── ECOUNT 스타일 일정등록 팝업 다이얼로그 ──
class _EventFormDialog extends ConsumerStatefulWidget {
  const _EventFormDialog({required this.date, this.event});
  final DateTime date;
  final CalendarEvent? event;

  @override
  ConsumerState<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends ConsumerState<_EventFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _memoController;
  String _category = '일정';
  String _selectedColor = '#3F51B5';
  bool _isSaving = false;

  static const _categories = ['일정', '회의', '연차', '출장', '교육', '기타'];

  static const _colorMap = {
    '일정': '#3F51B5',
    '회의': '#F44336',
    '연차': '#FF9800',
    '출장': '#4CAF50',
    '교육': '#9C27B0',
    '기타': '#607D8B',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _memoController = TextEditingController(text: widget.event?.description ?? '');
    _category = widget.event?.category ?? '일정';
    _selectedColor = widget.event?.color ?? _colorMap[_category] ?? '#3F51B5';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력하세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(calendarRepositoryProvider);
      if (widget.event != null) {
        await repo.updateEvent(
          id: widget.event!.id,
          title: _titleController.text.trim(),
          eventDate: widget.date,
          description: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
          color: _selectedColor,
          category: _category,
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        );
      } else {
        await repo.addEvent(
          title: _titleController.text.trim(),
          eventDate: widget.date,
          description: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
          color: _selectedColor,
          category: _category,
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.event != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 바 (ECOUNT 스타일)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.indigo,
              child: Row(
                children: [
                  Text(
                    isEdit ? '일정 수정' : '일정관리등록',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context, false),
                    child: const Icon(Icons.close, size: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 폼 본문
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 제목
                    _buildFormRow('제목', TextField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '제목을 입력하세요',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                      ),
                    )),
                    const SizedBox(height: 14),

                    // 일정구분 + 날짜
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 일정구분
                        Expanded(
                          child: _buildFormRow('일정구분', DropdownButtonFormField<String>(
                            value: _category,
                            isDense: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                            ),
                            items: _categories.map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: const TextStyle(fontSize: 14)),
                            )).toList(),
                            onChanged: (v) {
                              setState(() {
                                _category = v ?? '일정';
                                _selectedColor = _colorMap[_category] ?? '#3F51B5';
                              });
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        // 날짜
                        Expanded(
                          child: _buildFormRow('날짜', Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: cs.outlineVariant),
                              borderRadius: BorderRadius.circular(4),
                              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                            ),
                            child: Text(
                              DateFormat('yyyy / MM / dd (E)', 'ko').format(widget.date),
                              style: TextStyle(fontSize: 14, color: cs.onSurface),
                            ),
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 장소
                    _buildFormRow('장소', TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: '장소',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                      ),
                    )),
                    const SizedBox(height: 14),

                    // 메모
                    _buildFormRow('메모', TextField(
                      controller: _memoController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '메모를 입력하세요',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? '수정' : '저장', style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: const Text('닫기', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 라벨 + 입력 폼 행 (ECOUNT 스타일)
  Widget _buildFormRow(String label, Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
