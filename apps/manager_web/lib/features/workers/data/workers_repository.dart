class WorkerRow {
  WorkerRow({required this.id, required this.name, required this.phone, required this.part, required this.site, required this.isActive});
  final String id, name, phone, part, site;
  bool isActive;
}

class WorkersRepository {
  final List<WorkerRow> _workers = [
    WorkerRow(id: '1', name: '김영수', phone: '010-1234-0001', part: '지게차', site: '서이천', isActive: true),
    WorkerRow(id: '2', name: '이민호', phone: '010-1234-0002', part: '사무', site: '의왕', isActive: true),
    WorkerRow(id: '3', name: '최지우', phone: '010-1234-0003', part: '현장', site: '부평', isActive: true),
    WorkerRow(id: '4', name: '박강성', phone: '010-1234-0004', part: '일용직', site: '남사', isActive: true),
    WorkerRow(id: '5', name: '정우성', phone: '010-1234-0005', part: '사무', site: '서이천', isActive: true),
    WorkerRow(id: '6', name: '한지민', phone: '010-1234-0006', part: '현장', site: '의왕', isActive: true),
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

  Future<void> deactivateWorker(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _workers.indexWhere((w) => w.id == id);
    if (idx != -1) _workers[idx].isActive = false;
  }
}
