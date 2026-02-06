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
  String? _selectedStatus; // 상태 필터 (null = 전체)
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
          // Header - 날짜만 크게 표시
          Text(
            DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(DateTime.now()),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),

          // Summary cards (클릭 가능)
          summary.when(
            data: (s) => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSummaryCard('전체 직원', '${s.totalWorkers}명', Icons.people, Colors.blue, null),
                _buildSummaryCard('오늘 출근', '${s.checkedIn}명', Icons.login, Colors.green, '출근'),
                _buildSummaryCard('퇴근 완료', '${s.checkedOut}명', Icons.logout, Colors.indigo, '퇴근'),
                _buildSummaryCard('지각', '${s.late}명', Icons.warning, Colors.orange, '지각'),
                _buildSummaryCard('조퇴', '${s.earlyLeave ?? 0}명', Icons.exit_to_app, Colors.purple, '조퇴'),
                _buildSummaryCard('미출근', '${s.absent}명', Icons.person_off, Colors.red, '미출근'),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('오류: $e'),
          ),
          const SizedBox(height: 32),

          // Toolbar (엑셀저장 버튼 제거)
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
              // 현재 필터 상태 표시
              if (_selectedStatus != null)
                Chip(
                  label: Text('필터: $_selectedStatus'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _selectedStatus = null),
                  backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Table
          Row(
            children: [
              const Text('▶ 오늘의 출퇴근 현황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              if (_selectedStatus != null) ...[
                const SizedBox(width: 8),
                Text('($_selectedStatus)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ],
          ),
          const SizedBox(height: 12),
          attendances.when(
            data: (rows) {
              var filtered = rows.where((r) =>
                (r.name.contains(_searchQuery) || r.site.contains(_searchQuery)) &&
                (_selectedCenter == '전체' || r.site == _selectedCenter),
              ).toList();

              // 상태 필터 적용
              if (_selectedStatus != null) {
                filtered = filtered.where((r) {
                  switch (_selectedStatus) {
                    case '출근':
                      return r.status == '출근' && r.checkOut == '-';
                    case '퇴근':
                      return r.checkOut != '-';
                    case '지각':
                      return r.status == '지각';
                    case '조퇴':
                      return r.note.contains('조퇴') || r.status == '조퇴';
                    case '미출근':
                      return r.status == '미출근';
                    default:
                      return true;
                  }
                }).toList();
              }

              // 정렬 적용
              if (_sortColumnIndex != null) {
                filtered.sort((a, b) {
                  int compare;
                  switch (_sortColumnIndex) {
                    case 0: // No. (인덱스 기준이라 의미 없음)
                      compare = 0;
                      break;
                    case 1: // 사업장
                      compare = a.site.compareTo(b.site);
                      break;
                    case 2: // 성명
                      compare = a.name.compareTo(b.name);
                      break;
                    case 3: // 직위
                      compare = a.position.compareTo(b.position);
                      break;
                    case 4: // 직무
                      compare = a.job.compareTo(b.job);
                      break;
                    case 5: // 출근
                      compare = a.checkIn.compareTo(b.checkIn);
                      break;
                    case 6: // 퇴근
                      compare = a.checkOut.compareTo(b.checkOut);
                      break;
                    case 7: // 근무시간
                      compare = a.workHours.compareTo(b.workHours);
                      break;
                    case 8: // 상태
                      compare = a.status.compareTo(b.status);
                      break;
                    case 9: // 비고
                      compare = a.note.compareTo(b.note);
                      break;
                    default:
                      compare = 0;
                  }
                  return _isAscending ? compare : -compare;
                });
              }

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
                        DataColumn(label: const Text('사업장'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('성명'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('직위'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('직무'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('출근'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('퇴근'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('근무시간'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('상태'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                        DataColumn(label: const Text('비고'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _isAscending = asc; })),
                      ],
                      rows: filtered.isEmpty
                          ? [
                              const DataRow(cells: [
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('해당하는 데이터가 없습니다.', style: TextStyle(color: Colors.grey))),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ]),
                            ]
                          : filtered.asMap().entries.map((entry) {
                              final i = entry.key;
                              final e = entry.value;
                              return DataRow(cells: [
                                DataCell(Text('${i + 1}')),
                                DataCell(Text(e.site)),
                                DataCell(Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(e.position)),
                                DataCell(Text(e.job)),
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, String? filterValue) {
    final isSelected = _selectedStatus == filterValue;

    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedStatus == filterValue) {
            _selectedStatus = null; // 같은 카드 다시 클릭하면 필터 해제
          } else {
            _selectedStatus = filterValue;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(Icons.filter_alt, color: color, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? color : null)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = switch (status) {
      '지각' => Colors.orange,
      '출근' => Colors.green,
      '퇴근' => Colors.indigo,
      '조퇴' => Colors.purple,
      '미출근' => Colors.red,
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
