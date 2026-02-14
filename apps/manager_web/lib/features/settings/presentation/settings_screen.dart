import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
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
                      ],
                    ),
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDisplayTab(),
                          _buildNotificationTab(),
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
            color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.4),
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
}
