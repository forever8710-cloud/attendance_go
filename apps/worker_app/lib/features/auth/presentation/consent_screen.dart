import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _personalInfoConsent = false;
  bool _locationConsent = false;

  bool get _allChecked => _personalInfoConsent && _locationConsent;

  void _toggleAll(bool? value) {
    setState(() {
      _personalInfoConsent = value ?? false;
      _locationConsent = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 뒤로가기
                    GestureDetector(
                      onTap: () => ref.read(authProvider.notifier).signOut(),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      '서비스 이용을 위해\n아래 약관에 동의해 주세요.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 전체 동의
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: CheckboxListTile(
                        value: _allChecked,
                        onChanged: _toggleAll,
                        title: const Text(
                          '전체 동의',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 8),

                    // [필수] 개인정보 수집·이용 동의
                    CheckboxListTile(
                      value: _personalInfoConsent,
                      onChanged: (v) => setState(() => _personalInfoConsent = v ?? false),
                      title: const Text(
                        '[필수] 개인정보 수집·이용 동의',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    _buildExpansionDetail(
                      children: [
                        _buildDetailRow('수집 항목', '이름, 전화번호, 주민등록번호, 주소, 계좌정보'),
                        _buildDetailRow('수집 목적', '근로계약 관리, 급여 지급, 인사관리'),
                        _buildDetailRow('보유 기간', '근로관계 종료 후 3년'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // [필수] 위치정보 이용 동의
                    CheckboxListTile(
                      value: _locationConsent,
                      onChanged: (v) => setState(() => _locationConsent = v ?? false),
                      title: const Text(
                        '[필수] 위치정보 이용 동의',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    _buildExpansionDetail(
                      children: [
                        _buildDetailRow('수집 항목', 'GPS 위치정보'),
                        _buildDetailRow('이용 목적', '출퇴근 장소 확인 (근무지 반경 내 확인)'),
                        _buildDetailRow('수집 시점', '출근·퇴근 버튼 누를 때만 수집'),
                        _buildDetailRow('보유 기간', '출퇴근 기록 저장 후 좌표 즉시 파기'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _allChecked
                      ? () => ref.read(authProvider.notifier).acceptConsent(
                            locationConsent: _locationConsent,
                          )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '동의하고 계속하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionDetail({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: ExpansionTile(
        title: const Text(
          '상세 내용 보기',
          style: TextStyle(fontSize: 13, color: AppColors.textHint),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
