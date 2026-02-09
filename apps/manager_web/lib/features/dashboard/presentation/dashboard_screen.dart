import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/permissions.dart';
import '../../../core/widgets/sticky_data_table.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
    required this.role,
    required this.userSiteId,
    this.onWorkerTap,
  });

  final AppRole role;
  final String userSiteId;
  final void Function(String name)? onWorkerTap;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedCenter;
  String _searchQuery = '';
  String? _selectedStatus;
  int? _sortColumnIndex;
  bool _isAscending = true;

  // 센터 목록 (전체, 서이천, 안성, 의왕, 부평)
  static const _allCenters = ['전체', '서이천', '안성', '의왕', '부평'];

  // siteId → 센터명 매핑 (데모용)
  String _getSiteName(String siteId) {
    return switch (siteId) {
      'site-seoicheon' => '서이천',
      'site-anseong' => '안성',
      'site-uiwang' => '의왕',
      'site-bupyeong' => '부평',
      'demo-site-id' => '서이천', // 데모 센터장용
      _ => '서이천',
    };
  }

  List<String> get _availableCenters {
    if (canAccessAllSites(widget.role)) {
      return _allCenters;
    } else {
      // 센터장은 본인 센터만
      final mySite = _getSiteName(widget.userSiteId);
      return [mySite];
    }
  }

  @override
  void initState() {
    super.initState();
    // 센터장은 자기 센터로 초기화, 그 외는 '전체'
    if (canAccessAllSites(widget.role)) {
      _selectedCenter = '전체';
    } else {
      _selectedCenter = _getSiteName(widget.userSiteId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(dashboardSummaryProvider);
    final attendances = ref.watch(todayAttendancesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 상단 고정 영역 (스크롤 안 됨) ──
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - 날짜 + 필터 Chip
              Row(
                children: [
                  Text(
                    DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(DateTime.now()),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  if (_selectedStatus != null) ...[
                    const SizedBox(width: 16),
                    Chip(
                      label: Text('필터: $_selectedStatus', style: const TextStyle(fontSize: 13)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() => _selectedStatus = null),
                      backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                      side: BorderSide(color: Colors.indigo.withValues(alpha: 0.3)),
                    ),
                  ],
                ],
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
              const SizedBox(height: 24),

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
                ],
              ),
              const SizedBox(height: 16),

              // 테이블 헤더
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
            ],
          ),
        ),

        // ── 하단: 테이블 (남은 공간 전체 사용, 헤더 고정) ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
            child: attendances.when(
              data: (rows) {
                var filtered = rows.where((r) {
                  final centerMatch = _selectedCenter == '전체' || r.site == _selectedCenter;
                  final searchMatch = r.name.contains(_searchQuery) || r.site.contains(_searchQuery);
                  return centerMatch && searchMatch;
                }).toList();

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

                if (_sortColumnIndex != null) {
                  filtered.sort((a, b) {
                    int compare;
                    switch (_sortColumnIndex) {
                      case 0: compare = 0; break;
                      case 1: compare = a.site.compareTo(b.site); break;
                      case 2: compare = a.name.compareTo(b.name); break;
                      case 3: compare = a.position.compareTo(b.position); break;
                      case 4: compare = a.job.compareTo(b.job); break;
                      case 5: compare = a.checkIn.compareTo(b.checkIn); break;
                      case 6: compare = a.checkOut.compareTo(b.checkOut); break;
                      case 7: compare = a.workHours.compareTo(b.workHours); break;
                      case 8: compare = a.status.compareTo(b.status); break;
                      case 9: compare = a.note.compareTo(b.note); break;
                      default: compare = 0;
                    }
                    return _isAscending ? compare : -compare;
                  });
                }

                void onSort(int colIndex) {
                  setState(() {
                    if (_sortColumnIndex == colIndex) {
                      _isAscending = !_isAscending;
                    } else {
                      _sortColumnIndex = colIndex;
                      _isAscending = true;
                    }
                  });
                }

                final columns = [
                  TableColumnDef(label: 'No.', width: 55, onSort: () => onSort(0), sortAscending: _sortColumnIndex == 0 ? _isAscending : null),
                  TableColumnDef(label: '사업장', width: 85, onSort: () => onSort(1), sortAscending: _sortColumnIndex == 1 ? _isAscending : null),
                  TableColumnDef(label: '성명', width: 85, onSort: () => onSort(2), sortAscending: _sortColumnIndex == 2 ? _isAscending : null),
                  TableColumnDef(label: '직위', width: 75, onSort: () => onSort(3), sortAscending: _sortColumnIndex == 3 ? _isAscending : null),
                  TableColumnDef(label: '직무', width: 110, onSort: () => onSort(4), sortAscending: _sortColumnIndex == 4 ? _isAscending : null),
                  TableColumnDef(label: '출근', width: 75, onSort: () => onSort(5), sortAscending: _sortColumnIndex == 5 ? _isAscending : null),
                  TableColumnDef(label: '퇴근', width: 75, onSort: () => onSort(6), sortAscending: _sortColumnIndex == 6 ? _isAscending : null),
                  TableColumnDef(label: '근무시간', width: 90, onSort: () => onSort(7), sortAscending: _sortColumnIndex == 7 ? _isAscending : null),
                  TableColumnDef(label: '상태', width: 80, onSort: () => onSort(8), sortAscending: _sortColumnIndex == 8 ? _isAscending : null),
                  TableColumnDef(label: '비고', width: 130, onSort: () => onSort(9), sortAscending: _sortColumnIndex == 9 ? _isAscending : null),
                ];

                return StickyHeaderTable.wrapWithCard(
                  columns: columns,
                  rowCount: filtered.length,
                  emptyMessage: '해당하는 데이터가 없습니다.',
                  cellBuilder: (colIndex, rowIndex) {
                    final e = filtered[rowIndex];
                    return switch (colIndex) {
                      0 => Text('${rowIndex + 1}', style: const TextStyle(fontSize: 13)),
                      1 => Text(e.site, style: const TextStyle(fontSize: 13)),
                      2 => widget.onWorkerTap != null
                          ? GestureDetector(
                              onTap: () => widget.onWorkerTap!(e.name),
                              child: Text(e.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo, decoration: TextDecoration.underline)),
                            )
                          : Text(e.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      3 => Text(e.position, style: const TextStyle(fontSize: 13)),
                      4 => Text(e.job, style: const TextStyle(fontSize: 13)),
                      5 => Text(e.checkIn, style: const TextStyle(fontSize: 13)),
                      6 => Text(e.checkOut, style: const TextStyle(fontSize: 13)),
                      7 => Text(e.workHours, style: const TextStyle(fontSize: 13)),
                      8 => _buildStatusBadge(e.status),
                      9 => Text(e.note, style: const TextStyle(fontSize: 13)),
                      _ => const SizedBox(),
                    };
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('오류: $e'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, String? filterValue) {
    final isSelected = _selectedStatus == filterValue;

    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedStatus == filterValue) {
            _selectedStatus = null;
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCenterDropdown() {
    final centers = _availableCenters;

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
          items: centers
              .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: centers.length > 1 ? (v) => setState(() => _selectedCenter = v!) : null,
        ),
      ),
    );
  }
}
