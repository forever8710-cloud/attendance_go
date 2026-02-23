import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ────────────────────────────────────────────────────────────
// 1. 모던 날짜 범위 선택 다이얼로그
// ────────────────────────────────────────────────────────────

/// 모던 스타일의 날짜 범위 선택 다이얼로그를 표시합니다.
Future<DateTimeRange?> showModernDateRangePicker({
  required BuildContext context,
  required DateTimeRange initialRange,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (ctx) => _ModernDateRangeDialog(
      initialRange: initialRange,
      firstDate: firstDate ?? DateTime(2024),
      lastDate: lastDate ?? DateTime.now(),
    ),
  );
}

class _ModernDateRangeDialog extends StatefulWidget {
  const _ModernDateRangeDialog({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTimeRange initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_ModernDateRangeDialog> createState() => _ModernDateRangeDialogState();
}

class _ModernDateRangeDialogState extends State<_ModernDateRangeDialog> {
  late DateTime _focusMonth;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange.start;
    _end = widget.initialRange.end;
    _focusMonth = DateTime(_start!.year, _start!.month);
  }

  void _selectPreset(DateTime start, DateTime end) {
    setState(() {
      _start = start;
      _end = end;
      _focusMonth = DateTime(start.year, start.month);
    });
  }

  void _onDayTap(DateTime day) {
    setState(() {
      if (_start == null || _end != null) {
        _start = day;
        _end = null;
      } else {
        if (day.isBefore(_start!)) {
          _end = _start;
          _start = day;
        } else {
          _end = day;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 헤더 ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8D99AE),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('날짜 범위 선택', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _start != null && _end != null
                        ? '${DateFormat('yyyy.MM.dd').format(_start!)} ~ ${DateFormat('yyyy.MM.dd').format(_end!)}'
                        : _start != null
                            ? '${DateFormat('yyyy.MM.dd').format(_start!)} ~ 종료일 선택'
                            : '시작일을 선택하세요',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ── 프리셋 버튼 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _presetChip('오늘', today, today),
                  _presetChip('어제', today.subtract(const Duration(days: 1)), today.subtract(const Duration(days: 1))),
                  _presetChip('최근 7일', today.subtract(const Duration(days: 6)), today),
                  _presetChip('이번 주', _startOfWeek(today), today),
                  _presetChip('이번 달', DateTime(today.year, today.month), today),
                  _presetChip('지난 달', DateTime(today.year, today.month - 1), DateTime(today.year, today.month, 0)),
                ],
              ),
            ),

            const Divider(height: 16),

            // ── 월 네비게이션 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 1);
                    }),
                    icon: const Icon(Icons.chevron_left, size: 22),
                    splashRadius: 18,
                  ),
                  Text(
                    DateFormat('yyyy년 M월').format(_focusMonth),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {
                      final next = DateTime(_focusMonth.year, _focusMonth.month + 1);
                      if (!next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month + 1))) {
                        setState(() => _focusMonth = next);
                      }
                    },
                    icon: const Icon(Icons.chevron_right, size: 22),
                    splashRadius: 18,
                  ),
                ],
              ),
            ),

            // ── 요일 헤더 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['일', '월', '화', '수', '목', '금', '토'].map((d) {
                  final color = d == '일' ? Colors.red[400] : d == '토' ? Colors.blue[400] : cs.onSurface.withValues(alpha: 0.5);
                  return Expanded(
                    child: Center(child: Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),

            // ── 달력 그리드 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildCalendarGrid(cs, today),
            ),

            const SizedBox(height: 8),

            // ── 하단 액션 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _start != null && _end != null
                        ? () => Navigator.pop(context, DateTimeRange(start: _start!, end: _end!))
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8D99AE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('적용'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(String label, DateTime start, DateTime end) {
    final isSelected = _start != null &&
        _end != null &&
        _start!.year == start.year &&
        _start!.month == start.month &&
        _start!.day == start.day &&
        _end!.year == end.year &&
        _end!.month == end.month &&
        _end!.day == end.day;

    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : const Color(0xFF2B2D42))),
      backgroundColor: isSelected ? const Color(0xFF8D99AE) : const Color(0xFFF8F9FA),
      side: BorderSide(color: isSelected ? const Color(0xFF8D99AE) : const Color(0xFFD1D5DE)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => _selectPreset(start, end),
    );
  }

  Widget _buildCalendarGrid(ColorScheme cs, DateTime today) {
    final firstDayOfMonth = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusMonth.year, _focusMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7; // 0=Sun

    final days = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (int d = 1; d <= lastDayOfMonth.day; d++) {
      days.add(DateTime(_focusMonth.year, _focusMonth.month, d));
    }
    while (days.length % 7 != 0) {
      days.add(null);
    }

    final rows = <Widget>[];
    for (int i = 0; i < days.length; i += 7) {
      rows.add(Row(
        children: List.generate(7, (j) {
          final day = days[i + j];
          if (day == null) return const Expanded(child: SizedBox(height: 38));
          return Expanded(child: _buildDayCell(day, today, j));
        }),
      ));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime day, DateTime today, int weekdayIndex) {
    final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
    final isDisabled = day.isAfter(widget.lastDate) || day.isBefore(widget.firstDate);

    final isStart = _start != null && day.year == _start!.year && day.month == _start!.month && day.day == _start!.day;
    final isEnd = _end != null && day.year == _end!.year && day.month == _end!.month && day.day == _end!.day;
    final isInRange = _start != null &&
        _end != null &&
        day.isAfter(_start!.subtract(const Duration(days: 1))) &&
        day.isBefore(_end!.add(const Duration(days: 1)));
    final isEdge = isStart || isEnd;

    Color? bgColor;
    Color textColor;
    FontWeight fontWeight = FontWeight.normal;

    if (isEdge) {
      bgColor = const Color(0xFF8D99AE);
      textColor = Colors.white;
      fontWeight = FontWeight.w600;
    } else if (isInRange) {
      bgColor = const Color(0xFFF8F9FA);
      textColor = const Color(0xFF2B2D42);
    } else if (isToday) {
      textColor = const Color(0xFF2B2D42);
      fontWeight = FontWeight.w700;
    } else if (isDisabled) {
      textColor = Colors.grey[350]!;
    } else if (weekdayIndex == 0) {
      textColor = Colors.red[400]!;
    } else if (weekdayIndex == 6) {
      textColor = Colors.blue[400]!;
    } else {
      textColor = Colors.grey[800]!;
    }

    // 범위 배경 (좌우 연결)
    BoxDecoration? rangeBg;
    if (isInRange && !isEdge) {
      rangeBg = BoxDecoration(color: const Color(0xFFF8F9FA));
    } else if (isStart && _end != null) {
      rangeBg = BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent, const Color(0xFFF8F9FA)], begin: Alignment.centerLeft, end: Alignment.centerRight),
      );
    } else if (isEnd && _start != null) {
      rangeBg = BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFF8F9FA), Colors.transparent], begin: Alignment.centerLeft, end: Alignment.centerRight),
      );
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _onDayTap(day),
      child: Container(
        height: 38,
        decoration: rangeBg,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: isToday && !isEdge ? Border.all(color: const Color(0xFFB0B8C8), width: 1.5) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(fontSize: 13, fontWeight: fontWeight, color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday % 7; // 0=Sun
    return date.subtract(Duration(days: weekday));
  }
}

