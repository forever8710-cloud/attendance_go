import 'package:flutter/material.dart';
import '../../data/attendance_records_repository.dart';

class AttendanceEditDialog extends StatefulWidget {
  const AttendanceEditDialog({super.key, required this.record});

  final AttendanceRecordRow record;

  @override
  State<AttendanceEditDialog> createState() => _AttendanceEditDialogState();
}

class _AttendanceEditDialogState extends State<AttendanceEditDialog> {
  late TimeOfDay _checkInTime;
  late TimeOfDay _checkOutTime;
  bool _hasCheckOut = false;
  late String _status;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    // 출근시간 파싱
    final ciParts = widget.record.checkInTime.split(':');
    _checkInTime = TimeOfDay(hour: int.parse(ciParts[0]), minute: int.parse(ciParts[1]));

    // 퇴근시간 파싱
    if (widget.record.checkOutTime != '-') {
      final coParts = widget.record.checkOutTime.split(':');
      _checkOutTime = TimeOfDay(hour: int.parse(coParts[0]), minute: int.parse(coParts[1]));
      _hasCheckOut = true;
    } else {
      _checkOutTime = const TimeOfDay(hour: 18, minute: 0);
      _hasCheckOut = false;
    }

    _status = widget.record.status;
    _notesController = TextEditingController(text: widget.record.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: cs.primary, size: 22),
          const SizedBox(width: 8),
          const Text('근태 수정'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.record.workerName} (${widget.record.job})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 출근시간
            _buildTimePicker('출근 시간', _checkInTime, (t) => setState(() => _checkInTime = t)),
            const SizedBox(height: 12),

            // 퇴근시간
            Row(
              children: [
                Checkbox(
                  value: _hasCheckOut,
                  onChanged: (v) => setState(() => _hasCheckOut = v!),
                ),
                const Text('퇴근 기록'),
              ],
            ),
            if (_hasCheckOut)
              _buildTimePicker('퇴근 시간', _checkOutTime, (t) => setState(() => _checkOutTime = t)),
            const SizedBox(height: 12),

            // 상태 드롭다운
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: '상태',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: ['출근', '지각', '조퇴', '미출근']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),

            // 비고
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '비고',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            final date = widget.record.date;
            final checkIn = DateTime(date.year, date.month, date.day, _checkInTime.hour, _checkInTime.minute);
            DateTime? checkOut;
            if (_hasCheckOut) {
              checkOut = DateTime(date.year, date.month, date.day, _checkOutTime.hour, _checkOutTime.minute);
            }

            // DB status 매핑
            final dbStatus = switch (_status) {
              '조퇴' => 'leave',
              '지각' => 'late',
              '미출근' => 'absent',
              _ => 'present',
            };

            Navigator.pop(context, {
              'checkInTime': checkIn,
              'checkOutTime': checkOut,
              'status': dbStatus,
              'notes': _notesController.text,
            });
          },
          child: const Text('저장'),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, ValueChanged<TimeOfDay> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
            const Icon(Icons.access_time, size: 18),
          ],
        ),
      ),
    );
  }
}
