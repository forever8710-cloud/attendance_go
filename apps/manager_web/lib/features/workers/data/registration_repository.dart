import 'package:supabase_client/supabase_client.dart';

/// 가입 요청 데이터 모델
class RegistrationRequest {
  const RegistrationRequest({
    required this.id,
    required this.authUserId,
    required this.name,
    required this.phone,
    required this.company,
    this.address,
    this.detailAddress,
    this.ssn,
    this.bank,
    this.accountNumber,
    required this.status,
    this.rejectReason,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  final String id;
  final String authUserId;
  final String name;
  final String phone;
  final String company;
  final String? address;
  final String? detailAddress;
  final String? ssn;
  final String? bank;
  final String? accountNumber;
  final String status;
  final String? rejectReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) {
    return RegistrationRequest(
      id: json['id'] as String,
      authUserId: json['auth_user_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      company: json['company'] as String,
      address: json['address'] as String?,
      detailAddress: json['detail_address'] as String?,
      ssn: json['ssn'] as String?,
      bank: json['bank'] as String?,
      accountNumber: json['account_number'] as String?,
      status: json['status'] as String,
      rejectReason: json['reject_reason'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class RegistrationRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// pending 상태의 가입 요청 목록 조회
  Future<List<RegistrationRequest>> getPendingRequests() async {
    final rows = await _supabase
        .from('registration_requests')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: true);
    return (rows as List)
        .map((r) => RegistrationRequest.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// pending 상태의 가입 요청 건수
  Future<int> getPendingCount() async {
    try {
      final rows = await _supabase
          .from('registration_requests')
          .select('id')
          .eq('status', 'pending');
      return (rows as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// 가입 요청 승인 → Edge Function 호출
  Future<void> approveRequest({
    required String requestId,
    required String siteId,
    required String partId,
    required String company,
    required String employeeId,
    String? position,
    String? employmentStatus,
    String? job,
  }) async {
    final response = await _supabase.functions.invoke(
      'approve-registration',
      body: {
        'request_id': requestId,
        'site_id': siteId,
        'part_id': partId,
        'company': company,
        'employee_id': employeeId,
        'position': position,
        'employment_status': employmentStatus,
        'job': job,
      },
    );

    if (response.status != 200) {
      final data = response.data;
      final error = data is Map ? data['error'] : 'Unknown error';
      throw Exception('승인 처리 실패: $error');
    }
  }

  /// 가입 요청 거부
  Future<void> rejectRequest(String requestId, String reason) async {
    await _supabase.from('registration_requests').update({
      'status': 'rejected',
      'reject_reason': reason,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', requestId);
  }
}
