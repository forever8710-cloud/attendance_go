import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_client/supabase_client.dart';
import '../../../core/utils/permissions.dart';
import '../../../core/widgets/sticky_data_table.dart';
import '../providers/accounts_provider.dart';

/// 사이트 목록 provider
final _sitesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final rows = await SupabaseService.instance
      .from('sites')
      .select('id, name')
      .order('name');
  return (rows as List).cast<Map<String, dynamic>>();
});

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
  final _passwordController = TextEditingController();
  final _personalEmailController = TextEditingController();
  String _role = 'center_manager';
  String? _position;
  String? _siteId;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isSendingEmail = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _personalEmailController.dispose();
    super.dispose();
  }

  void _loadAccount(AccountRow account) {
    setState(() {
      _selectedAccount = account;
      _isNewAccount = false;
      _nameController.text = account.name;
      _phoneController.text = account.phone;
      _emailController.text = account.email ?? '';
      _personalEmailController.text = account.personalEmail ?? '';
      _role = account.role;
      _position = account.position;
      _siteId = account.siteId;
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
      _passwordController.clear();
      _personalEmailController.clear();
      _role = 'center_manager';
      _position = null;
      _siteId = null;
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

    // 신규 등록 시 이메일, 비밀번호 필수
    if (_isNewAccount) {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신규 등록 시 이메일과 비밀번호는 필수입니다.')),
        );
        return;
      }
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호는 6자 이상이어야 합니다.')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      if (_isNewAccount) {
        // Edge Function으로 Auth 유저 + DB 레코드 생성
        final createdName = _nameController.text;
        final createdLoginEmail = _emailController.text;
        final createdPassword = _passwordController.text;
        final createdPersonalEmail = _personalEmailController.text.trim();

        await ref.read(accountsRepositoryProvider).createAccount(
          email: createdLoginEmail,
          password: createdPassword,
          name: createdName,
          phone: _phoneController.text,
          role: _role,
          siteId: _siteId,
          position: _position,
          personalEmail: createdPersonalEmail.isEmpty ? null : createdPersonalEmail,
        );
        ref.invalidate(accountsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$createdName님의 계정이 생성되었습니다.')),
          );
          _clearForm();
          setState(() => _isNewAccount = false);

          // 개인 이메일이 있으면 가입정보 전송 다이얼로그
          if (createdPersonalEmail.isNotEmpty) {
            _showSendEmailDialog(
              toEmail: createdPersonalEmail,
              name: createdName,
              loginEmail: createdLoginEmail,
              password: createdPassword,
            );
          }
        }
      } else {
        // 기존 계정 수정
        final account = AccountRow(
          id: _selectedAccount!.id,
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          role: _role,
          position: _position,
          siteId: _siteId,
          isActive: _isActive,
          createdAt: _selectedAccount?.createdAt ?? DateTime.now(),
          personalEmail: _personalEmailController.text.trim().isEmpty ? null : _personalEmailController.text.trim(),
        );
        await ref.read(accountsRepositoryProvider).saveAccount(account);
        ref.invalidate(accountsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${account.name}님의 계정이 저장되었습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// 계정 삭제 확인 다이얼로그
  void _showDeleteDialog(AccountRow account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('계정 삭제', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: account.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '님의 계정을 완전히 삭제하시겠습니까?'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Text(
                '삭제된 계정은 복구할 수 없으며,\n관련된 모든 데이터가 함께 삭제됩니다.',
                style: TextStyle(fontSize: 13, color: Colors.red, height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(accountsRepositoryProvider).deleteAccount(account.id);
                ref.invalidate(accountsProvider);
                if (mounted) {
                  setState(() {
                    _selectedAccount = null;
                    _isNewAccount = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${account.name}님의 계정이 삭제되었습니다.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_forever, size: 16),
            label: const Text('삭제'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
          ),
        ],
      ),
    );
  }

  /// 기존 계정에 가입정보 메일 전송 (비밀번호 미포함)
  Future<void> _sendWelcomeEmail() async {
    final personalEmail = _personalEmailController.text.trim();
    if (personalEmail.isEmpty || _selectedAccount == null) return;

    setState(() => _isSendingEmail = true);
    try {
      await ref.read(accountsRepositoryProvider).sendWelcomeEmail(
        toEmail: personalEmail,
        name: _selectedAccount!.name,
        loginEmail: _selectedAccount!.email!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('가입정보가 $personalEmail로 전송되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메일 전송 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingEmail = false);
    }
  }

  /// 신규 계정 생성 후 가입정보 전송 다이얼로그
  void _showSendEmailDialog({
    required String toEmail,
    required String name,
    required String loginEmail,
    required String password,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: const Color(0xFF8D99AE)),
            SizedBox(width: 8),
            Text('가입정보 메일 전송', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name님의 가입정보를 아래 이메일로 전송하시겠습니까?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('수신: $toEmail', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('내용: 로그인 아이디, 초기 비밀번호, 접속 주소', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('건너뛰기'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isSendingEmail = true);
              try {
                await ref.read(accountsRepositoryProvider).sendWelcomeEmail(
                  toEmail: toEmail,
                  name: name,
                  loginEmail: loginEmail,
                  password: password,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('가입정보가 $toEmail로 전송되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('메일 전송 실패: $e'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (mounted) setState(() => _isSendingEmail = false);
              }
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('전송'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child:
        Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // ── 상단: 계정 정보 카드 ──
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
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
                      const Icon(Icons.manage_accounts, color: Color(0xFF8D99AE), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isNewAccount ? '신규 관리자 계정 생성' : (_selectedAccount != null ? '${_selectedAccount!.name} - 관리자 계정정보' : '관리자 계정정보'),
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
                    // 1행: 로그인 아이디, 이름, 전화번호
                    Row(
                      children: [
                        Expanded(child: _buildFormField(_isNewAccount ? '로그인 아이디(이메일) *' : '로그인 아이디(이메일)', _emailController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFormField('이름 *', _nameController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFormField('전화번호 *', _phoneController)),
                      ],
                    ),
                    // 신규 등록 시: 비밀번호 + 개인 이메일 필드
                    if (_isNewAccount) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: '초기 비밀번호 *',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                isDense: true,
                                helperText: '6자 이상 (로그인 후 본인이 변경 가능)',
                                helperStyle: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _personalEmailController,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: '개인 이메일 (가입정보 수신용)',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                isDense: true,
                                helperText: '가입정보를 이 이메일로 전송합니다',
                                helperStyle: TextStyle(fontSize: 11),
                                prefixIcon: Icon(Icons.email_outlined, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // 기존 계정: 개인 이메일 필드
                    if (!_isNewAccount && _selectedAccount != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _personalEmailController,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: '개인 이메일 (가입정보 수신용)',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                isDense: true,
                                prefixIcon: Icon(Icons.email_outlined, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),

                    // 2행: 직위, 소속 센터, 권한, 상태, 생성일
                    Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            initialValue: _position,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                            decoration: const InputDecoration(
                              labelText: '직위',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: '시스템관리자', child: Text('시스템관리자')),
                              DropdownMenuItem(value: '대표이사', child: Text('대표이사')),
                              DropdownMenuItem(value: '센터장', child: Text('센터장')),
                              DropdownMenuItem(value: '부장', child: Text('부장')),
                              DropdownMenuItem(value: '과장', child: Text('과장')),
                            ],
                            onChanged: (v) => setState(() {
                              _position = v;
                              // 직위에 따라 역할 자동 설정
                              if (v == '시스템관리자') {
                                _role = 'system_admin';
                              } else if (v == '대표이사') {
                                _role = 'owner';
                              } else {
                                _role = 'center_manager';
                              }
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 180,
                          child: ref.watch(_sitesProvider).when(
                            data: (sites) => DropdownButtonFormField<String>(
                              initialValue: _siteId,
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                              decoration: const InputDecoration(
                                labelText: '소속 센터',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem<String>(value: null, child: Text('미지정')),
                                ...sites.map((s) => DropdownMenuItem<String>(
                                  value: s['id'] as String,
                                  child: Text(s['name'] as String),
                                )),
                              ],
                              onChanged: (v) => setState(() => _siteId = v),
                            ),
                            loading: () => const SizedBox(width: 180, height: 40, child: LinearProgressIndicator()),
                            error: (_, __) => const Text('센터 로드 실패'),
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
                          // 가입정보 메일 전송 버튼
                          if (_personalEmailController.text.trim().isNotEmpty && _selectedAccount!.email != null)
                            OutlinedButton.icon(
                              onPressed: _isSendingEmail ? null : () => _sendWelcomeEmail(),
                              icon: _isSendingEmail
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.forward_to_inbox, size: 16),
                              label: const Text('가입정보 메일 전송', style: TextStyle(fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF8D99AE),
                              ),
                            ),
                          if (_personalEmailController.text.trim().isNotEmpty && _selectedAccount!.email != null)
                            const SizedBox(width: 12),
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
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showDeleteDialog(_selectedAccount!),
                            icon: const Icon(Icons.delete_forever, size: 16),
                            label: const Text('삭제', style: TextStyle(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[700],
                              side: BorderSide(color: Colors.red[300]!),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _saveAccount,
                          icon: _isSaving
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.save, size: 16),
                          label: Text(_isNewAccount ? '계정 생성' : '저장', style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            '아래 목록에서 관리자 계정을 선택하거나\n신규 등록 버튼을 클릭하세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 14),
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

              // ── 중간: 구분선 ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    const Icon(Icons.list_alt, size: 18, color: Color(0xFF8D99AE)),
                    const SizedBox(width: 8),
                    const Text('관리자 계정목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8D99AE))),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 220,
                      height: 36,
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: '이름, 전화번호 검색...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ],
              ),
            ),
        ),
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final remaining = constraints.viewportMainAxisExtent - constraints.precedingScrollExtent;
            final tableHeight = remaining < 500 ? 500.0 : remaining;
            return SliverToBoxAdapter(child:
        SizedBox(
          height: tableHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
            child: accounts.when(
              data: (list) {
                final filtered = list.where((a) =>
                  a.name.contains(_searchQuery) || a.phone.contains(_searchQuery) || (a.email?.contains(_searchQuery) ?? false),
                ).toList();

                final columns = [
                  const TableColumnDef(label: 'No.', width: 45),
                  const TableColumnDef(label: '이름', width: 75),
                  const TableColumnDef(label: '직위', width: 80),
                  const TableColumnDef(label: '소속 센터', width: 80),
                  const TableColumnDef(label: '전화번호', width: 110),
                  const TableColumnDef(label: '로그인 아이디', width: 155),
                  const TableColumnDef(label: '개인 이메일', width: 160),
                  const TableColumnDef(label: '상태', width: 70),
                  const TableColumnDef(label: '생성일', width: 90),
                ];

                return StickyHeaderTable.wrapWithCard(
                  columns: columns,
                  rowCount: filtered.length,
                  isRowSelected: (i) => _selectedAccount?.id == filtered[i].id,
                  onRowTap: (i) => _loadAccount(filtered[i]),
                  cellBuilder: (colIndex, rowIndex) {
                    final a = filtered[rowIndex];
                    final isSelected = _selectedAccount?.id == a.id;
                    return switch (colIndex) {
                      0 => Text('${rowIndex + 1}', style: const TextStyle(fontSize: 13)),
                      1 => Text(a.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF8D99AE) : null)),
                      2 => Text(a.position ?? '-', style: const TextStyle(fontSize: 13)),
                      3 => Text(a.siteName ?? '-', style: const TextStyle(fontSize: 13)),
                      4 => Text(a.phone, style: const TextStyle(fontSize: 13)),
                      5 => Text(a.email ?? '-', style: const TextStyle(fontSize: 13)),
                      6 => Text(a.personalEmail ?? '-', style: const TextStyle(fontSize: 13)),
                      7 => _buildStatusBadge(a.isActive),
                      8 => Text(a.createdAt != null ? DateFormat('yyyy-MM-dd').format(a.createdAt!) : '-', style: const TextStyle(fontSize: 13)),
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
            );
          },
        ),
      ],
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
      AppRole.owner => (const Color(0xFF8D99AE), '대표이사'),
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
    final color = isActive ? Colors.green : Colors.grey;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          isActive ? '활성' : '비활성',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
