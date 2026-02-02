import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'present' => Colors.green,
      'absent' => Colors.red,
      'leave' => Colors.orange,
      'holiday' => Colors.blue,
      _ => Colors.grey,
    };

    final label = switch (status) {
      'present' => '출근',
      'absent' => '미출근',
      'leave' => '휴가',
      'holiday' => '공휴일',
      _ => status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
