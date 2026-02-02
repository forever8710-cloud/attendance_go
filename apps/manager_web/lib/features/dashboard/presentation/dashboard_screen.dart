import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCenter = '전체';
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(dashboardSummaryProvider);
    final attendances = ref.watch(todayAttendancesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('대시보드', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(DateTime.now()),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => ref.invalidate(dashboardSummaryProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('새로고침'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary cards
          summary.when(
            data: (s) => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSummaryCard('전체 직원', '${s.totalWorkers}명', Icons.people, Colors.blue),
                _buildSummaryCard('오늘 출근', '${s.checkedIn}명', Icons.login, Colors.green),
                _buildSummaryCard('퇴근 완료', '${s.checkedOut}명', Icons.logout, Colors.indigo),
                _buildSummaryCard('지각', '${s.late}명', Icons.warning, Colors.orange),
                _buildSummaryCard('미출근', '${s.absent}명', Icons.person_off, Colors.red),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('오류: $e'),
          ),
          const SizedBox(height: 32),

          // Toolbar
          Row(
            children: [
              _buildCenterDropdown(),
              const SizedBox(width: 12),
              SizedBox(
                width: 250,
                height: 40,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: '이름/사업장 검색...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text('엑셀 저장'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Table
          const Text('▶ 오늘의 출퇴근 현황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 12),
          attendances.when(
            data: (rows) {
              final filtered = rows.where((r) =>
                (r.name.contains(_searchQuery) || r.site.contains(_searchQuery)) &&
                (_selectedCenter == '전체' || r.site == _selectedCenter),
              ).toList();

              return Align(
                alignment: Alignment.centerLeft,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _isAscending,
                      columnSpacing: 28,
                      columns: [
                        DataColumn(label: const Text('No.'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        const DataColumn(label: Text('사업장')),
                        const DataColumn(label: Text('성명')),
                        const DataColumn(label: Text('파트')),
                        DataColumn(label: const Text('출근'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('퇴근'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        const DataColumn(label: Text('근무시간')),
                        const DataColumn(label: Text('상태')),
                        const DataColumn(label: Text('비고')),
                      ],
                      rows: filtered.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        return DataRow(cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(e.site)),
                          DataCell(Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(e.part)),
                          DataCell(Text(e.checkIn)),
                          DataCell(Text(e.checkOut)),
                          DataCell(Text(e.workHours)),
                          DataCell(_buildStatusBadge(e.status)),
                          DataCell(Text(e.note)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('오류: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = switch (status) {
      '지각' => Colors.red,
      '출근' => Colors.green,
      '미출근' => Colors.grey,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCenterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCenter,
          items: ['전체', '서이천', '의왕', '부평', '남사']
              .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (v) => setState(() => _selectedCenter = v!),
        ),
      ),
    );
  }
}
