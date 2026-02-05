import 'package:flutter/material.dart';
import '../utils/permissions.dart';

class _MenuDestination {
  const _MenuDestination({required this.index, required this.icon, required this.label});
  final int index;
  final IconData icon;
  final String label;
}

const _allDestinations = [
  _MenuDestination(index: 0, icon: Icons.home, label: '홈'),
  _MenuDestination(index: 1, icon: Icons.people, label: '근로자 관리'),
  _MenuDestination(index: 2, icon: Icons.list_alt, label: '근태 기록'),
  _MenuDestination(index: 3, icon: Icons.payments, label: '급여 관리'),
  _MenuDestination(index: 4, icon: Icons.settings, label: '설정'),
  _MenuDestination(index: 5, icon: Icons.manage_accounts, label: '계정 관리'),
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
    // 역할에 따라 접근 가능한 메뉴만 필터링
    final visibleDestinations = _allDestinations
        .where((d) => canAccessMenu(role, d.index))
        .toList();

    // selectedIndex를 visibleDestinations 내 순서(railIndex)로 변환
    final railIndex = visibleDestinations.indexWhere((d) => d.index == selectedIndex);
    final safeRailIndex = railIndex >= 0 ? railIndex : 0;

    return NavigationRail(
      extended: true,
      minExtendedWidth: 220,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Row(
          children: [
            SizedBox(width: 16),
            Icon(Icons.shield, size: 40, color: Colors.indigo),
            SizedBox(width: 8),
            Text('출퇴근GO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      trailing: const Expanded(child: SizedBox()),
      unselectedLabelTextStyle: const TextStyle(fontSize: 15, color: Colors.black87),
      selectedLabelTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
      destinations: visibleDestinations
          .map((d) => NavigationRailDestination(
                icon: Icon(d.icon),
                label: Text(d.label),
              ))
          .toList(),
      selectedIndex: safeRailIndex,
      onDestinationSelected: (railIdx) {
        // railIndex → 원래 menuIndex로 복원
        final menuIndex = visibleDestinations[railIdx].index;
        onDestinationSelected(menuIndex);
      },
    );
  }
}
