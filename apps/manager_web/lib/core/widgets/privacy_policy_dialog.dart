import 'package:flutter/material.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip, color: cs.primary),
                  const SizedBox(width: 8),
                  const Text('개인정보처리방침', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SelectableText.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13.5, height: 1.7, color: cs.onSurface),
                    children: const [
                      TextSpan(
                        text: '(주)태경홀딩스 개인정보처리방침\n\n',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '(주)태경홀딩스(이하 "회사")는 「개인정보 보호법」 제30조에 따라 '
                            '정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 '
                            '처리할 수 있도록 하기 위하여 다음과 같이 개인정보처리방침을 수립·공개합니다.\n\n',
                      ),

                      // 제1조
                      TextSpan(text: '제1조 (개인정보의 처리 목적)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '회사는 다음의 목적을 위하여 개인정보를 처리합니다.\n'
                            '① 근로자 출퇴근 관리: 근로자 식별, GPS 기반 출퇴근 기록, 근무시간 산정\n'
                            '② 급여 관리: 급여 계산, 급여 명세서 생성, 계좌 이체\n'
                            '③ 인사 관리: 근로자 인적사항 관리, 배치 관리\n'
                            '④ 서비스 운영: 관리자 계정 인증, 시스템 접근 제어\n\n',
                      ),

                      // 제2조
                      TextSpan(text: '제2조 (처리하는 개인정보 항목)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '회사는 다음의 개인정보 항목을 처리합니다.\n'
                            '① 필수항목: 성명, 전화번호, 소속 사업장, 직무\n'
                            '② 선택항목: 주민등록번호(뒷자리), 은행명, 계좌번호, 주소\n'
                            '③ 자동수집항목: 출퇴근 시각, GPS 위치정보, 접속 IP, 접속 일시\n\n',
                      ),

                      // 제3조
                      TextSpan(text: '제3조 (개인정보의 처리 및 보유기간)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '① 근로자 인적사항: 근로관계 종료 후 3년 (근로기준법)\n'
                            '② 급여 관련 정보: 근로관계 종료 후 5년 (국세기본법)\n'
                            '③ 출퇴근 기록: 근로관계 종료 후 3년 (근로기준법)\n'
                            '④ 관리자 계정 정보: 계정 삭제 시까지\n\n',
                      ),

                      // 제4조
                      TextSpan(text: '제4조 (개인정보의 제3자 제공)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '회사는 정보주체의 동의 없이 개인정보를 제3자에게 제공하지 않습니다. '
                            '다만, 다음의 경우에는 예외로 합니다.\n'
                            '① 정보주체가 사전에 동의한 경우\n'
                            '② 법률에 특별한 규정이 있는 경우\n'
                            '③ 정보주체 또는 그 법정대리인이 의사표시를 할 수 없는 상태에 있거나 '
                            '주소불명 등으로 사전 동의를 받을 수 없는 경우로서 명백히 정보주체 또는 제3자의 '
                            '급박한 생명, 신체, 재산의 이익을 위하여 필요하다고 인정되는 경우\n\n',
                      ),

                      // 제5조
                      TextSpan(text: '제5조 (개인정보의 파기)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '① 회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 '
                            '되었을 때에는 지체 없이 해당 개인정보를 파기합니다.\n'
                            '② 전자적 파일 형태의 정보는 복구 및 재생할 수 없도록 안전하게 삭제하며, '
                            '그 밖의 기록물은 파쇄 또는 소각하여 파기합니다.\n\n',
                      ),

                      // 제6조
                      TextSpan(text: '제6조 (정보주체의 권리·의무 및 행사방법)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '정보주체는 회사에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다.\n'
                            '① 개인정보 열람 요구\n'
                            '② 오류 등이 있을 경우 정정 요구\n'
                            '③ 삭제 요구\n'
                            '④ 처리정지 요구\n\n',
                      ),

                      // 제7조
                      TextSpan(text: '제7조 (개인정보의 안전성 확보 조치)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '회사는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다.\n'
                            '① 관리적 조치: 내부관리계획 수립·시행, 정기적 직원 교육\n'
                            '② 기술적 조치: 개인정보처리시스템 등의 접근권한 관리, 접근통제시스템 설치, '
                            '개인정보의 암호화, 보안프로그램 설치\n'
                            '③ 물리적 조치: 전산실, 자료보관실 등의 접근통제\n\n',
                      ),

                      // 제8조
                      TextSpan(text: '제8조 (개인정보보호 책임자)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, '
                            '개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 '
                            '아래와 같이 개인정보보호 책임자를 지정하고 있습니다.\n\n'
                            '  ▪ 개인정보보호 책임자: 김지훈\n'
                            '  ▪ 연락처: 010-3467-0422\n'
                            '  ▪ 이메일: forever8710@gmail.com\n\n',
                      ),

                      // 제9조
                      TextSpan(text: '제9조 (개인정보처리방침의 변경)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextSpan(
                        text: '이 개인정보처리방침은 2026년 2월 19일부터 적용됩니다. '
                            '변경 사항이 있을 경우 시행일 7일 전부터 공지사항을 통하여 고지할 것입니다.\n',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
