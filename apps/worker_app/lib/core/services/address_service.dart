import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressResult {
  final String roadAddr;
  final String jibunAddr;
  final String zipNo;
  final String bdNm;

  const AddressResult({
    required this.roadAddr,
    required this.jibunAddr,
    required this.zipNo,
    this.bdNm = '',
  });
}

/// 행정안전부 도로명주소 API (juso.go.kr)
class AddressService {
  AddressService(this._confmKey);

  final String _confmKey;

  static const _baseUrl =
      'https://business.juso.go.kr/addrlink/addrLinkApi.do';

  /// 주소 검색 (keyword: 도로명, 지번, 건물명 등)
  Future<List<AddressResult>> search(String keyword) async {
    if (keyword.trim().length < 2) return [];
    if (_confmKey.isEmpty) return [];

    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'confmKey': _confmKey,
          'currentPage': '1',
          'countPerPage': '10',
          'keyword': keyword.trim(),
          'resultType': 'json',
        },
      );

      final response = await http.get(uri).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as Map<String, dynamic>?;
      if (results == null) return [];

      final jusoList = results['juso'] as List?;
      if (jusoList == null || jusoList.isEmpty) return [];

      return jusoList.map((j) {
        final m = j as Map<String, dynamic>;
        return AddressResult(
          roadAddr: m['roadAddr'] as String? ?? '',
          jibunAddr: m['jibunAddr'] as String? ?? '',
          zipNo: m['zipNo'] as String? ?? '',
          bdNm: m['bdNm'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
