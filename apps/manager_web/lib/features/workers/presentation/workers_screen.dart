import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/permissions.dart';
import '../../../core/utils/company_constants.dart';
import '../../../core/providers/reference_data_provider.dart';
import '../../../core/widgets/modern_date_picker.dart';
import '../../../core/widgets/sticky_data_table.dart';
import '../providers/workers_provider.dart';
import '../providers/registration_provider.dart';
import '../data/workers_repository.dart';
import '../data/registration_repository.dart';
import 'widgets/approval_form_dialog.dart';
import 'package:uuid/uuid.dart';

class WorkersScreen extends ConsumerStatefulWidget {
  const WorkersScreen({super.key, required this.role, this.onWorkerTap, this.userSiteId = ''});

  final AppRole role;
  final String userSiteId;
  final void Function(String id, String name)? onWorkerTap;

  @override
  ConsumerState<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends ConsumerState<WorkersScreen> {
  String _searchQuery = '';
  String _siteFilter = '전체';
  String _jobFilter = '전체';
  String _statusFilter = '전체';
  WorkerRow? _selectedWorker;
  bool _isNewWorker = false;

  // Form controllers
  final _employeeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _ssnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyController = TextEditingController();

  String? _company;
  String? _gender;
  String? _employmentStatus;
  String? _position;
  String? _role;
  String? _job;
  String? _site;
  DateTime? _joinDate;
  DateTime? _leaveDate;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _ssnController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _emailController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  // 드롭다운 rebuild를 위한 키
  int _formKey = 0;

  void _loadWorkerData(WorkerRow worker) {
    setState(() {
      _selectedWorker = worker;
      _isNewWorker = false;
      _formKey++; // 드롭다운 강제 재빌드
      _company = worker.company;
      _employeeIdController.text = worker.employeeId ?? '';
      _nameController.text = worker.name;
      _ssnController.text = worker.ssn ?? '';
      _phoneController.text = worker.phone;
      _addressController.text = worker.address ?? '';
      _detailAddressController.text = worker.detailAddress ?? '';
      _emailController.text = worker.email ?? '';
      _emergencyController.text = worker.emergencyContact ?? '';
      _gender = worker.gender;
      _employmentStatus = worker.employmentStatus;
      _position = worker.position;
      _role = worker.role;
      _job = worker.job ?? (worker.part.isNotEmpty ? worker.part : null);
      _site = worker.site.isNotEmpty ? worker.site : null;
      _joinDate = worker.joinDate;
      _leaveDate = worker.leaveDate;
    });
  }

  void _clearForm() {
    setState(() {
      _selectedWorker = null;
      _isNewWorker = true;
      _formKey++; // 드롭다운 강제 재빌드
      _company = null;
      _employeeIdController.clear();
      _nameController.clear();
      _ssnController.clear();
      _phoneController.clear();
      _addressController.clear();
      _detailAddressController.clear();
      _emailController.clear();
      _emergencyController.clear();
      _gender = null;
      _employmentStatus = null;
      _position = null;
      _role = null;
      _job = null;
      _site = null;
      _joinDate = null;
      _leaveDate = null;
    });
  }

  Future<void> _updateAutoEmployeeId() async {
    if (_company != null && _site != null) {
      final repo = ref.read(workersRepositoryProvider);
      final generatedId = await repo.generateNextEmployeeId(_company!, _site!);
      if (mounted) _employeeIdController.text = generatedId;
    } else if (_isNewWorker) {
      _employeeIdController.clear();
    }
  }

  Future<void> _saveWorker() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 전화번호는 필수입니다.')),
      );
      return;
    }

    final worker = WorkerRow(
      id: _selectedWorker?.id ?? const Uuid().v4(),
      company: _company,
      employeeId: _employeeIdController.text.isEmpty ? null : _employeeIdController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      part: _job ?? _selectedWorker?.part ?? '',
      site: _site ?? _selectedWorker?.site ?? '',
      isActive: _employmentStatus != '퇴사',
      ssn: _ssnController.text.isEmpty ? null : _ssnController.text,
      gender: _gender,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      detailAddress: _detailAddressController.text.isEmpty ? null : _detailAddressController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      emergencyContact: _emergencyController.text.isEmpty ? null : _emergencyController.text,
      employmentStatus: _employmentStatus,
      joinDate: _joinDate,
      leaveDate: _leaveDate,
      position: _position,
      role: _role,
      job: _job,
    );

    try {
      final repo = ref.read(workersRepositoryProvider);
      if (_isNewWorker) {
        await repo.createWorkerWithProfile(worker);
      } else {
        await repo.saveWorkerProfile(worker);
      }
      ref.invalidate(workersProvider);

      if (mounted) {
        final action = _isNewWorker ? '등록' : '수정';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${worker.name}님의 정보가 ${action}되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        // 수정 후 폼에 최신 데이터 유지
        if (_isNewWorker) {
          _clearForm();
          setState(() => _isNewWorker = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get _canEdit => canEditWorkers(widget.role);

  @override
  Widget build(BuildContext context) {
    final workers = ref.watch(workersProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 상단: 인사기록카드 ──
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카드 헤더: 타이틀 + 신규등록 버튼
                  Row(
                    children: [
                      const Icon(Icons.badge, color: Color(0xFF8D99AE), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isNewWorker ? '신규 근로자 등록' : (_selectedWorker != null ? '${_selectedWorker!.name} - 인사기록카드' : '인사기록카드'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_canEdit)
                        FilledButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('신규 등록', style: TextStyle(fontSize: 13)),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                    ],
                  ),
                    const Divider(height: 24),
                    if (_selectedWorker != null || _isNewWorker) ...[
                    KeyedSubtree(
                      key: ValueKey('form_$_formKey'),
                      child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 좌측: 사진 영역 (단독)
                        Column(
                          children: [
                            Container(
                              width: 110,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              child: _selectedWorker?.photoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(_selectedWorker!.photoUrl!, fit: BoxFit.cover),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person, size: 44, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
                                        const SizedBox(height: 4),
                                        Text('반명함', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 6),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.upload, size: 14),
                              label: const Text('사진 첨부', style: TextStyle(fontSize: 11)),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),

                        // 우측: 입력 폼
                        Expanded(
                          child: Column(
                            children: [
                              // 1행: 소속회사, 사번, 이름, 성별
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown(
                                      '소속회사',
                                      CompanyConstants.companies.map((c) => c.displayName).toList(),
                                      _company != null ? CompanyConstants.companies.firstWhere((c) => c.code == _company).displayName : null,
                                      (v) {
                                        setState(() {
                                          if (v != null) {
                                            _company = CompanyConstants.companies.firstWhere((c) => c.displayName == v).code;
                                          } else {
                                            _company = null;
                                          }
                                        });
                                        _updateAutoEmployeeId();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _employeeIdController,
                                      readOnly: true,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        labelText: '사번',
                                        labelStyle: const TextStyle(fontSize: 12),
                                        hintText: '(자동)',
                                        hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
                                        border: const OutlineInputBorder(),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('이름 *', _nameController)),
                                  const SizedBox(width: 12),
                                  SizedBox(width: 100, child: _buildDropdown('성별', ['남', '여'], _gender, (v) => setState(() => _gender = v))),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 2행: 주민번호, 전화번호, 비상연락망, E-mail
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('주민번호', _ssnController)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('전화번호 *', _phoneController)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('비상연락망', _emergencyController)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('E-mail', _emailController)),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 3행: 주소(자동검색) + 주소찾기 | 나머지주소(수동입력)
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _addressController,
                                            readOnly: true,
                                            style: const TextStyle(fontSize: 13),
                                            decoration: InputDecoration(
                                              labelText: '주소',
                                              labelStyle: const TextStyle(fontSize: 12),
                                              hintText: '주소찾기 버튼을 클릭하세요',
                                              hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
                                              border: const OutlineInputBorder(),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              isDense: true,
                                              filled: true,
                                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          height: 40,
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showAddressSearchDialog(context),
                                            icon: const Icon(Icons.search, size: 16),
                                            label: const Text('주소찾기', style: TextStyle(fontSize: 12)),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField('나머지 주소 (동/호수)', _detailAddressController),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 4행: 재직상태, 입사일, 퇴사일
                              Row(
                                children: [
                                  Expanded(child: _buildDropdown('재직상태', ['정규직', '계약직', '일용직', '파견', '육아휴직'], _employmentStatus, (v) => setState(() => _employmentStatus = v))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildDatePicker('입사일', _joinDate, (d) => setState(() => _joinDate = d))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildDatePicker('퇴사일', _leaveDate, (d) => setState(() => _leaveDate = d))),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 5행: 직위, 직책, 직무, 사업장
                              Row(
                                children: [
                                  Expanded(child: _buildDropdown('직위', ['사원', '대리', '과장', '부장', '대표'], _position, (v) => setState(() => _position = v))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildDropdown('직책', ['', '조장', '파트장'], _role, (v) => setState(() => _role = v))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildDropdown('직무', ref.watch(partNamesProvider), _job, (v) => setState(() => _job = v))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildDropdown(
                                    '사업장',
                                    ref.watch(siteNamesProvider),
                                    _site,
                                    (v) {
                                      setState(() => _site = v);
                                      _updateAutoEmployeeId();
                                    },
                                  )),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 이력서 첨부
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.attach_file, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)),
                                    const SizedBox(width: 6),
                                    Text('이력서 첨부', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45), fontSize: 13)),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                                      child: const Text('파일 선택', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ), // KeyedSubtree 닫기
                    const SizedBox(height: 16),

                    // 저장/퇴사 버튼 (편집 권한이 있을 때만)
                    if (_canEdit)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_selectedWorker != null) ...[
                            OutlinedButton.icon(
                              onPressed: () => _showDeleteDialog(context, _selectedWorker!),
                              icon: const Icon(Icons.person_off, size: 16),
                              label: const Text('퇴사 처리', style: TextStyle(fontSize: 13)),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            ),
                            const SizedBox(width: 12),
                          ],
                          FilledButton.icon(
                            onPressed: _saveWorker,
                            icon: const Icon(Icons.save, size: 16),
                            label: const Text('저장', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            '아래 목록에서 근로자를 선택하거나\n신규 등록 버튼을 클릭하세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ),

                ),
              ),
            ),
          ),

          // ── 등록 대기 요청 섹션 ──
          _buildPendingRequestsSection(),

          // ── 중간: 필터 바 ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.list_alt, size: 18, color: Color(0xFF8D99AE)),
                    const SizedBox(width: 8),
                    const Text('근로자 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8D99AE))),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildWorkerFilterDropdown('사업장', _siteFilter, ['전체', ...ref.watch(siteNamesProvider)],
                            (v) => setState(() => _siteFilter = v!)),
                        _buildWorkerFilterDropdown('직무', _jobFilter, ['전체', ...ref.watch(partNamesProvider)],
                            (v) => setState(() => _jobFilter = v!)),
                        _buildWorkerFilterDropdown('재직상태', _statusFilter, ['전체', '정규직', '계약직', '일용직', '파견', '육아휴직'],
                            (v) => setState(() => _statusFilter = v!)),
                        SizedBox(
                          width: 200,
                          height: 36,
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: '이름 검색...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _siteFilter = '전체';
                            _jobFilter = '전체';
                            _statusFilter = '전체';
                            _searchQuery = '';
                          }),
                          child: const Text('초기화'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 하단: 근로자 리스트 (헤더 고정) ──
          Expanded(
            child: workers.when(
              data: (list) {
                var baseList = list;
                if (widget.role == AppRole.centerManager && widget.userSiteId.isNotEmpty) {
                  final userSiteName = ref.watch(siteNameByIdProvider)[widget.userSiteId] ?? '';
                  if (userSiteName.isNotEmpty) {
                    baseList = list.where((w) => w.site == userSiteName).toList();
                  }
                }
                final filtered = baseList.where((w) {
                  if (_siteFilter != '전체' && w.site != _siteFilter) return false;
                  if (_jobFilter != '전체' && (w.job ?? w.part) != _jobFilter) return false;
                  if (_statusFilter != '전체') {
                    final status = w.employmentStatus ?? (w.isActive ? '재직' : '퇴사');
                    if (status != _statusFilter) return false;
                  }
                  if (_searchQuery.isNotEmpty && !w.name.contains(_searchQuery) && !w.phone.contains(_searchQuery)) return false;
                  return true;
                }).toList();

                final columns = [
                  const TableColumnDef(label: 'No.', width: 45),
                  const TableColumnDef(label: '성명', width: 75),
                  const TableColumnDef(label: '소속회사', width: 85),
                  const TableColumnDef(label: '사번', width: 85),
                  const TableColumnDef(label: '전화번호', width: 115),
                  const TableColumnDef(label: '직무', width: 95),
                  const TableColumnDef(label: '직위', width: 65),
                  const TableColumnDef(label: '사업장', width: 75),
                  const TableColumnDef(label: '재직상태', width: 80),
                  const TableColumnDef(label: '입사일', width: 95),
                ];

                return StickyHeaderTable.wrapWithCard(
                  columns: columns,
                  rowCount: filtered.length,
                  isRowSelected: (i) => _selectedWorker?.id == filtered[i].id,
                  onRowTap: (i) => _loadWorkerData(filtered[i]),
                  cellBuilder: (colIndex, rowIndex) {
                    final w = filtered[rowIndex];
                    final isSelected = _selectedWorker?.id == w.id;
                    return switch (colIndex) {
                      0 => Text('${rowIndex + 1}', style: const TextStyle(fontSize: 13)),
                      1 => widget.onWorkerTap != null
                          ? GestureDetector(
                              onTap: () => widget.onWorkerTap!(w.id, w.name),
                              child: Text(w.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.deepPurple, decoration: TextDecoration.underline, decorationColor: Colors.deepPurple)),
                            )
                          : Text(w.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF8D99AE) : null)),
                      2 => Text(w.company != null ? CompanyConstants.companyName(w.company!) : '-', style: const TextStyle(fontSize: 13)),
                      3 => Text(w.employeeId ?? '-', style: const TextStyle(fontSize: 13)),
                      4 => Text(w.phone, style: const TextStyle(fontSize: 13)),
                      5 => Text(w.job ?? w.part, style: const TextStyle(fontSize: 13)),
                      6 => Text(w.position ?? '-', style: const TextStyle(fontSize: 13)),
                      7 => Text(w.site, style: const TextStyle(fontSize: 13)),
                      8 => _buildStatusChip(w.employmentStatus ?? (w.isActive ? '재직' : '퇴사')),
                      9 => Text(w.joinDate != null ? DateFormat('yyyy-MM-dd').format(w.joinDate!) : '-', style: const TextStyle(fontSize: 13)),
                      _ => const SizedBox(),
                    };
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('오류: $e'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        isDense: true,
      ),
    );
  }

  Widget _buildReadonlyField(String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        isDense: true,
      ),
      items: items.map((e) => DropdownMenuItem(value: e.isEmpty ? null : e, child: Text(e.isEmpty ? '-' : e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, ValueChanged<DateTime?> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showModernDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1990),
          lastDate: DateTime(2100),
          title: label,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense: true,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value != null ? DateFormat('yyyy-MM-dd').format(value) : '-', style: const TextStyle(fontSize: 13)),
            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = switch (status) {
      '정규직' => Colors.green,
      '계약직' => Colors.blue,
      '일용직' => Colors.orange,
      '파견' => Colors.purple,
      '육아휴직' => Colors.teal,
      '퇴사' || '재직' => status == '재직' ? Colors.green : Colors.grey,
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

  Widget _buildWorkerFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((v) => DropdownMenuItem(value: v, child: Text('$label: $v', style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showAddressSearchDialog(BuildContext context) {
    // 데모용 mock 주소 (향후 카카오/네이버 주소 API 연동)
    const mockAddresses = [
      '경기도 이천시 호법면 매곡리 123',
      '경기도 이천시 부발읍 무촌리 456',
      '경기도 안성시 공도읍 만정리 789',
      '경기도 의왕시 내손동 234-5',
      '경기도 의왕시 오전동 567-8',
      '인천시 부평구 부평동 890-1',
      '인천시 부평구 산곡동 345-6',
      '서울시 강남구 역삼동 123-4',
      '서울시 송파구 잠실동 567-8',
      '경기도 용인시 수지구 죽전동 901-2',
    ];
    String query = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final results = query.isEmpty
                ? mockAddresses
                : mockAddresses.where((a) => a.contains(query)).toList();

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.location_on, color: const Color(0xFF8D99AE)),
                  SizedBox(width: 8),
                  Text('주소 검색'),
                ],
              ),
              content: SizedBox(
                width: 480,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      onChanged: (v) => setDialogState(() => query = v),
                      decoration: InputDecoration(
                        hintText: '도로명, 지번, 건물명 검색',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: results.isEmpty
                          ? Center(child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey[500])))
                          : ListView.separated(
                              itemCount: results.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF8D99AE)),
                                  title: Text(results[i], style: const TextStyle(fontSize: 13)),
                                  onTap: () {
                                    _addressController.text = results[i];
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPendingRequestsSection() {
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();

        final cs = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_add_rounded, size: 18, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '등록 대기 요청 (${requests.length}건)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...requests.map((req) => Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: _buildPendingRequestCard(req, cs),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestCard(RegistrationRequest req, ColorScheme cs) {
    final companyName = CompanyConstants.companyName(req.company);
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(req.createdAt.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        color: Colors.orange.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // 아바타
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange.withValues(alpha: 0.15),
                child: Text(
                  req.name.isNotEmpty ? req.name[0] : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                ),
              ),
              const SizedBox(width: 16),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(req.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('대기', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${req.phone} | $companyName | $dateStr',
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                    if (req.address != null && req.address!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${req.address ?? ''} ${req.detailAddress ?? ''}',
                          style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // 버튼
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _showRejectDialog(req),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('거부', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _openApprovalForm(req),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2B2D42),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('승인', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openApprovalForm(RegistrationRequest request) {
    showDialog(
      context: context,
      builder: (_) => ApprovalFormDialog(request: request),
    ).then((_) {
      ref.invalidate(pendingRequestsProvider);
      ref.invalidate(pendingCountProvider);
      ref.invalidate(workersProvider);
    });
  }

  void _showRejectDialog(RegistrationRequest request) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('가입 요청 거부'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${request.name}님의 가입 요청을 거부하시겠습니까?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '거부 사유',
                hintText: '거부 사유를 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              try {
                await ref.read(registrationRepositoryProvider).rejectRequest(request.id, reason);
                if (ctx.mounted) Navigator.of(ctx).pop();
                ref.invalidate(pendingRequestsProvider);
                ref.invalidate(pendingCountProvider);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('거부 처리 실패: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('거부'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WorkerRow worker) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('퇴사 처리'),
        content: Text('${worker.name}님을 퇴사 처리하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              await ref.read(workersRepositoryProvider).deactivateWorker(worker.id);
              ref.invalidate(workersProvider);
              _clearForm();
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('퇴사 처리'),
          ),
        ],
      ),
    );
  }
}
