import 'package:flutter/material.dart';
import '../../data/attendance_records_repository.dart';

class AttendanceDeleteDialog extends StatelessWidget {
  const AttendanceDeleteDialog({super.key, required this.record});

  final AttendanceRecordRow record;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.delete_outline, color: Colors.red, size: 22),
          SizedBox(width: 8),
          Text('근태 삭제'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('다음 근태 기록을 삭제하시겠습니까?'),
          const SizedBox(height: 16),
          Text('${record.workerName} / ${record.checkInTime} ~ ${record.checkOutTime}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '삭제된 기록은 복구할 수 없습니다.',
            style: TextStyle(color: Colors.red[700], fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제'),
        ),
      ],
    );
  }
}
