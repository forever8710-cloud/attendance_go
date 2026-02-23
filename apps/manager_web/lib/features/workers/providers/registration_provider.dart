import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/registration_repository.dart';

final registrationRepositoryProvider =
    Provider((ref) => RegistrationRepository());

/// pending 상태의 가입 요청 목록
final pendingRequestsProvider =
    FutureProvider.autoDispose<List<RegistrationRequest>>((ref) {
  return ref.watch(registrationRepositoryProvider).getPendingRequests();
});

/// pending 상태의 가입 요청 건수
final pendingCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(registrationRepositoryProvider).getPendingCount();
});
