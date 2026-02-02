import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/workers_repository.dart';

final workersRepositoryProvider = Provider((ref) => WorkersRepository());

final workersProvider = FutureProvider<List<WorkerRow>>((ref) {
  return ref.watch(workersRepositoryProvider).getWorkers();
});
