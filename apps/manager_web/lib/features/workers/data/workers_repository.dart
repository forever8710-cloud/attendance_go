import '../../../core/utils/company_constants.dart';
import '../../../core/utils/employee_id_generator.dart';

class WorkerRow {
  WorkerRow({
    required this.id,
    required this.name,
    required this.phone,
    required this.part,
    required this.site,
    required this.isActive,
    this.company,
    this.employeeId,
    this.ssn,
    this.gender,
    this.address,
    this.detailAddress,
    this.email,
    this.emergencyContact,
    this.resumeFile,
    this.employmentStatus,
    this.joinDate,
    this.leaveDate,
    this.position,
    this.role,
    this.job,
    this.photoUrl,
  });

  final String id, name, phone, part, site;
  bool isActive;

  // 소속 회사
  final String? company; // 회사코드: 'BT' 또는 'TK'

  // HR 카드 추가 필드
  final String? employeeId;    // 사번
  final String? ssn;           // 주민번호
  final String? gender;        // 성별
  final String? address;       // 주소 (자동검색)
  final String? detailAddress; // 나머지 주소 (동/호수 등)
  final String? email;         // 이메일
  final String? emergencyContact; // 비상연락망
  final String? resumeFile;    // 이력서 첨부
  final String? employmentStatus; // 재직상태: 정규직, 계약직, 일용직, 파견, 육아휴직
  final DateTime? joinDate;    // 입사일
  final DateTime? leaveDate;   // 퇴사일
  final String? position;      // 직위: 사원, 대리, 과장, 부장, 대표
  final String? role;          // 직책: 조장, 파트장
  final String? job;           // 직무: 지게차, 지게차(야간), 피커, 피커(야간), 검수, 사무
  final String? photoUrl;      // 사진

