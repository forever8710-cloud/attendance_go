import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/permissions.dart';
import '../providers/workers_provider.dart';
import '../data/workers_repository.dart';

class WorkersScreen extends ConsumerStatefulWidget {
  const WorkersScreen({super.key, required this.role});

  final AppRole role;

  @override
  ConsumerState<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends ConsumerState<WorkersScreen> {
  String _searchQuery = '';
  WorkerRow? _selectedWorker;
  bool _isNewWorker = false;

  // Form controllers
  final _employeeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _ssnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyController = TextEditingController();

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
    _emailController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _loadWorkerData(WorkerRow worker) {
    setState(() {
      _selectedWorker = worker;
      _isNewWorker = false;
      _employeeIdController.text = worker.employeeId ?? '';
      _nameController.text = worker.name;
      _ssnController.text = worker.ssn ?? '';
      _phoneController.text = worker.phone;
      _addressController.text = worker.address ?? '';
      _emailController.text = worker.email ?? '';
      _emergencyController.text = worker.emergencyContact ?? '';
      _gender = worker.gender;
      _employmentStatus = worker.employmentStatus;
      _position = worker.position;
      _role = worker.role;
      _job = worker.job;
      _site = worker.site;
      _joinDate = worker.joinDate;
      _leaveDate = worker.leaveDate;
    });
  }

  void _clearForm() {
    setState(() {
      _selectedWorker = null;
      _isNewWorker = true;
      _employeeIdController.clear();
      _nameController.clear();
      _ssnController.clear();
      _phoneController.clear();
      _addressController.clear();
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

  Future<void> _saveWorker() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 전화번호는 필수입니다.')),
      );
      return;
    }

    final worker = WorkerRow(
      id: _selectedWorker?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: _employeeIdController.text.isEmpty ? null : _employeeIdController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      part: _job ?? '미정',
      site: _site ?? '서이천',
      isActive: _employmentStatus != '퇴사',
      ssn: _ssnController.text.isEmpty ? null : _ssnController.text,
      gender: _gender,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      emergencyContact: _emergencyController.text.isEmpty ? null : _emergencyController.text,
      employmentStatus: _employmentStatus,
      joinDate: _joinDate,
      leaveDate: _leaveDate,
      position: _position,
      role: _role,
      job: _job,
    );

    await ref.read(workersRepositoryProvider).saveWorkerProfile(worker);
    ref.invalidate(workersProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${worker.name}님의 정보가 저장되었습니다.')),
      );
    }
  }

  bool get _canEdit => canEditWorkers(widget.role);

  @override
  Widget build(BuildContext context) {
    final workers = ref.watch(workersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 상단: 인사기록카드 ──
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[300]!),
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
                      const Icon(Icons.badge, color: Colors.indigo, size: 20),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 좌측: 사진 영역 (단독)
                        Column(
                          children: [
                            Container(
                              width: 110,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: _selectedWorker?.photoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(_selectedWorker!.photoUrl!, fit: BoxFit.cover),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person, size: 44, color: Colors.grey[400]),
                                        const SizedBox(height: 4),
                                        Text('반명함', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
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
                              // 1행: ID, 사번, 이름, 주민번호, 성별
                              Row(
                                children: [
                                  SizedBox(width: 80, child: _buildReadonlyField('ID', _selectedWorker?.id ?? '(자동)')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('사번', _employeeIdController)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('이름 *', _nameController)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('주민번호', _ssnController)),
                                  const SizedBox(width: 12),
                                  SizedBox(width: 80, child: _buildDropdown('성별', ['남', '여'], _gender, (v) => setState(() => _gender = v))),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 2행: 전화번호, 비상연락망, E-mail
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('전화번호 *', _phoneController)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('비상연락망', _emergencyController)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('E-mail', _emailController)),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 3행: 주소
                              _buildTextField('주소', _addressController),
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
                                  Expanded(child: _buildDropdown('직무', ['사무', '지게차', '피커', '검수'], _job, (v) => setState(() => _job = v))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildDropdown('사업장', ['서이천', '의왕', '부평', '남사'], _site, (v) => setState(() => _site = v))),
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
                                    const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    const Text('이력서 첨부', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          '아래 목록에서 근로자를 선택하거나\n신규 등록 버튼을 클릭하세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── 중간: 구분선 ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                const Icon(Icons.list_alt, size: 18, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text('근로자 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(width: 16),
                Expanded(child: Divider(color: Colors.grey[300])),
                const SizedBox(width: 16),
                SizedBox(
                  width: 220,
                  height: 36,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: '이름, 전화번호 검색...',
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
          ),

          // ── 하단: 근로자 리스트 ──
          workers.when(
            data: (list) {
              // center_manager: 본인 센터(서이천) 근로자만 표시
              var baseList = list;
              if (widget.role == AppRole.centerManager) {
                baseList = list.where((w) => w.site == '서이천').toList();
              }
              final filtered = baseList.where((w) =>
                w.name.contains(_searchQuery) || w.phone.contains(_searchQuery),
              ).toList();

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 28,
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('No.')),
                      DataColumn(label: Text('성명')),
                      DataColumn(label: Text('사번')),
                      DataColumn(label: Text('전화번호')),
                      DataColumn(label: Text('직무')),
                      DataColumn(label: Text('직위')),
                      DataColumn(label: Text('사업장')),
                      DataColumn(label: Text('재직상태')),
                      DataColumn(label: Text('입사일')),
                    ],
                    rows: filtered.asMap().entries.map((entry) {
                      final i = entry.key;
                      final w = entry.value;
                      final isSelected = _selectedWorker?.id == w.id;

                      return DataRow(
                        selected: isSelected,
                        color: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.indigo.withValues(alpha: 0.1);
                          }
                          return null;
                        }),
                        onSelectChanged: (_) => _loadWorkerData(w),
                        cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(w.name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.indigo : null))),
                          DataCell(Text(w.employeeId ?? '-')),
                          DataCell(Text(w.phone)),
                          DataCell(Text(w.job ?? w.part)),
                          DataCell(Text(w.position ?? '-')),
                          DataCell(Text(w.site)),
                          DataCell(_buildStatusChip(w.employmentStatus ?? (w.isActive ? '재직' : '퇴사'))),
                          DataCell(Text(w.joinDate != null ? DateFormat('yyyy-MM-dd').format(w.joinDate!) : '-')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('오류: $e'),
          ),
        ],
          ),
        ),
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
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
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
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1990),
          lastDate: DateTime(2100),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
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
