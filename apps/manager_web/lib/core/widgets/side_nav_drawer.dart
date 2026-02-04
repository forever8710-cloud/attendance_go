import 'package:flutter/material.dart';

class SideNavDrawer extends StatelessWidget {
  const SideNavDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

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
      trailing: const Expanded(child: SizedBox()),
      unselectedLabelTextStyle: const TextStyle(fontSize: 15, color: Colors.black87),
      selectedLabelTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text('홈')),
        NavigationRailDestination(icon: Icon(Icons.people), label: Text('근로자 관리')),
        NavigationRailDestination(icon: Icon(Icons.list_alt), label: Text('근태 기록')),
        NavigationRailDestination(icon: Icon(Icons.payments), label: Text('급여 관리')),
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}
