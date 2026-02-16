import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final worker = authState.worker;
    final profileAsync = ref.watch(workerProfileProvider);
    final siteNameAsync = ref.watch(workerSiteNameProvider);
    final partNameAsync = ref.watch(workerPartNameProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Text(
                '마이페이지',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // 프로필 헤더 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        worker?.name.isNotEmpty == true
                            ? worker!.name.substring(0, 1)
                            : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker?.name ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _roleLabel(worker?.role),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 기본정보
              _SectionTitle('기본정보'),
              const SizedBox(height: 12),
              _InfoCard(
                children: [
                  _InfoItem(
                    icon: Icons.phone_rounded,
                    label: '전화번호',
                    value: worker?.phone ?? '-',
                  ),
                  const Divider(height: 1),
                  _InfoItem(
                    icon: Icons.location_city_rounded,
                    label: '소속센터',
                    value: siteNameAsync.valueOrNull?.isNotEmpty == true
                        ? siteNameAsync.value!
                        : '-',
                  ),
                  const Divider(height: 1),
                  _InfoItem(
                    icon: Icons.work_rounded,
                    label: '파트',
                    value: partNameAsync.valueOrNull?.isNotEmpty == true
                        ? partNameAsync.value!
                        : '-',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 개인정보
              _SectionTitle('개인정보'),
              const SizedBox(height: 12),
              profileAsync.when(
                data: (profile) {
                  return _InfoCard(
                    children: [
                      _InfoItem(
                        icon: Icons.home_rounded,
                        label: '주소',
                        value: _maskAddress(profile?.address),
                      ),
                      const Divider(height: 1),
                      _InfoItem(
                        icon: Icons.account_balance_rounded,
                        label: '은행',
                        value: profile?.bank ?? '-',
                      ),
                      const Divider(height: 1),
                      _InfoItem(
                        icon: Icons.credit_card_rounded,
                        label: '계좌번호',
                        value: _maskAccount(profile?.accountNumber),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('프로필을 불러올 수 없습니다'),
              ),

              const SizedBox(height: 32),

              // 로그아웃 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    '로그아웃',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red[200]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'system_admin':
        return '시스템 관리자';
      case 'owner':
        return '대표';
      case 'center_manager':
        return '센터 관리자';
      case 'worker':
        return '근로자';
      default:
        return '근로자';
    }
  }

  String _maskAddress(String? address) {
    if (address == null || address.isEmpty) return '-';
    if (address.length <= 8) return address;
    return '${address.substring(0, 8)}****';
  }

  String _maskAccount(String? account) {
    if (account == null || account.isEmpty) return '-';
    if (account.length <= 4) return '****';
    return '${'*' * (account.length - 4)}${account.substring(account.length - 4)}';
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red[600]),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
