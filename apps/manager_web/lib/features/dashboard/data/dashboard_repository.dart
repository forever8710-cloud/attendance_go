class DashboardRepository {
  Future<DashboardSummary> getTodaySummary(String siteId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Demo data
    return DashboardSummary(
      totalWorkers: 152,
      checkedIn: 145,
      checkedOut: 82,
      late: 3,
      earlyLeave: 2,
      absent: 7,
    );
  }

  Future<List<WorkerAttendanceRow>> getTodayAttendances(String siteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      WorkerAttendanceRow(name: '김영수', position: '대리', job: '지게차', site: '서이천', phone: '010-1234-0001', checkIn: '08:50', checkOut: '18:10', workHours: '9h 20m', status: '출근', note: '정상'),
      WorkerAttendanceRow(name: '이민호', position: '과장', job: '사무', site: '의왕', phone: '010-1234-0002', checkIn: '08:55', checkOut: '19:30', workHours: '10h 35m', status: '출근', note: '연장 1.5h'),
      WorkerAttendanceRow(name: '최지우', position: '사원', job: '피커', site: '부평', phone: '010-1234-0003', checkIn: '09:10', checkOut: '18:05', workHours: '8h 55m', status: '지각', note: '오전병원'),
      WorkerAttendanceRow(name: '박강성', position: '사원', job: '검수', site: '남사', phone: '010-1234-0004', checkIn: '08:40', checkOut: '17:40', workHours: '9h 00m', status: '출근', note: '조기출근'),
      WorkerAttendanceRow(name: '정우성', position: '부장', job: '사무', site: '서이천', phone: '010-1234-0005', checkIn: '09:00', checkOut: '18:00', workHours: '9h 00m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '한지민', position: '대리', job: '피커 (야간)', site: '의왕', phone: '010-1234-0006', checkIn: '-', checkOut: '-', workHours: '-', status: '미출근', note: '-'),
      WorkerAttendanceRow(name: '송중기', position: '센터장', job: '사무', site: '서이천', phone: '010-1234-0007', checkIn: '08:30', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '김태희', position: '사원', job: '지게차 (야간)', site: '부평', phone: '010-1234-0008', checkIn: '20:00', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),
    ];
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalWorkers,
    required this.checkedIn,
    required this.checkedOut,
    required this.late,
    this.earlyLeave,
    required this.absent,
  });
  final int totalWorkers;
  final int checkedIn;
  final int checkedOut;
  final int late;
  final int? earlyLeave;
  final int absent;
}

class WorkerAttendanceRow {
  const WorkerAttendanceRow({
    required this.name,
    required this.position,
    required this.job,
    required this.site,
    required this.phone,
    required this.checkIn,
    required this.checkOut,
    required this.workHours,
    required this.status,
    required this.note,
  });
  final String name;
  final String position;  // 직위: 사원, 대리, 과장, 부장, 센터장, 대표
  final String job;       // 직무: 사무, 지게차, 피커, 검수, 지게차 (야간), 피커 (야간)
  final String site;
  final String phone;
  final String checkIn;
  final String checkOut;
  final String workHours;
  final String status;
  final String note;
}
