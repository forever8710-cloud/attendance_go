/// 회사 및 센터/파트 상수 정의
class CompanyConstants {
  CompanyConstants._();

  // ── 회사 ──
  static const companies = [
    Company(code: 'BT', name: '보트랜스', type: '원청'),
    Company(code: 'TK', name: '태경홀딩스', type: '하청'),
  ];

  static String companyName(String code) =>
      companies.firstWhere((c) => c.code == code, orElse: () => companies.first).name;

  // ── 센터(사업장) ──
  static const centers = [
    SiteCenter(code: 'IC', name: '서이천'),
    SiteCenter(code: 'AS', name: '안성'),
    SiteCenter(code: 'UW', name: '의왕'),
    SiteCenter(code: 'BP', name: '부평'),
  ];

  static List<String> get centerNames => centers.map((c) => c.name).toList();

  static String centerCode(String name) =>
      centers.firstWhere((c) => c.name == name, orElse: () => centers.first).code;

  // ── 파트(직무) ──
  static const parts = [
    '지게차',
    '지게차(야간)',
    '피커',
    '피커(야간)',
    '검수',
    '사무',
  ];
}

class Company {
  const Company({required this.code, required this.name, required this.type});
  final String code;
  final String name;
  final String type;

  String get displayName => '$name($code)';
}

class SiteCenter {
  const SiteCenter({required this.code, required this.name});
  final String code;
  final String name;
}
