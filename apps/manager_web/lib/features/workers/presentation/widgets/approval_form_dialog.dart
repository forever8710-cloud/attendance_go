import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/reference_data_provider.dart';
import '../../../../core/utils/company_constants.dart';
import '../../data/registration_repository.dart';
import '../../data/workers_repository.dart';
import '../../providers/registration_provider.dart';

/// 가입 요청 승인 폼 다이얼로그
/// 관리자가 센터/파트/직위/사번 등을 입력하여 승인
class ApprovalFormDialog extends ConsumerStatefulWidget {
  const ApprovalFormDialog({super.key, required this.request});

  final RegistrationRequest request;

  @override
  ConsumerState<ApprovalFormDialog> createState() => _ApprovalFormDialogState();
}

class _ApprovalFormDialogState extends ConsumerState<ApprovalFormDialog> {
  String? _selectedSiteName;
  String? _selectedPartName;
  String? _selectedPosition;
  String? _selectedEmploymentStatus;
  String _employeeId = '';
  bool _isLoading = false;
  bool _isGeneratingId = false;

  final _positions = ['사원', '대리', '과장', '부장', '대표'];
  final _employmentStatuses = ['정규직', '계약직', '일용직', '파견', '육아휴직'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final siteNames = ref.watch(siteNamesProvider);
    final partNames = ref.watch(partNamesProvider);
    final siteIdMap = ref.watch(siteIdByNameProvider);
    final partIdMap = ref.watch(partIdByNameProvider);
    final companyName = CompanyConstants.companyName(widget.request.company);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2B2D42),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.how_to_reg_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    '가입 승인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // 본문
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 요청자 정보 (읽기 전용)
                    const Text('요청자 정보',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2D42))),
                    const SizedBox(height: 12),
                    _infoRow('이름', widget.request.name),
                    _infoRow('전화번호', widget.request.phone),
                    _infoRow('소속회사', companyName),
                    if (widget.request.address != null)
                      _infoRow('주소',
                          '${widget.request.address ?? ''} ${widget.request.detailAddress ?? ''}'),
                    if (widget.request.ssn != null &&
                        widget.request.ssn!.isNotEmpty)
                      _infoRow('주민번호', _maskSsn(widget.request.ssn!)),
                    if (widget.request.bank != null &&
                        widget.request.bank!.isNotEmpty)
                      _infoRow('은행', widget.request.bank!),
                    if (widget.request.accountNumber != null &&
                        widget.request.accountNumber!.isNotEmpty)
                      _infoRow('계좌번호', widget.request.accountNumber!),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // 관리자 입력 필드
                    const Text('관리자 입력',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2D42))),
                    const SizedBox(height: 16),

                    // 센터 (필수)
                    _buildLabel('센터', required: true),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSiteName,
                      decoration: _dropdownDecoration(),
                      hint: const Text('센터 선택'),
                      items: siteNames
                          .map((n) =>
                              DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedSiteName = v);
                        _generateEmployeeId();
                      },
                    ),
                    const SizedBox(height: 16),

                    // 파트 (필수)
                    _buildLabel('파트', required: true),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPartName,
                      decoration: _dropdownDecoration(),
                      hint: const Text('파트 선택'),
                      items: partNames
                          .map((n) =>
                              DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPartName = v),
                    ),
                    const SizedBox(height: 16),

                    // 직위
                    _buildLabel('직위'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      decoration: _dropdownDecoration(),
                      hint: const Text('직위 선택 (선택사항)'),
                      items: _positions
                          .map((n) =>
                              DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPosition = v),
                    ),
                    const SizedBox(height: 16),

                    // 재직상태
                    _buildLabel('재직상태'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedEmploymentStatus,
                      decoration: _dropdownDecoration(),
                      hint: const Text('재직상태 선택 (선택사항)'),
                      items: _employmentStatuses
                          .map((n) =>
                              DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedEmploymentStatus = v),
                    ),
                    const SizedBox(height: 16),

                    // 사번 (자동생성)
                    _buildLabel('사번', required: true),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.badge_rounded,
                              size: 18, color: cs.primary),
                          const SizedBox(width: 10),
                          Text(
                            _isGeneratingId
                                ? '생성 중...'
                                : _employeeId.isEmpty
                                    ? '센터를 선택하면 자동생성됩니다'
                                    : _employeeId,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _employeeId.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: _employeeId.isEmpty
                                  ? cs.onSurface.withValues(alpha: 0.4)
                                  : cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _canSubmit && !_isLoading ? _submit : null,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(_isLoading ? '처리 중...' : '승인'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2B2D42),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _selectedSiteName != null &&
      _selectedPartName != null &&
      _employeeId.isNotEmpty;

  Future<void> _generateEmployeeId() async {
    if (_selectedSiteName == null) return;
    setState(() => _isGeneratingId = true);
    try {
      final repo = WorkersRepository();
      final eid = await repo.generateNextEmployeeId(
        widget.request.company,
        _selectedSiteName!,
      );
      setState(() => _employeeId = eid);
    } catch (_) {
      // 생성 실패 시 무시
    } finally {
      setState(() => _isGeneratingId = false);
    }
  }

  Future<void> _submit() async {
    final siteIdMap = ref.read(siteIdByNameProvider);
    final partIdMap = ref.read(partIdByNameProvider);

    final siteId = siteIdMap[_selectedSiteName];
    final partId = partIdMap[_selectedPartName];

    if (siteId == null || partId == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(registrationRepositoryProvider).approveRequest(
            requestId: widget.request.id,
            siteId: siteId,
            partId: partId,
            company: widget.request.company,
            employeeId: _employeeId,
            position: _selectedPosition,
            employmentStatus: _selectedEmploymentStatus,
            job: _selectedPartName,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.request.name}님의 가입이 승인되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // 목록 새로고침
      ref.invalidate(pendingRequestsProvider);
      ref.invalidate(pendingCountProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('승인 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _maskSsn(String ssn) {
    // 123456-7****** 형식으로 마스킹
    if (ssn.contains('-') && ssn.length >= 8) {
      final parts = ssn.split('-');
      return '${parts[0]}-${parts[1].substring(0, 1)}******';
    }
    if (ssn.length >= 7) {
      return '${ssn.substring(0, 6)}-${ssn.substring(6, 7)}******';
    }
    return ssn;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if (required)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 13)),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }
}
