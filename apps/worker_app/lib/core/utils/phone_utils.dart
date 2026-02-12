/// 한국 전화번호를 E.164 형식으로 변환
/// 예: '010-1234-5678' → '+821012345678'
///     '01012345678'   → '+821012345678'
String toE164(String phone) {
  // 숫자만 추출
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

  // 이미 국제번호 형식이면 그대로
  if (digits.startsWith('82')) {
    return '+$digits';
  }

  // 0으로 시작하면 0 제거 후 +82 추가
  if (digits.startsWith('0')) {
    return '+82${digits.substring(1)}';
  }

  return '+82$digits';
}

/// E.164 형식을 한국 전화번호로 변환
/// 예: '+821012345678' → '010-1234-5678'
String fromE164(String e164) {
  final digits = e164.replaceAll(RegExp(r'[^0-9]'), '');

  String local;
  if (digits.startsWith('82')) {
    local = '0${digits.substring(2)}';
  } else {
    local = digits;
  }

  if (local.length == 11) {
    return '${local.substring(0, 3)}-${local.substring(3, 7)}-${local.substring(7)}';
  }
  return local;
}