// ────────────────────────────────────────────────────────────
// 2. 모던 단일 날짜 선택 다이얼로그
// ────────────────────────────────────────────────────────────

/// 모던 스타일의 단일 날짜 선택 다이얼로그를 표시합니다.
Future<DateTime?> showModernDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = '날짜 선택',
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => _ModernDateDialog(
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1990),
      lastDate: lastDate ?? DateTime(2100),
      title: title,
    ),
  );
}

class _ModernDateDialog extends StatefulWidget {
  const _ModernDateDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  @override
  State<_ModernDateDialog> createState() => _ModernDateDialogState();
}

class _ModernDateDialogState extends State<_ModernDateDialog> {
  late DateTime _focusMonth;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _focusMonth = DateTime(_selected!.year, _selected!.month);
  }

  void _onDayTap(DateTime day) {
    setState(() => _selected = day);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 헤더 ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8D99AE),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (_selected != null)
                    Text(
                      DateFormat('yyyy.MM.dd').format(_selected!),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    splashRadius: 18,
                  ),
                ],
              ),
            ),

            // ── 월 네비게이션 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 1);
                    }),
                    icon: const Icon(Icons.chevron_left, size: 22),
                    splashRadius: 18,
                  ),
                  Text(
                    DateFormat('yyyy년 M월').format(_focusMonth),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + 1);
                    }),
                    icon: const Icon(Icons.chevron_right, size: 22),
                    splashRadius: 18,
                  ),
                ],
              ),
            ),

            // ── 요일 헤더 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['일', '월', '화', '수', '목', '금', '토'].map((d) {
                  final color = d == '일' ? Colors.red[400] : d == '토' ? Colors.blue[400] : cs.onSurface.withValues(alpha: 0.5);
                  return Expanded(
                    child: Center(child: Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),

            // ── 달력 그리드 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildCalendarGrid(cs, today),
            ),

            const SizedBox(height: 8),

            // ── 하단 액션 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _selected != null ? () => Navigator.pop(context, _selected) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8D99AE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(ColorScheme cs, DateTime today) {
    final firstDayOfMonth = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusMonth.year, _focusMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7;

    final days = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (int d = 1; d <= lastDayOfMonth.day; d++) {
      days.add(DateTime(_focusMonth.year, _focusMonth.month, d));
    }
    while (days.length % 7 != 0) {
      days.add(null);
    }

    final rows = <Widget>[];
    for (int i = 0; i < days.length; i += 7) {
      rows.add(Row(
        children: List.generate(7, (j) {
          final day = days[i + j];
          if (day == null) return const Expanded(child: SizedBox(height: 38));
          return Expanded(child: _buildDayCell(day, today, j));
        }),
      ));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime day, DateTime today, int weekdayIndex) {
    final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
    final isDisabled = day.isAfter(widget.lastDate) || day.isBefore(widget.firstDate);
    final isSelected = _selected != null && day.year == _selected!.year && day.month == _selected!.month && day.day == _selected!.day;

    Color? bgColor;
    Color textColor;
    FontWeight fontWeight = FontWeight.normal;

    if (isSelected) {
      bgColor = const Color(0xFF8D99AE);
      textColor = Colors.white;
      fontWeight = FontWeight.w600;
    } else if (isToday) {
      textColor = const Color(0xFF2B2D42);
      fontWeight = FontWeight.w700;
    } else if (isDisabled) {
      textColor = Colors.grey[350]!;
    } else if (weekdayIndex == 0) {
      textColor = Colors.red[400]!;
    } else if (weekdayIndex == 6) {
      textColor = Colors.blue[400]!;
    } else {
      textColor = Colors.grey[800]!;
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _onDayTap(day),
      child: SizedBox(
        height: 38,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: isToday && !isSelected ? Border.all(color: const Color(0xFFB0B8C8), width: 1.5) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(fontSize: 13, fontWeight: fontWeight, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
