import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/announcement_provider.dart';
import '../providers/settings_provider.dart';
import 'widgets/announcement_form_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('설정', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: const [
                        Tab(icon: Icon(Icons.display_settings, size: 20), text: '화면 설정'),
                        Tab(icon: Icon(Icons.notifications, size: 20), text: '알림 설정'),
                        Tab(icon: Icon(Icons.campaign, size: 20), text: '공지사항'),
                      ],
                    ),
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDisplayTab(),
                          _buildNotificationTab(),
                          _buildAnnouncementTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 탭 1: 화면 설정 ───
  Widget _buildDisplayTab() {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 테마
          const Text('테마', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeCard('라이트', Icons.light_mode, ThemeMode.light, settings.themeMode, notifier),
              const SizedBox(width: 16),
              _buildThemeCard('다크', Icons.dark_mode, ThemeMode.dark, settings.themeMode, notifier),
              const SizedBox(width: 16),
              _buildThemeCard('시스템', Icons.settings_brightness, ThemeMode.system, settings.themeMode, notifier),
            ],
          ),
          const SizedBox(height: 32),

          // 폰트 크기
          const Text('폰트 크기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: FontSizeOption.values.map((option) {
              final isSelected = settings.fontSize == option;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text('${option.label} (${option == FontSizeOption.small ? "13px" : option == FontSizeOption.medium ? "15px" : "17px"})'),
                  selected: isSelected,
                  onSelected: (_) => notifier.setFontSize(option),
                  selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '미리보기: 이 텍스트는 현재 선택된 폰트 크기로 표시됩니다.',
              style: TextStyle(fontSize: settings.fontSizeValue),
            ),
          ),
          const SizedBox(height: 32),

          // 테이블 표시 건수
          const Text('테이블 표시 건수', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [10, 20, 50].map((count) {
              final isSelected = settings.tableRowsPerPage == count;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text('${count}건'),
                  selected: isSelected,
                  onSelected: (_) => notifier.setTableRowsPerPage(count),
                  selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(String label, IconData icon, ThemeMode mode, ThemeMode current, AppSettingsNotifier notifier) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = current == mode;
    return InkWell(
      onTap: () => notifier.setThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.12) : cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? cs.primary : cs.onSurface)),
          ],
        ),
      ),
    );
  }

  // ─── 탭 3: 알림 설정 ───
  Widget _buildNotificationTab() {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('알림 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // 지각 알림
          _buildSettingTile(
            icon: Icons.warning_amber,
            color: Colors.orange,
            title: '지각 알림',
            subtitle: '근로자 지각 발생 시 알림을 받습니다',
            trailing: Switch(
              value: settings.lateAlertEnabled,
              onChanged: notifier.setLateAlertEnabled,
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(height: 1),

          // 미출근 알림
          _buildSettingTile(
            icon: Icons.person_off,
            color: Colors.red,
            title: '미출근 알림',
            subtitle: '설정된 시간까지 출근하지 않은 근로자를 알립니다',
            trailing: Switch(
              value: settings.absentAlertEnabled,
              onChanged: notifier.setAbsentAlertEnabled,
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ),

          if (settings.absentAlertEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 56, top: 8, bottom: 8),
              child: Row(
                children: [
                  Text('알림 시간:', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text('${settings.absentAlertTime.hour.toString().padLeft(2, '0')}:${settings.absentAlertTime.minute.toString().padLeft(2, '0')}'),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: settings.absentAlertTime,
                      );
                      if (time != null) notifier.setAbsentAlertTime(time);
                    },
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 1),
          const SizedBox(height: 24),

          // 알림 수신 방법
          const Text('알림 수신 방법', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: settings.webNotificationEnabled,
            onChanged: (v) => notifier.setWebNotificationEnabled(v!),
            title: const Text('웹 알림'),
            subtitle: const Text('브라우저 푸시 알림을 통해 받습니다'),
            secondary: const Icon(Icons.web),
            activeColor: Theme.of(context).colorScheme.primary,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          CheckboxListTile(
            value: settings.emailNotificationEnabled,
            onChanged: (v) => notifier.setEmailNotificationEnabled(v!),
            title: const Text('이메일 알림'),
            subtitle: const Text('등록된 이메일로 알림을 받습니다'),
            secondary: const Icon(Icons.email),
            activeColor: Theme.of(context).colorScheme.primary,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
    );
  }

  // ─── 탭 3: 공지사항 관리 ───
  Widget _buildAnnouncementTab() {
    final announcementsAsync = ref.watch(announcementsProvider);
    final sitesAsync = ref.watch(sitesProvider);
    final sites = sitesAsync.valueOrNull ?? [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('공지사항 관리', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showAnnouncementForm(sites: sites),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('새 공지'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: announcementsAsync.when(
              data: (announcements) {
                if (announcements.isEmpty) {
                  return const Center(
                    child: Text('등록된 공지사항이 없습니다.', style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.separated(
                  itemCount: announcements.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final a = announcements[index];
                    final createdAt = a['created_at'] != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(a['created_at'] as String).toLocal())
                        : '';
                    final isActive = a['is_active'] as bool? ?? true;
                    final siteId = a['site_id'] as String?;
                    final siteName = siteId != null
                        ? sites.where((s) => s['id'] == siteId).map((s) => s['name']).firstOrNull ?? '지정됨'
                        : '전체';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive
                            ? Colors.indigo.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.campaign,
                          color: isActive ? Colors.indigo : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        a['title'] as String? ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? null : Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        '$createdAt · 대상: $siteName${!isActive ? ' · 비활성' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) =>
                            _handleAnnouncementAction(action, a, sites),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('수정')),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(isActive ? '비활성화' : '활성화'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAnnouncementForm({
    required List<Map<String, String>> sites,
    Map<String, dynamic>? existing,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AnnouncementFormDialog(
        initialTitle: existing?['title'] as String?,
        initialContent: existing?['content'] as String?,
        initialSiteId: existing?['site_id'] as String?,
        sites: sites,
        isEdit: existing != null,
      ),
    );

    if (result != null && mounted) {
      try {
        final repo = ref.read(announcementRepositoryProvider);
        if (existing != null) {
          await repo.updateAnnouncement(
            existing['id'] as String,
            title: result['title'] as String?,
            content: result['content'] as String?,
            siteId: result['siteId'] as String?,
          );
        } else {
          await repo.createAnnouncement(
            title: result['title'] as String,
            content: result['content'] as String,
            siteId: result['siteId'] as String?,
          );
        }
        ref.invalidate(announcementsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(existing != null ? '공지사항이 수정되었습니다.' : '공지사항이 등록되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleAnnouncementAction(
    String action,
    Map<String, dynamic> announcement,
    List<Map<String, String>> sites,
  ) async {
    final repo = ref.read(announcementRepositoryProvider);
    try {
      switch (action) {
        case 'edit':
          await _showAnnouncementForm(sites: sites, existing: announcement);
          return;
        case 'toggle':
          final current = announcement['is_active'] as bool? ?? true;
          await repo.updateAnnouncement(announcement['id'] as String, isActive: !current);
          break;
        case 'delete':
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('공지사항 삭제'),
              content: const Text('이 공지사항을 삭제하시겠습니까?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('삭제'),
                ),
              ],
            ),
          );
          if (confirmed != true) return;
          await repo.deleteAnnouncement(announcement['id'] as String);
          break;
      }
      ref.invalidate(announcementsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('처리되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }
}
