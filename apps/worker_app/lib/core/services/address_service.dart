import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
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
  /// 에러 시 Exception을 throw하여 호출부에서 사용자에게 피드백 가능.
  Future<List<AddressResult>> search(String keyword) async {
    if (keyword.trim().length < 2) return [];
    if (_confmKey.isEmpty) {
      throw Exception('주소 검색 API 키가 설정되지 않았습니다.');
    }

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

      if (response.statusCode != 200) {
        throw Exception('주소 검색 서버 오류 (${response.statusCode})');
      }

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
    } on TimeoutException {
      throw Exception('주소 검색 시간이 초과되었습니다. 다시 시도해주세요.');
    } on SocketException {
      throw Exception('네트워크 연결을 확인해주세요.');
    } catch (e) {
      debugPrint('AddressService.search error: $e');
      if (e is Exception) rethrow;
      throw Exception('주소 검색 중 오류가 발생했습니다.');
    }
  }
}