  WorkerRow copyWith({
    String? id,
    String? name,
    String? phone,
    String? part,
    String? site,
    bool? isActive,
    String? company,
    String? employeeId,
    String? ssn,
    String? gender,
    String? address,
    String? detailAddress,
    String? email,
    String? emergencyContact,
    String? resumeFile,
    String? employmentStatus,
    DateTime? joinDate,
    DateTime? leaveDate,
    String? position,
    String? role,
    String? job,
    String? photoUrl,
  }) {
    return WorkerRow(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      part: part ?? this.part,
      site: site ?? this.site,
      isActive: isActive ?? this.isActive,
      company: company ?? this.company,
      employeeId: employeeId ?? this.employeeId,
      ssn: ssn ?? this.ssn,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      detailAddress: detailAddress ?? this.detailAddress,
      email: email ?? this.email,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      resumeFile: resumeFile ?? this.resumeFile,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      joinDate: joinDate ?? this.joinDate,
      leaveDate: leaveDate ?? this.leaveDate,
      position: position ?? this.position,
      role: role ?? this.role,
      job: job ?? this.job,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class WorkersRepository {
  final List<WorkerRow> _workers = [
    WorkerRow(
      id: '1', company: 'BT', employeeId: 'BT-IC001', name: '김영수', phone: '010-1234-0001', part: '지게차', site: '서이천', isActive: true,
      ssn: '850115-1******', gender: '남', address: '경기도 이천시 호법면', email: 'kim@email.com',
      emergencyContact: '010-9999-0001', employmentStatus: '정규직', joinDate: DateTime(2020, 3, 1),
      position: '대리', role: '조장', job: '지게차',
    ),
    WorkerRow(
      id: '2', company: 'BT', employeeId: 'BT-UW001', name: '이민호', phone: '010-1234-0002', part: '사무', site: '의왕', isActive: true,
      ssn: '900520-1******', gender: '남', address: '경기도 의왕시 내손동', email: 'lee@email.com',
      emergencyContact: '010-9999-0002', employmentStatus: '정규직', joinDate: DateTime(2019, 5, 15),
      position: '과장', role: '파트장', job: '사무',
    ),
    WorkerRow(
      id: '3', company: 'TK', employeeId: 'TK-BP001', name: '최지우', phone: '010-1234-0003', part: '피커', site: '부평', isActive: true,
      ssn: '950812-2******', gender: '여', address: '인천시 부평구 부평동', email: 'choi@email.com',
      emergencyContact: '010-9999-0003', employmentStatus: '계약직', joinDate: DateTime(2023, 1, 10),
      position: '사원', job: '피커',
    ),
    WorkerRow(
      id: '4', company: 'TK', employeeId: 'TK-AS001', name: '박강성', phone: '010-1234-0004', part: '검수', site: '안성', isActive: true,
      ssn: '880303-1******', gender: '남', address: '경기도 안성시 공도읍', email: 'park@email.com',
      emergencyContact: '010-9999-0004', employmentStatus: '일용직', joinDate: DateTime(2024, 6, 1),
      position: '사원', job: '검수',
    ),
    WorkerRow(
      id: '5', company: 'BT', employeeId: 'BT-IC002', name: '정우성', phone: '010-1234-0005', part: '사무', site: '서이천', isActive: true,
      ssn: '780725-1******', gender: '남', address: '경기도 이천시 부발읍', email: 'jung@email.com',
      emergencyContact: '010-9999-0005', employmentStatus: '정규직', joinDate: DateTime(2015, 2, 1),
      position: '부장', role: '파트장', job: '사무',
    ),
    WorkerRow(
      id: '6', company: 'BT', employeeId: 'BT-UW002', name: '한지민', phone: '010-1234-0006', part: '피커(야간)', site: '의왕', isActive: true,
      ssn: '920410-2******', gender: '여', address: '경기도 의왕시 오전동', email: 'han@email.com',
      emergencyContact: '010-9999-0006', employmentStatus: '육아휴직', joinDate: DateTime(2021, 8, 1),
      position: '대리', job: '피커(야간)',
    ),
  ];

  Future<List<WorkerRow>> getWorkers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_workers);
  }

  Future<void> addWorker(String name, String phone, String part, String site) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _workers.add(WorkerRow(
      id: '${_workers.length + 1}',
      name: name,
      phone: phone,
      part: part,
      site: site,
      isActive: true,
    ));
  }

  Future<void> updateWorker(String id, {String? name, String? phone, String? part}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _workers.indexWhere((w) => w.id == id);
    if (idx != -1) {
      final old = _workers[idx];
      _workers[idx] = WorkerRow(
        id: old.id,
        name: name ?? old.name,
        phone: phone ?? old.phone,
        part: part ?? old.part,
        site: old.site,
        isActive: old.isActive,
      );
    }
  }

  Future<void> saveWorkerProfile(WorkerRow worker) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _workers.indexWhere((w) => w.id == worker.id);
    if (idx != -1) {
      _workers[idx] = worker;
    } else {
      _workers.add(worker);
    }
  }

  Future<void> deactivateWorker(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _workers.indexWhere((w) => w.id == id);
    if (idx != -1) _workers[idx].isActive = false;
  }

  /// 특정 회사+센터 조합의 다음 순번을 반환
  int getNextSequenceNumber(String companyCode, String centerName) {
    final centerCode = CompanyConstants.centerCode(centerName);
    final prefix = '$companyCode-$centerCode';
    int maxSeq = 0;
    for (final w in _workers) {
      if (w.employeeId != null && w.employeeId!.startsWith(prefix)) {
        final seqStr = w.employeeId!.substring(prefix.length);
        final seq = int.tryParse(seqStr) ?? 0;
        if (seq > maxSeq) maxSeq = seq;
      }
    }
    return maxSeq + 1;
  }

  /// 사번 자동생성
  String generateNextEmployeeId(String companyCode, String centerName) {
    final nextSeq = getNextSequenceNumber(companyCode, centerName);
    return EmployeeIdGenerator.generate(
      companyCode: companyCode,
      centerName: centerName,
      sequenceNumber: nextSeq,
    );
  }
}
