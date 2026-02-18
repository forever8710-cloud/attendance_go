import 'package:supabase_client/supabase_client.dart';
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
    this.bank,
    this.accountNumber,
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
  final String? bank;          // 은행
  final String? accountNumber; // 계좌번호

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
    String? bank,
    String? accountNumber,
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
      bank: bank ?? this.bank,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }
}

class WorkersRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// site_id → site_name, part_id → part_name 매핑 캐시
  Map<String, String> _siteNames = {};
  Map<String, String> _partNames = {};

  Future<void> _loadMappings() async {
    if (_siteNames.isNotEmpty) return;
    final sites = await _supabase.from('sites').select('id, name');
    _siteNames = {for (final s in sites) s['id'] as String: s['name'] as String};
    final parts = await _supabase.from('parts').select('id, name');
    _partNames = {for (final p in parts) p['id'] as String: p['name'] as String};
  }

  /// Supabase에서 workers + worker_profiles 조회
  Future<List<WorkerRow>> getWorkers() async {
    try {
      await _loadMappings();

      // workers LEFT JOIN worker_profiles
      final response = await _supabase
          .from('workers')
          .select('*, worker_profiles(*)');

      return (response as List).map((row) {
        final profile = (row['worker_profiles'] is List && (row['worker_profiles'] as List).isNotEmpty)
            ? (row['worker_profiles'] as List).first
            : null;

        final siteId = row['site_id'] as String?;
        final partId = row['part_id'] as String?;

        return WorkerRow(
          id: row['id'] as String,
          name: row['name'] as String,
          phone: row['phone'] as String,
          part: partId != null ? (_partNames[partId] ?? '') : '',
          site: siteId != null ? (_siteNames[siteId] ?? '') : '',
          isActive: row['is_active'] as bool? ?? true,
          company: profile?['company'] as String?,
          employeeId: profile?['employee_id'] as String?,
          ssn: profile?['ssn'] as String?,
          gender: profile?['gender'] as String?,
          address: profile?['address'] as String?,
          detailAddress: profile?['detail_address'] as String?,
          email: profile?['email'] as String?,
          emergencyContact: profile?['emergency_contact'] as String?,
          resumeFile: profile?['resume_file'] as String?,
          employmentStatus: profile?['employment_status'] as String?,
          joinDate: profile?['join_date'] != null ? DateTime.tryParse(profile!['join_date']) : null,
          leaveDate: profile?['leave_date'] != null ? DateTime.tryParse(profile!['leave_date']) : null,
          position: profile?['position'] as String?,
          role: profile?['title'] as String?,
          job: profile?['job'] as String?,
          photoUrl: profile?['photo_url'] as String?,
          bank: profile?['bank'] as String?,
          accountNumber: profile?['account_number'] as String?,
        );
      }).toList();
    } catch (e) {
      // 데모 로그인(non-UUID id) 시에만 빈 목록 반환
      if (e.toString().contains('invalid input syntax for type uuid')) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> addWorker(String name, String phone, String part, String site) async {
    // site_name → site_id, part_name → part_id 변환
    await _loadMappings();
    final siteId = _siteNames.entries
        .where((e) => e.value == site)
        .map((e) => e.key)
        .firstOrNull;
    final partId = _partNames.entries
        .where((e) => e.value == part)
        .map((e) => e.key)
        .firstOrNull;

    await _supabase.from('workers').insert({
      'name': name,
      'phone': phone,
      'site_id': siteId,
      'part_id': partId,
      'role': 'worker',
      'is_active': true,
    });
  }

  Future<void> updateWorker(String id, {String? name, String? phone, String? part}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (part != null) {
      await _loadMappings();
      final partId = _partNames.entries
          .where((e) => e.value == part)
          .map((e) => e.key)
          .firstOrNull;
      updates['part_id'] = partId;
    }
    if (updates.isNotEmpty) {
      await _supabase.from('workers').update(updates).eq('id', id);
    }
  }

  Future<void> saveWorkerProfile(WorkerRow worker) async {
    // workers 테이블 업데이트
    await _loadMappings();
    final siteId = _siteNames.entries
        .where((e) => e.value == worker.site)
        .map((e) => e.key)
        .firstOrNull;
    final partId = _partNames.entries
        .where((e) => e.value == worker.part)
        .map((e) => e.key)
        .firstOrNull;

    await _supabase.from('workers').update({
      'name': worker.name,
      'phone': worker.phone,
      'site_id': siteId,
      'part_id': partId,
      'is_active': worker.isActive,
    }).eq('id', worker.id);

    // worker_profiles upsert
    await _supabase.from('worker_profiles').upsert({
      'worker_id': worker.id,
      'company': worker.company,
      'employee_id': worker.employeeId,
      'ssn': worker.ssn,
      'gender': worker.gender,
      'address': worker.address,
      'detail_address': worker.detailAddress,
      'email': worker.email,
      'emergency_contact': worker.emergencyContact,
      'resume_file': worker.resumeFile,
      'employment_status': worker.employmentStatus,
      'join_date': worker.joinDate?.toIso8601String().split('T').first,
      'leave_date': worker.leaveDate?.toIso8601String().split('T').first,
      'position': worker.position,
      'title': worker.role,
      'job': worker.job,
      'photo_url': worker.photoUrl,
      'bank': worker.bank,
      'account_number': worker.accountNumber,
    }, onConflict: 'worker_id');
  }

  Future<void> deactivateWorker(String id) async {
    await _supabase.from('workers').update({'is_active': false}).eq('id', id);
  }

  /// 특정 회사+센터 조합의 다음 순번을 반환
  Future<int> getNextSequenceNumber(String companyCode, String centerName) async {
    final centerCode = CompanyConstants.centerCode(centerName);
    final prefix = '$companyCode-$centerCode';

    final response = await _supabase
        .from('worker_profiles')
        .select('employee_id')
        .like('employee_id', '$prefix%');

    int maxSeq = 0;
    for (final row in response) {
      final eid = row['employee_id'] as String?;
      if (eid != null && eid.startsWith(prefix)) {
        final seqStr = eid.substring(prefix.length);
        final seq = int.tryParse(seqStr) ?? 0;
        if (seq > maxSeq) maxSeq = seq;
      }
    }
    return maxSeq + 1;
  }

  /// 사번 자동생성
  Future<String> generateNextEmployeeId(String companyCode, String centerName) async {
    final nextSeq = await getNextSequenceNumber(companyCode, centerName);
    return EmployeeIdGenerator.generate(
      companyCode: companyCode,
      centerName: centerName,
      sequenceNumber: nextSeq,
    );
  }
}
