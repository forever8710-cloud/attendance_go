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

  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
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

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.indigo,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Colors.indigo,
                  tabs: const [
                    Tab(icon: Icon(Icons.admin_panel_settings, size: 20), text: '관리자 계정'),
                    Tab(icon: Icon(Icons.display_settings, size: 20), text: '화면 설정'),
                    Tab(icon: Icon(Icons.notifications, size: 20), text: '알림 설정'),
                  ],
                ),
                SizedBox(
                  height: 520,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAccountTab(),
                      _buildDisplayTab(),
                      _buildNotificationTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 탭 1: 관리자 계정 관리 ───
  Widget _buildAccountTab() {
    final admins = ref.watch(adminUsersProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 비밀번호 변경
          const Text('비밀번호 변경', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPwField('현재 비밀번호', _currentPwController)),
              const SizedBox(width: 16),
              Expanded(child: _buildPwField('새 비밀번호', _newPwController)),
              const SizedBox(width: 16),
              Expanded(child: _buildPwField('비밀번호 확인', _confirmPwController)),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
                  );
                  _currentPwController.clear();
                  _newPwController.clear();
                  _confirmPwController.clear();
                },
                child: const Text('변경'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 관리자 목록
          Row(
            children: [
              const Text('관리자 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showAddAdminDialog(),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('관리자 추가'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DataTable(
            columnSpacing: 40,
            columns: const [
              DataColumn(label: Text('이름')),
              DataColumn(label: Text('이메일')),
              DataColumn(label: Text('권한')),
              DataColumn(label: Text('상태')),
              DataColumn(label: Text('관리')),
            ],
            rows: admins.map((a) => DataRow(cells: [
              DataCell(Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(a.email)),
              DataCell(_buildRoleBadge(a.role)),
              DataCell(_buildStatusBadge(a.isActive)),
              DataCell(IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () {},
                tooltip: '수정',
              )),
            ])).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPwField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final color = role == '최고관리자' ? Colors.indigo : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(role, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        isActive ? '활성' : '비활성',
        style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddAdminDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('관리자 추가'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '권한', border: OutlineInputBorder()),
                items: ['관리자', '부관리자'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('관리자가 추가되었습니다.')));
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // ─── 탭 2: 화면 설정 ───
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
                  selectedColor: Colors.indigo.withValues(alpha: 0.2),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
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
                  selectedColor: Colors.indigo.withValues(alpha: 0.2),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(String label, IconData icon, ThemeMode mode, ThemeMode current, AppSettingsNotifier notifier) {
    final isSelected = current == mode;
    return InkWell(
      onTap: () => notifier.setThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? Colors.indigo : Colors.grey),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.indigo : null)),
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
              activeThumbColor: Colors.indigo,
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
              activeThumbColor: Colors.indigo,
            ),
          ),

          if (settings.absentAlertEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 56, top: 8, bottom: 8),
              child: Row(
                children: [
                  Text('알림 시간:', style: TextStyle(color: Colors.grey[600])),
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
            activeColor: Colors.indigo,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          CheckboxListTile(
            value: settings.emailNotificationEnabled,
            onChanged: (v) => notifier.setEmailNotificationEnabled(v!),
            title: const Text('이메일 알림'),
            subtitle: const Text('등록된 이메일로 알림을 받습니다'),
            secondary: const Icon(Icons.email),
            activeColor: Colors.indigo,
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
