import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/company_constants.dart';
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
  final void Function(String id, String name)? onWorkerTap;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedCenter;
  String _searchQuery = '';
  String? _selectedStatus;
  int? _sortColumnIndex;
  bool _isAscending = true;
  bool _showManagerOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCenter = canAccessAllSites(widget.role) ? '전체' : null;
  }

  List<String> _getAvailableCenters(List<Map<String, String>> sites) {
    if (canAccessAllSites(widget.role)) {
      return ['전체', ...sites.map((s) => s['name']!)];
    } else {
      // 센터장은 자기 센터만 — attendances에서 site 매칭으로 표시
      final mySiteName = sites
          .where((s) => s['id'] == widget.userSiteId)
          .map((s) => s['name']!)
          .firstOrNull;
      return [mySiteName ?? ''];
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(dashboardSummaryProvider);
    final attendances = ref.watch(todayAttendancesProvider);
    final sitesAsync = ref.watch(sitesProvider);

    // 사이트 로드 후 센터장 초기화
    final sites = sitesAsync.valueOrNull ?? [];
    if (_selectedCenter == null && sites.isNotEmpty && !canAccessAllSites(widget.role)) {
      final mySiteName = sites
          .where((s) => s['id'] == widget.userSiteId)
          .map((s) => s['name']!)
          .firstOrNull;
      if (mySiteName != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedCenter = mySiteName);
        });
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final topContent = Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards (클릭 가능)
              summary.when(
                data: (s) => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildSummaryCard('전체 직원', '${s.totalWorkers}명', Icons.people, Colors.blue, null),
                    _buildSummaryCard('주간출근', '${s.dayCheckedIn}명', Icons.wb_sunny, Colors.green, '주간출근'),
                    _buildSummaryCard('야간출근', '${s.nightCheckedIn}명', Icons.nightlight_round, Colors.deepPurple, '야간출근'),
                    _buildSummaryCard('퇴근 완료', '${s.checkedOut}명', Icons.logout, const Color(0xFF8D99AE), '퇴근'),
                    _buildSummaryCard('지각', '${s.late}명', Icons.warning, Colors.orange, '지각'),
                    _buildSummaryCard('조퇴', '${s.earlyLeave ?? 0}명', Icons.exit_to_app, Colors.purple, '조퇴'),
                    _buildSummaryCard('미출근', '${s.absent}명', Icons.person_off, Colors.red, '미출근'),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('오류: $e'),
              ),
              const SizedBox(height: 20),

              // 테이블 헤더 + 필터/검색
              Row(
                children: [
                  const Text('▶ 오늘의 출퇴근 현황', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B2D42))),
                  const SizedBox(width: 24),
                  _buildCenterDropdown(),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 200,
                    height: 36,
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: '이름/사업장 검색...',
                        prefixIcon: const Icon(Icons.search, size: 16),
                        filled: false,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF8D99AE), width: 1.5),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (_selectedStatus != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFBDBDBD)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('필터: $_selectedStatus', style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => setState(() => _selectedStatus = null),
                            borderRadius: BorderRadius.circular(10),
                            child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // 센터장 필터 버튼 (system_admin / owner만)
                  if (canAccessAllSites(widget.role)) ...[
                    const SizedBox(width: 12),
                    _buildManagerFilterButton(),
                  ],
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );

        // ── 하단: 테이블 ──
        final tableContent = Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
            child: attendances.when(
              data: (rows) {
                var filtered = rows.where((r) {
                  // 센터장 필터: 토글 ON이면 센터장만, OFF이면 일반 근로자만
                  if (_showManagerOnly) {
                    if (r.workerRole != 'center_manager') return false;
                  } else {
                    if (r.workerRole == 'center_manager') return false;
                  }
                  final centerMatch = _selectedCenter == '전체' || r.site == _selectedCenter;
                  final searchMatch = r.name.contains(_searchQuery) || r.site.contains(_searchQuery);
                  return centerMatch && searchMatch;
                }).toList();

                if (_selectedStatus != null) {
                  filtered = filtered.where((r) {
                    final isNightJob = r.job.contains('야간');
                    switch (_selectedStatus) {
                      case '주간출근':
                        return (r.status == '출근') && !isNightJob && r.checkOut == '-';
                      case '야간출근':
                        return (r.status == '출근') && isNightJob;
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
                      case 1: compare = a.name.compareTo(b.name); break;
                      case 2: compare = a.status.compareTo(b.status); break;
                      case 3: compare = a.checkIn.compareTo(b.checkIn); break;
                      case 4: compare = a.checkOut.compareTo(b.checkOut); break;
                      case 5: compare = a.site.compareTo(b.site); break;
                      case 6: compare = (a.company ?? '').compareTo(b.company ?? ''); break;
                      case 7: compare = a.phone.compareTo(b.phone); break;
                      case 8: compare = a.job.compareTo(b.job); break;
                      case 9: compare = (a.temperatureZone ?? '').compareTo(b.temperatureZone ?? ''); break;
                      case 10: compare = (a.joinDate ?? '').compareTo(b.joinDate ?? ''); break;
                      case 11: compare = a.note.compareTo(b.note); break;
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
                  TableColumnDef(label: 'No.', width: 45, onSort: () => onSort(0), sortAscending: _sortColumnIndex == 0 ? _isAscending : null),
                  TableColumnDef(label: '성명', width: 75, onSort: () => onSort(1), sortAscending: _sortColumnIndex == 1 ? _isAscending : null),
                  TableColumnDef(label: '상태', width: 75, onSort: () => onSort(2), sortAscending: _sortColumnIndex == 2 ? _isAscending : null),
                  TableColumnDef(label: '출근', width: 65, onSort: () => onSort(3), sortAscending: _sortColumnIndex == 3 ? _isAscending : null),
                  TableColumnDef(label: '퇴근', width: 65, onSort: () => onSort(4), sortAscending: _sortColumnIndex == 4 ? _isAscending : null),
                  TableColumnDef(label: '사업장', width: 75, onSort: () => onSort(5), sortAscending: _sortColumnIndex == 5 ? _isAscending : null),
                  TableColumnDef(label: '소속회사', width: 85, onSort: () => onSort(6), sortAscending: _sortColumnIndex == 6 ? _isAscending : null),
                  TableColumnDef(label: '전화번호', width: 115, onSort: () => onSort(7), sortAscending: _sortColumnIndex == 7 ? _isAscending : null),
                  TableColumnDef(label: '직무', width: 95, onSort: () => onSort(8), sortAscending: _sortColumnIndex == 8 ? _isAscending : null),
                  TableColumnDef(label: '상/저온', width: 60, onSort: () => onSort(9), sortAscending: _sortColumnIndex == 9 ? _isAscending : null),
                  TableColumnDef(label: '입사일', width: 95, onSort: () => onSort(10), sortAscending: _sortColumnIndex == 10 ? _isAscending : null),
                  TableColumnDef(label: '비고', width: 110, onSort: () => onSort(11), sortAscending: _sortColumnIndex == 11 ? _isAscending : null),
                ];

                return StickyHeaderTable.wrapWithCard(
                  columns: columns,
                  rowCount: filtered.length,
                  emptyMessage: '해당하는 데이터가 없습니다.',
                  cellBuilder: (colIndex, rowIndex) {
                    final e = filtered[rowIndex];
                    return switch (colIndex) {
                      0 => Text('${rowIndex + 1}', style: const TextStyle(fontSize: 13)),
                      1 => Tooltip(
                          message: e.name,
                          child: widget.onWorkerTap != null
                              ? GestureDetector(
                                  onTap: () => widget.onWorkerTap!(e.id ?? '', e.name),
                                  child: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.deepPurple, decoration: TextDecoration.underline, decorationColor: Colors.deepPurple)),
                                )
                              : Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      2 => _buildStatusBadge(e.status),
                      3 => Text(e.checkIn, style: const TextStyle(fontSize: 13)),
                      4 => Text(e.checkOut, style: const TextStyle(fontSize: 13)),
                      5 => Text(e.site, style: const TextStyle(fontSize: 13)),
                      6 => Text(e.company != null ? CompanyConstants.companyName(e.company!) : '-', style: const TextStyle(fontSize: 13)),
                      7 => Text(e.phone, style: const TextStyle(fontSize: 13)),
                      8 => Text(e.job, style: const TextStyle(fontSize: 13)),
                      9 => Text(e.temperatureZone ?? '상온', style: TextStyle(fontSize: 13, color: (e.temperatureZone == '저온') ? Colors.blue[700] : null)),
                      10 => Text(e.joinDate ?? '-', style: const TextStyle(fontSize: 13)),
                      11 => Text(e.note, style: const TextStyle(fontSize: 13)),
                      _ => const SizedBox(),
                    };
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('오류: $e'),
            ),
        );

        // 동적 테이블 높이: 큰 모니터 → 꽉 채움, 작은 모니터 → 최소 500px + 스크롤
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: topContent),
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final remaining = constraints.viewportMainAxisExtent - constraints.precedingScrollExtent;
                final tableHeight = remaining < 500 ? 500.0 : remaining;
                return SliverToBoxAdapter(
                  child: SizedBox(height: tableHeight, child: tableContent),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, String? filterValue) {
    final cs = Theme.of(context).colorScheme;
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
          color: isSelected ? color.withValues(alpha: 0.15) : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : cs.outlineVariant.withValues(alpha: 0.3),
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
            Text(title, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? color : cs.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = switch (status) {
      '지각' => Colors.orange,
      '출근' => Colors.green,
      '퇴근' => const Color(0xFF8D99AE),
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

  Widget _buildManagerFilterButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _showManagerOnly = !_showManagerOnly),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _showManagerOnly ? Colors.teal[700] : null,
            border: Border.all(
              color: _showManagerOnly ? Colors.teal[700]! : const Color(0xFFBDBDBD),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 16,
                color: _showManagerOnly ? Colors.white : Colors.teal[700],
              ),
              const SizedBox(width: 6),
              Text(
                '센터장',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _showManagerOnly ? Colors.white : Colors.teal[700],
                ),
              ),
              if (_showManagerOnly) ...[
                const SizedBox(width: 4),
                const Icon(Icons.close, size: 14, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDropdown() {
    final cs = Theme.of(context).colorScheme;
    final sites = ref.watch(sitesProvider).valueOrNull ?? [];
    final centers = _getAvailableCenters(sites);

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCenter,
          isDense: true,
          items: centers
              .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: centers.length > 1 ? (v) => setState(() => _selectedCenter = v!) : null,
        ),
      ),
    );
  }
}
