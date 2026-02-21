import 'package:flutter/material.dart';
import '../utils/permissions.dart';

class _MenuDestination {
  const _MenuDestination({
    required this.index,
    required this.icon,
    required this.label,
    this.isSubMenu = false,
  });
  final int index;
  final IconData icon;
  final String label;
  final bool isSubMenu;
}

// 메뉴 순서: 홈, 근로자관리, (하위)근태기록, (하위)급여관리, 설정
const _allDestinations = [
  _MenuDestination(index: 0, icon: Icons.access_time, label: '출퇴근 현황'),
  _MenuDestination(index: 1, icon: Icons.people, label: '근로자 관리'),
  _MenuDestination(index: 2, icon: Icons.list_alt, label: '근태 기록', isSubMenu: true),
  _MenuDestination(index: 3, icon: Icons.payments, label: '급여 관리 (준비중)', isSubMenu: true),
  _MenuDestination(index: 4, icon: Icons.settings, label: '설정'),
  _MenuDestination(index: 5, icon: Icons.admin_panel_settings, label: '관리자 계정관리'),
];

class SideNavDrawer extends StatelessWidget {
  const SideNavDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.role,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 역할에 따라 접근 가능한 메뉴만 필터링
    final visibleDestinations = _allDestinations
        .where((d) => canAccessMenu(role, d.index))
        .toList();

    return Container(
      width: 220,
      color: cs.surface,
      child: Column(
        children: [
          // 헤더: Workflow 로고
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.shield, size: 40, color: cs.primary),
                const SizedBox(width: 8),
                Text('Workflow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          // 메뉴 리스트
          Expanded(
            child: ListView.builder(
              itemCount: visibleDestinations.length,
              itemBuilder: (context, idx) {
                final dest = visibleDestinations[idx];
                final isSelected = selectedIndex == dest.index;

                return _buildMenuItem(
                  context: context,
                  icon: dest.icon,
                  label: dest.label,
                  isSelected: isSelected,
                  isSubMenu: dest.isSubMenu,
                  onTap: () => onDestinationSelected(dest.index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isSubMenu,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final leftPadding = isSubMenu ? 40.0 : 16.0;

    return Material(
      color: isSelected ? cs.primary.withValues(alpha: 0.12) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: EdgeInsets.only(left: leftPadding, right: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
