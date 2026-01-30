import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '출퇴근GO Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}

// ... Employee 모델 클래스는 동일 ...
class Employee {
  final int no;
  final String center, name, rank, part, phone, time, endTime, workingHours, status, note;
  Employee(this.no, this.center, this.name, this.rank, this.part, this.phone, this.time, this.endTime, this.workingHours, this.status, this.note);
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String _selectedCenter = '전체';
  String _searchQuery = "";
  int? _sortColumnIndex;
  bool _isAscending = true;
  
  final List<Employee> _allEmployees = [
    Employee(1, '서이천', '김영수', '사원', '지게차', '010-1234-0001', '08:50', '18:10', '9h 20m', '출근', '정상'),
    Employee(2, '의왕', '이민호', '대리', '사무', '010-1234-0002', '08:55', '19:30', '10h 35m', '출근', '연장 1.5h'),
    Employee(3, '부평', '최지우', '과장', '현장', '010-1234-0003', '09:10', '18:05', '8h 55m', '지각', '오전병원'),
    Employee(4, '남사', '박강성', '부장', '일용직', '010-1234-0004', '08:40', '17:40', '9h 00m', '출근', '조기출근'),
    Employee(5, '서이천', '정우성', '대표', '사무', '010-1234-0005', '09:00', '18:00', '9h 00m', '출근', '-'),
    Employee(6, '의왕', '한지민', '사원', '현장', '010-1234-0006', '-', '-', '-', '미출근', '-'),
  ];

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
      _allEmployees.sort((a, b) {
        dynamic aVal, bVal;
        if (columnIndex == 3) { aVal = a.time; bVal = b.time; }
        else if (columnIndex == 4) { aVal = a.endTime; bVal = b.endTime; }
        else if (columnIndex == 6) { aVal = a.status; bVal = b.status; }
        else { aVal = a.no; bVal = b.no; }
        return ascending ? Comparable.compare(aVal, bVal) : Comparable.compare(bVal, aVal);
      });
    });
  }

  List<Employee> get _filtered => _allEmployees.where((e) => 
    (e.name.contains(_searchQuery) || e.center.contains(_searchQuery)) && 
    (_selectedCenter == '전체' || e.center == _selectedCenter)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSideBar(),
          const VerticalDivider(width: 1, thickness: 1, color: Colors.black12), // 세로선
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),
                const Divider(height: 1, thickness: 1, color: Colors.black12), // ✨ 가로 구분선 추가!
                Expanded(child: _buildMainArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBar() {
    return NavigationRail(
      extended: true,
      minExtendedWidth: 220,
      leading: const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Icon(Icons.shield, size: 45, color: Colors.indigo)),
      unselectedLabelTextStyle: const TextStyle(fontSize: 18, color: Colors.black87),
      selectedLabelTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text('홈')),
        NavigationRailDestination(icon: Icon(Icons.people), label: Text('직원 관리')),
        NavigationRailDestination(icon: Icon(Icons.list_alt), label: Text(' ㄴ 근태대장')),
        NavigationRailDestination(icon: Icon(Icons.payments), label: Text(' ㄴ 급여대장')),
        NavigationRailDestination(icon: Icon(Icons.calendar_month), label: Text(' ㄴ 연차대장')),
        NavigationRailDestination(icon: Icon(Icons.task_alt), label: Text(' ㄴ 휴가승인')),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 60, 
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white, // 배경색을 고정하여 구분선이 더 돋보이게 함
      child: Row(children: [
        const Text('출퇴근GO Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        const Text('(주) 티케이홀딩스', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 18)),
      ]),
    );
  }

  // ... 나머지 UI 위젯 (_buildMainArea, _buildToolBar, _buildTableSection 등)은 이전과 동일 ...
  Widget _buildMainArea() {
    if (_selectedIndex == 2) return _buildAttendanceLogPage();
    return _buildHomeDashboard();
  }

  Widget _buildToolBar() {
    return Row(
      children: [
        _buildCenterDropdown(),
        const SizedBox(width: 10),
        SizedBox(
          width: 250, height: 40,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: '이름/사업장 검색...', prefixIcon: const Icon(Icons.search, size: 18),
              filled: true, fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {}, 
          icon: const Icon(Icons.download, size: 16), 
          label: const Text('엑셀 저장'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }

  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 25, 35, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('전체 근태 현황', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildToolBar(),
          const SizedBox(height: 25),
          _buildSummaryCards(),
          const SizedBox(height: 40),
          _buildTableSection("오늘의 출퇴근 요약", false),
        ],
      ),
    );
  }

  Widget _buildAttendanceLogPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 25, 35, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('근태대장 (상세 모니터링)', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildToolBar(),
          const SizedBox(height: 30),
          _buildTableSection("상세 근무 기록", true),
        ],
      ),
    );
  }

  Widget _buildTableSection(String title, bool isDetailed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('▶ $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Card(
            elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _isAscending,
              columnSpacing: 45,
              horizontalMargin: 20,
              columns: [
                const DataColumn(label: Text('No.')),
                const DataColumn(label: Text('사업장')),
                const DataColumn(label: Text('성명')),
                DataColumn(label: const Text('출근'), onSort: _onSort),
                DataColumn(label: const Text('퇴근'), onSort: _onSort),
                if (isDetailed) const DataColumn(label: Text('근무시간')),
                DataColumn(label: const Text('상태'), onSort: _onSort),
                if (isDetailed) const DataColumn(label: Text('비고')),
              ],
              rows: _filtered.map((e) => DataRow(cells: [
                DataCell(Text(e.no.toString())),
                DataCell(Text(e.center)),
                DataCell(Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(e.time)),
                DataCell(Text(e.endTime)),
                if (isDetailed) DataCell(Text(e.workingHours)),
                DataCell(_buildStatusBadge(e.status)),
                if (isDetailed) DataCell(Text(e.note)),
              ])).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Wrap(
      spacing: 15, runSpacing: 15,
      children: [
        _buildSummaryCard('전체 직원', '152명', Icons.people, Colors.blue),
        _buildSummaryCard('오늘 출근', '145명', Icons.login, Colors.green),
        _buildSummaryCard('퇴근 완료', '82명', Icons.logout, Colors.indigo),
        _buildSummaryCard('지각', '3명', Icons.warning, Colors.orange),
      ],
    );
  }

  Widget _buildSummaryCard(String t, String v, IconData i, Color c) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[100]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, color: c, size: 28), const SizedBox(height: 15),
        Text(t, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildStatusBadge(String s) {
    Color c = s == '지각' ? Colors.red : (s == '출근' ? Colors.green : Colors.grey);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Text(s, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)));
  }

  Widget _buildCenterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCenter,
          items: ['전체', '서이천', '의왕', '부평', '남사'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _selectedCenter = v!),
        ),
      ),
    );
  }
}