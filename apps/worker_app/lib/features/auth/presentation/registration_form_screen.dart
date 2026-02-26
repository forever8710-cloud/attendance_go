import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import '../../../core/services/address_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// 근로자 자가 가입 요청 폼 (동의 후 전체 정보 입력)
class RegistrationFormScreen extends ConsumerStatefulWidget {
  const RegistrationFormScreen({super.key, this.phone});

  final String? phone;

  @override
  ConsumerState<RegistrationFormScreen> createState() =>
      _RegistrationFormScreenState();
}

class _RegistrationFormScreenState
    extends ConsumerState<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _ssnFrontController = TextEditingController();
  final _ssnBackController = TextEditingController();
  final _accountNumberController = TextEditingController();
  String _selectedCompany = 'BT';
  String? _selectedBank;

  static const _banks = [
    '국민은행', '신한은행', '하나은행', '우리은행', '농협은행',
    'IBK기업은행', 'SC제일은행', '케이뱅크', '카카오뱅크', '토스뱅크',
    '대구은행', '부산은행', '경남은행', '광주은행', '전북은행',
    '제주은행', '수협은행', '산업은행', '새마을금고', '신협',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.phone != null) {
      _phoneController.text = widget.phone!;
    }
    // OAuth 사용자 정보로 이름/이메일 자동 채우기
    _prefillFromAuth();
  }

  void _prefillFromAuth() {
    final user = SupabaseService.instance.auth.currentUser;
    if (user == null) return;
    final meta = user.userMetadata;
    if (meta == null) return;

    // 카카오: full_name, name, 구글: full_name, name
    final name = meta['full_name'] as String? ??
        meta['name'] as String? ??
        meta['user_name'] as String? ??
        '';
    if (name.isNotEmpty && _nameController.text.isEmpty) {
      _nameController.text = name;
    }

    // 카카오 비즈앱: phone, 구글: phone
    final phone = user.phone ?? '';
    if (phone.isNotEmpty && _phoneController.text.isEmpty) {
      // +82 형식을 010 형식으로 변환
      if (phone.startsWith('+82')) {
        _phoneController.text = '0${phone.substring(3)}';
      } else {
        _phoneController.text = phone;
      }
    }

    // 이메일에서 이름 추출 (fallback)
    final email = meta['email'] as String? ?? user.email ?? '';
    if (_nameController.text.isEmpty && email.isNotEmpty) {
      // 이메일 앞부분을 힌트로 사용하지 않음 (정확하지 않으므로)
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _ssnFrontController.dispose();
    _ssnBackController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 주민번호 조합 (앞자리+뒷자리)
    final ssnFront = _ssnFrontController.text.trim();
    final ssnBack = _ssnBackController.text.trim();
    String? ssn;
    if (ssnFront.isNotEmpty && ssnBack.isNotEmpty) {
      ssn = '$ssnFront-$ssnBack';
    }

    await ref.read(authProvider.notifier).submitRegistration(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          company: _selectedCompany,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          detailAddress: _detailAddressController.text.trim().isEmpty
              ? null
              : _detailAddressController.text.trim(),
          ssn: ssn,
          bank: _selectedBank,
          accountNumber: _accountNumberController.text.trim().isEmpty
              ? null
              : _accountNumberController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 뒤로가기
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.person_add_rounded,
                            color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        '가입 요청',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '기본 정보를 입력하시면 관리자 승인 후\n서비스를 이용하실 수 있습니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 이름
                      _buildLabel('이름', required: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          hint: '홍길동',
                          icon: Icons.person_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return '이름을 입력해주세요';
                          if (v.trim().length < 2) return '2자 이상 입력해주세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 전화번호
                      _buildLabel('전화번호', required: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _inputDecoration(
                          hint: '01012345678',
                          icon: Icons.phone_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return '전화번호를 입력해주세요';
                          if (v.trim().length < 10) return '올바른 전화번호를 입력해주세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 소속회사
                      _buildLabel('소속회사', required: true),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCompany,
                        decoration: _inputDecoration(
                          icon: Icons.business_rounded,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'BT', child: Text('보트랜스')),
                          DropdownMenuItem(value: 'TK', child: Text('태경홀딩스')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCompany = v);
                        },
                      ),
                      const SizedBox(height: 20),

                      // 주소 (도로명주소 API 자동검색)
                      _buildLabel('주소', required: false),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showAddressSearch(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _addressController,
                            decoration: _inputDecoration(
                              hint: '터치하여 주소 검색',
                              icon: Icons.location_on_rounded,
                            ).copyWith(
                              suffixIcon: Icon(Icons.search_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _detailAddressController,
                        decoration: _inputDecoration(
                          hint: '상세주소 (동/호수)',
                          icon: Icons.apartment_rounded,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 주민등록번호
                      _buildLabel('주민등록번호', required: false),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ssnFrontController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: _inputDecoration(
                                hint: '앞 6자리',
                                icon: Icons.credit_card_rounded,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('-', style: TextStyle(fontSize: 20, color: Colors.grey)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _ssnBackController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(7),
                              ],
                              decoration: _inputDecoration(
                                hint: '뒤 7자리',
                                icon: Icons.lock_rounded,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 은행
                      _buildLabel('급여 계좌', required: false),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedBank,
                        decoration: _inputDecoration(
                          icon: Icons.account_balance_rounded,
                        ),
                        hint: const Text('은행 선택'),
                        items: _banks
                            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedBank = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _inputDecoration(
                          hint: '계좌번호 (숫자만)',
                          icon: Icons.numbers_rounded,
                        ),
                      ),

                      if (authState.errorMessage != null &&
                          authState.status != AuthStatus.pendingApproval) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 하단 제출 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          '가입 요청 제출',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  void _showAddressSearch(BuildContext context) {
    final confmKey = dotenv.env['JUSO_CONFIRM_KEY'] ?? '';
    if (confmKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('주소 검색 API가 설정되지 않았습니다. 직접 입력해주세요.')),
      );
      // API 키 없으면 수동 입력으로 전환
      setState(() {});
      return;
    }
    final service = AddressService(confmKey);

    List<AddressResult> results = [];
    bool isSearching = false;
    String lastQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> doSearch(String query) async {
              if (query.trim().length < 2) {
                setSheetState(() {
                  results = [];
                  lastQuery = query;
                });
                return;
              }
              setSheetState(() {
                isSearching = true;
                lastQuery = query;
              });
              try {
                final found = await service.search(query);
                if (lastQuery == query) {
                  setSheetState(() {
                    results = found;
                    isSearching = false;
                  });
                }
              } catch (e) {
                if (lastQuery == query) {
                  setSheetState(() {
                    results = [];
                    isSearching = false;
                  });
                }
              }
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('주소 검색',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '동이름, 도로명, 건물명으로 검색하세요',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      onChanged: doSearch,
                      decoration: InputDecoration(
                        hintText: '예: 남사면, 역삼동, 이천시',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isSearching)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                            child:
                                CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else if (results.isEmpty && lastQuery.trim().length >= 2)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: AppColors.textHint),
                              const SizedBox(height: 8),
                              Text(
                                '검색 결과가 없습니다',
                                style: TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final addr = results[i];
                            return ListTile(
                              leading: const Icon(Icons.location_on,
                                  color: AppColors.primary),
                              title: Text(
                                addr.roadAddr,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '[${addr.zipNo}] ${addr.jibunAddr}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textHint),
                                  ),
                                  if (addr.bdNm.isNotEmpty)
                                    Text(
                                      addr.bdNm,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primary),
                                    ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _addressController.text = addr.roadAddr;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration({String? hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 15),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
