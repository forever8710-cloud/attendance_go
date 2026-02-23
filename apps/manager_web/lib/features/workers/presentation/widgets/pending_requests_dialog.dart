import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/company_constants.dart';
import '../../data/registration_repository.dart';
import '../../providers/registration_provider.dart';
import 'approval_form_dialog.dart';

/// 가입 요청 대기 목록 다이얼로그
class PendingRequestsDialog extends ConsumerWidget {
  const PendingRequestsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRequestsProvider);
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2D42),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    '가입 요청 대기 목록',
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
              child: requestsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('오류: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
                data: (requests) {
                  if (requests.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 48, color: Colors.green),
                            SizedBox(height: 12),
                            Text('대기 중인 요청이 없습니다',
                                style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return _RequestCard(
                        request: req,
                        onApprove: () => _openApprovalForm(context, ref, req),
                        onReject: () => _showRejectDialog(context, ref, req),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openApprovalForm(
    BuildContext context,
    WidgetRef ref,
    RegistrationRequest request,
  ) {
    showDialog(
      context: context,
      builder: (_) => ApprovalFormDialog(request: request),
    ).then((_) {
      // 승인 후 목록 새로고침
      ref.invalidate(pendingRequestsProvider);
      ref.invalidate(pendingCountProvider);
    });
  }

  void _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    RegistrationRequest request,
  ) {
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
                await ref.read(registrationRepositoryProvider).rejectRequest(
                      request.id,
                      reason,
                    );
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
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final RegistrationRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final companyName =
        CompanyConstants.companyName(request.company);
    final dateStr =
        DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt.toLocal());

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 아바타
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF8D99AE).withValues(alpha: 0.15),
              child: Text(
                request.name.isNotEmpty ? request.name[0] : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2B2D42),
                ),
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
                      Text(
                        request.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '대기',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${request.phone} | $companyName | $dateStr',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (request.address != null &&
                      request.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${request.address ?? ''} ${request.detailAddress ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // 버튼
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('거부', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onApprove,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2B2D42),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('승인', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
