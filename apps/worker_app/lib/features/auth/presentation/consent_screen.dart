import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(
        title: const Text('개인정보 동의'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(authProvider.notifier).signOut(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '서비스 이용을 위해\n아래 약관에 동의해 주세요.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // 전체 동의
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      value: _allChecked,
                      onChanged: _toggleAll,
                      title: const Text(
                        '전체 동의',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
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

                  // [선택] 위치정보 이용 동의
                  CheckboxListTile(
                    value: _locationConsent,
                    onChanged: (v) => setState(() => _locationConsent = v ?? false),
                    title: const Text(
                      '[선택] 위치정보 이용 동의',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  _buildExpansionDetail(
                    children: [
                      _buildDetailRow('수집 항목', 'GPS 위치정보'),
                      _buildDetailRow('이용 목적', '출퇴근 장소 확인'),
                      _buildDetailRow('보유 기간', '출퇴근 기록 후 즉시 파기'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _personalInfoConsent
                      ? () => ref.read(authProvider.notifier).acceptConsent(
                            locationConsent: _locationConsent,
                          )
                      : null,
                  child: const Text(
                    '동의하고 계속하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionDetail({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: const Text('상세 내용 보기', style: TextStyle(fontSize: 13, color: Colors.grey)),
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
              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
