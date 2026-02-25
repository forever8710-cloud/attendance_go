import 'company_constants.dart';

/// 사번 자동생성 유틸리티
/// 형식: {회사코드}-{센터코드}{순번3자리}  예) BT-IC001, TK-BP001
class EmployeeIdGenerator {
  EmployeeIdGenerator._();

  static String generate({
    required String companyCode,
    required String centerName,
    required int sequenceNumber,
  }) {
    final centerCode = CompanyConstants.centerCode(centerName);
    final seq = sequenceNumber.toString().padLeft(3, '0');
    return '$companyCode-$centerCode$seq';
  }
}
