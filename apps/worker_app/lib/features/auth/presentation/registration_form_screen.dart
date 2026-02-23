import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// 근로자 자가 가입 요청 폼
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
  String _selectedCompany = 'BT';

  @override
  void initState() {
    super.initState();
    if (widget.phone != null) {
      _phoneController.text = widget.phone!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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

                      // 주소
                      _buildLabel('주소', required: false),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: _inputDecoration(
                          hint: '도로명 또는 지번 주소',
                          icon: Icons.location_on_rounded,
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
