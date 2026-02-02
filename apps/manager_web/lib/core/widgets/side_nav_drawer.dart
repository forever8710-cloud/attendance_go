import 'package:flutter/material.dart';

class SideNavDrawer extends StatelessWidget {
  const SideNavDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
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
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('로그아웃'),
            ),
          ),
        ),
      ),
      unselectedLabelTextStyle: const TextStyle(fontSize: 15, color: Colors.black87),
      selectedLabelTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('대시보드')),
        NavigationRailDestination(icon: Icon(Icons.people), label: Text('근로자 관리')),
        NavigationRailDestination(icon: Icon(Icons.list_alt), label: Text('근태 기록')),
        NavigationRailDestination(icon: Icon(Icons.payments), label: Text('급여 관리')),
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}
