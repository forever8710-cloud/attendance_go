import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/permissions.dart';
import '../providers/accounts_provider.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  String _searchQuery = '';
  AccountRow? _selectedAccount;
  bool _isNewAccount = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _role = 'worker';
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadAccount(AccountRow account) {
    setState(() {
      _selectedAccount = account;
      _isNewAccount = false;
      _nameController.text = account.name;
      _phoneController.text = account.phone;
      _emailController.text = account.email ?? '';
      _role = account.role;
      _isActive = account.isActive;
    });
  }

  void _clearForm() {
    setState(() {
      _selectedAccount = null;
      _isNewAccount = true;
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _role = 'worker';
      _isActive = true;
    });
  }

  Future<void> _saveAccount() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 전화번호는 필수입니다.')),
      );
      return;
    }

    final account = AccountRow(
      id: _selectedAccount?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      role: _role,
      isActive: _isActive,
      createdAt: _selectedAccount?.createdAt ?? DateTime.now(),
    );

    await ref.read(accountsRepositoryProvider).saveAccount(account);
    ref.invalidate(accountsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${account.name}님의 계정이 저장되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 상단: 계정 정보 카드 ──
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
                  // 카드 헤더: 타이틀 + 신규 버튼
                  Row(
                    children: [
                      const Icon(Icons.manage_accounts, color: Colors.indigo, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isNewAccount ? '신규 계정 생성' : (_selectedAccount != null ? '${_selectedAccount!.name} - 계정 정보' : '계정 정보'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
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

                  if (_selectedAccount != null || _isNewAccount) ...[
                    // 1행: ID (읽기전용), 이름, 전화번호
                    Row(
                      children: [
                        if (_selectedAccount != null) ...[
                          SizedBox(width: 80, child: _buildReadonlyField('ID', _selectedAccount!.id)),
                          const SizedBox(width: 12),
                        ],
                        Expanded(child: _buildFormField('이름 *', _nameController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFormField('전화번호 *', _phoneController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFormField('이메일', _emailController)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 2행: 역할, 상태, 생성일
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            initialValue: _role,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                            decoration: const InputDecoration(
                              labelText: '역할',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'worker', child: Text('근로자')),
                              DropdownMenuItem(value: 'center_manager', child: Text('센터장')),
                              DropdownMenuItem(value: 'owner', child: Text('대표이사')),
                              DropdownMenuItem(value: 'system_admin', child: Text('시스템관리자')),
                            ],
                            onChanged: (v) => setState(() => _role = v ?? 'worker'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('상태:', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('활성', style: TextStyle(fontSize: 12)),
                          selected: _isActive,
                          onSelected: (_) => setState(() => _isActive = true),
                          selectedColor: Colors.green.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('비활성', style: TextStyle(fontSize: 12)),
                          selected: !_isActive,
                          onSelected: (_) => setState(() => _isActive = false),
                          selectedColor: Colors.grey.withValues(alpha: 0.2),
                        ),
                        if (_selectedAccount?.createdAt != null) ...[
                          const SizedBox(width: 24),
                          Text(
                            '생성일: ${DateFormat('yyyy-MM-dd').format(_selectedAccount!.createdAt!)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 저장 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_selectedAccount != null) ...[
                          OutlinedButton.icon(
                            onPressed: () async {
                              await ref.read(accountsRepositoryProvider).toggleAccountStatus(_selectedAccount!.id);
                              ref.invalidate(accountsProvider);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${_selectedAccount!.name}님의 상태가 변경되었습니다.')),
                                );
                              }
                            },
                            icon: Icon(_selectedAccount!.isActive ? Icons.block : Icons.check_circle, size: 16),
                            label: Text(_selectedAccount!.isActive ? '비활성화' : '활성화', style: const TextStyle(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _selectedAccount!.isActive ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        FilledButton.icon(
                          onPressed: _saveAccount,
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
                          '아래 목록에서 계정을 선택하거나\n신규 등록 버튼을 클릭하세요.',
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
                const Text('계정 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
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

          // ── 하단: 계정 리스트 ──
          accounts.when(
            data: (list) {
              final filtered = list.where((a) =>
                a.name.contains(_searchQuery) || a.phone.contains(_searchQuery),
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
                      DataColumn(label: Text('이름')),
                      DataColumn(label: Text('전화번호')),
                      DataColumn(label: Text('이메일')),
                      DataColumn(label: Text('역할')),
                      DataColumn(label: Text('상태')),
                      DataColumn(label: Text('생성일')),
                    ],
                    rows: filtered.asMap().entries.map((entry) {
                      final i = entry.key;
                      final a = entry.value;
                      final isSelected = _selectedAccount?.id == a.id;

                      return DataRow(
                        selected: isSelected,
                        color: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.indigo.withValues(alpha: 0.1);
                          }
                          return null;
                        }),
                        onSelectChanged: (_) => _loadAccount(a),
                        cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(a.name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.indigo : null))),
                          DataCell(Text(a.phone)),
                          DataCell(Text(a.email ?? '-')),
                          DataCell(_buildRoleBadge(a.role)),
                          DataCell(_buildStatusBadge(a.isActive)),
                          DataCell(Text(a.createdAt != null ? DateFormat('yyyy-MM-dd').format(a.createdAt!) : '-')),
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

  Widget _buildFormField(String label, TextEditingController controller) {
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

  Widget _buildRoleBadge(String role) {
    final appRole = roleFromString(role);
    final (color, label) = switch (appRole) {
      AppRole.systemAdmin => (Colors.red, '시스템관리자'),
      AppRole.owner => (Colors.indigo, '대표이사'),
      AppRole.centerManager => (Colors.teal, '센터장'),
      AppRole.worker => (Colors.blue, '근로자'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        isActive ? '활성' : '비활성',
        style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
