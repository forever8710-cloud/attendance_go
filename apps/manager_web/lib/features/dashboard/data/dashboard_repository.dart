class DashboardRepository {
  Future<DashboardSummary> getTodaySummary(String siteId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Demo data — 50명 기준 요약
    return DashboardSummary(
      totalWorkers: 50,
      checkedIn: 45,
      checkedOut: 28,
      late: 4,
      earlyLeave: 3,
      absent: 5,
    );
  }

  Future<List<WorkerAttendanceRow>> getTodayAttendances(String siteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      // ── 서이천 (14명) ──
      WorkerAttendanceRow(name: '김영수', position: '대리', job: '지게차', site: '서이천', phone: '010-1234-0001', checkIn: '08:50', checkOut: '18:10', workHours: '9h 20m', status: '출근', note: '정상'),
      WorkerAttendanceRow(name: '정우성', position: '부장', job: '사무', site: '서이천', phone: '010-1234-0005', checkIn: '09:00', checkOut: '18:00', workHours: '9h 00m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '송중기', position: '센터장', job: '사무', site: '서이천', phone: '010-1234-0007', checkIn: '08:30', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '강동원', position: '사원', job: '지게차', site: '서이천', phone: '010-1234-0009', checkIn: '08:45', checkOut: '18:05', workHours: '9h 20m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '조인성', position: '대리', job: '피커', site: '서이천', phone: '010-1234-0010', checkIn: '09:15', checkOut: '18:00', workHours: '8h 45m', status: '지각', note: '교통체증'),
      WorkerAttendanceRow(name: '유아인', position: '사원', job: '검수', site: '서이천', phone: '010-1234-0011', checkIn: '08:55', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '임시완', position: '사원', job: '피커', site: '서이천', phone: '010-1234-0012', checkIn: '08:40', checkOut: '18:00', workHours: '9h 20m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '서강준', position: '사원', job: '지게차(야간)', site: '서이천', phone: '010-1234-0013', checkIn: '20:00', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),
      WorkerAttendanceRow(name: '남주혁', position: '사원', job: '피커(야간)', site: '서이천', phone: '010-1234-0014', checkIn: '20:05', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),
      WorkerAttendanceRow(name: '박보검', position: '사원', job: '검수', site: '서이천', phone: '010-1234-0015', checkIn: '-', checkOut: '-', workHours: '-', status: '미출근', note: '병가'),
      WorkerAttendanceRow(name: '김수현', position: '과장', job: '사무', site: '서이천', phone: '010-1234-0016', checkIn: '08:50', checkOut: '15:30', workHours: '6h 40m', status: '조퇴', note: '조퇴(병원)'),
      WorkerAttendanceRow(name: '윤성빈', position: '사원', job: '지게차', site: '서이천', phone: '010-1234-0017', checkIn: '08:58', checkOut: '18:00', workHours: '9h 02m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '장기용', position: '사원', job: '피커', site: '서이천', phone: '010-1234-0018', checkIn: '08:42', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '권혁수', position: '대리', job: '지게차', site: '서이천', phone: '010-1234-0019', checkIn: '08:35', checkOut: '18:10', workHours: '9h 35m', status: '출근', note: '-'),

      // ── 안성 (12명) ──
      WorkerAttendanceRow(name: '박강성', position: '사원', job: '검수', site: '안성', phone: '010-1234-0004', checkIn: '08:40', checkOut: '17:40', workHours: '9h 00m', status: '출근', note: '조기출근'),
      WorkerAttendanceRow(name: '황정민', position: '센터장', job: '사무', site: '안성', phone: '010-1234-0020', checkIn: '08:25', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '오달수', position: '과장', job: '사무', site: '안성', phone: '010-1234-0021', checkIn: '08:50', checkOut: '18:00', workHours: '9h 10m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '하정우', position: '대리', job: '지게차', site: '안성', phone: '010-1234-0022', checkIn: '08:55', checkOut: '18:05', workHours: '9h 10m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '마동석', position: '사원', job: '지게차', site: '안성', phone: '010-1234-0023', checkIn: '08:30', checkOut: '18:00', workHours: '9h 30m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '이정재', position: '부장', job: '사무', site: '안성', phone: '010-1234-0024', checkIn: '09:00', checkOut: '19:00', workHours: '10h 00m', status: '출근', note: '연장 1h'),
      WorkerAttendanceRow(name: '류준열', position: '사원', job: '피커', site: '안성', phone: '010-1234-0025', checkIn: '-', checkOut: '-', workHours: '-', status: '미출근', note: '무단결근'),
      WorkerAttendanceRow(name: '전미도', position: '사원', job: '피커', site: '안성', phone: '010-1234-0026', checkIn: '08:48', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '김고은', position: '사원', job: '검수', site: '안성', phone: '010-1234-0027', checkIn: '08:52', checkOut: '18:00', workHours: '9h 08m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '배수지', position: '사원', job: '피커(야간)', site: '안성', phone: '010-1234-0028', checkIn: '20:00', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),
      WorkerAttendanceRow(name: '손예진', position: '대리', job: '검수', site: '안성', phone: '010-1234-0029', checkIn: '08:45', checkOut: '15:00', workHours: '6h 15m', status: '조퇴', note: '조퇴(가사)'),
      WorkerAttendanceRow(name: '이준기', position: '사원', job: '지게차(야간)', site: '안성', phone: '010-1234-0030', checkIn: '20:10', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),

      // ── 의왕 (12명) ──
      WorkerAttendanceRow(name: '이민호', position: '과장', job: '사무', site: '의왕', phone: '010-1234-0002', checkIn: '08:55', checkOut: '19:30', workHours: '10h 35m', status: '출근', note: '연장 1.5h'),
      WorkerAttendanceRow(name: '한지민', position: '대리', job: '피커(야간)', site: '의왕', phone: '010-1234-0006', checkIn: '-', checkOut: '-', workHours: '-', status: '미출근', note: '육아휴직'),
      WorkerAttendanceRow(name: '공유', position: '센터장', job: '사무', site: '의왕', phone: '010-1234-0031', checkIn: '08:30', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '현빈', position: '대리', job: '지게차', site: '의왕', phone: '010-1234-0032', checkIn: '08:50', checkOut: '18:00', workHours: '9h 10m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '이병헌', position: '부장', job: '사무', site: '의왕', phone: '010-1234-0033', checkIn: '09:20', checkOut: '18:00', workHours: '8h 40m', status: '지각', note: '지하철 지연'),
      WorkerAttendanceRow(name: '김혜수', position: '대리', job: '검수', site: '의왕', phone: '010-1234-0034', checkIn: '08:48', checkOut: '18:05', workHours: '9h 17m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '전지현', position: '사원', job: '피커', site: '의왕', phone: '010-1234-0035', checkIn: '08:55', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '송혜교', position: '사원', job: '피커', site: '의왕', phone: '010-1234-0036', checkIn: '08:40', checkOut: '18:00', workHours: '9h 20m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '안성기', position: '사원', job: '지게차', site: '의왕', phone: '010-1234-0037', checkIn: '-', checkOut: '-', workHours: '-', status: '미출근', note: '연차'),
      WorkerAttendanceRow(name: '유해진', position: '사원', job: '지게차(야간)', site: '의왕', phone: '010-1234-0038', checkIn: '20:00', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),
      WorkerAttendanceRow(name: '박서준', position: '사원', job: '검수', site: '의왕', phone: '010-1234-0039', checkIn: '08:58', checkOut: '14:30', workHours: '5h 32m', status: '조퇴', note: '조퇴(개인사유)'),
      WorkerAttendanceRow(name: '정해인', position: '사원', job: '피커(야간)', site: '의왕', phone: '010-1234-0040', checkIn: '20:15', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),

      // ── 부평 (12명) ──
      WorkerAttendanceRow(name: '최지우', position: '사원', job: '피커', site: '부평', phone: '010-1234-0003', checkIn: '09:10', checkOut: '18:05', workHours: '8h 55m', status: '지각', note: '오전병원'),
      WorkerAttendanceRow(name: '김태희', position: '사원', job: '지게차(야간)', site: '부평', phone: '010-1234-0008', checkIn: '20:00', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),
      WorkerAttendanceRow(name: '이성민', position: '센터장', job: '사무', site: '부평', phone: '010-1234-0041', checkIn: '08:20', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '조정석', position: '과장', job: '사무', site: '부평', phone: '010-1234-0042', checkIn: '08:55', checkOut: '18:10', workHours: '9h 15m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '김우빈', position: '대리', job: '지게차', site: '부평', phone: '010-1234-0043', checkIn: '08:45', checkOut: '18:00', workHours: '9h 15m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '이도현', position: '사원', job: '피커', site: '부평', phone: '010-1234-0044', checkIn: '08:50', checkOut: '-', workHours: '-', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '위하준', position: '사원', job: '검수', site: '부평', phone: '010-1234-0045', checkIn: '08:38', checkOut: '18:00', workHours: '9h 22m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '김선호', position: '사원', job: '지게차', site: '부평', phone: '010-1234-0046', checkIn: '09:12', checkOut: '18:00', workHours: '8h 48m', status: '지각', note: '버스지연'),
      WorkerAttendanceRow(name: '고수', position: '대리', job: '사무', site: '부평', phone: '010-1234-0047', checkIn: '08:50', checkOut: '18:00', workHours: '9h 10m', status: '출근', note: '-'),
      WorkerAttendanceRow(name: '문소리', position: '사원', job: '피커(야간)', site: '부평', phone: '010-1234-0048', checkIn: '20:00', checkOut: '-', workHours: '-', status: '출근', note: '야간근무'),
      WorkerAttendanceRow(name: '배두나', position: '사원', job: '검수', site: '부평', phone: '010-1234-0049', checkIn: '-', checkOut: '-', workHours: '-', status: '미출근', note: '경조사'),
      WorkerAttendanceRow(name: '허준호', position: '사원', job: '피커', site: '부평', phone: '010-1234-0050', checkIn: '08:42', checkOut: '18:00', workHours: '9h 18m', status: '출근', note: '-'),
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
