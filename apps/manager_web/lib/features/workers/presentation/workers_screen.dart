import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workers_provider.dart';
import 'widgets/worker_form_dialog.dart';

class WorkersScreen extends ConsumerStatefulWidget {
  const WorkersScreen({super.key});

  @override
  ConsumerState<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends ConsumerState<WorkersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final workers = ref.watch(workersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('근로자 관리', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: '이름, 전화번호 검색...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('근로자 등록'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          workers.when(
            data: (list) {
              final filtered = list.where((w) =>
                w.name.contains(_searchQuery) || w.phone.contains(_searchQuery),
              ).toList();

              return Align(
                alignment: Alignment.centerLeft,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DataTable(
                    columnSpacing: 36,
                    columns: const [
                      DataColumn(label: Text('No.')),
                      DataColumn(label: Text('성명')),
                      DataColumn(label: Text('전화번호')),
                      DataColumn(label: Text('파트')),
                      DataColumn(label: Text('사업장')),
                      DataColumn(label: Text('상태')),
                      DataColumn(label: Text('관리')),
                    ],
                    rows: filtered.asMap().entries.map((entry) {
                      final i = entry.key;
                      final w = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(w.phone)),
                        DataCell(Text(w.part)),
                        DataCell(Text(w.site)),
                        DataCell(_buildStatusChip(w.isActive)),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () => _showEditDialog(context, w),
                              tooltip: '수정',
                            ),
                            IconButton(
                              icon: Icon(Icons.person_off, size: 18, color: Colors.red[400]),
                              onPressed: () => _showDeleteDialog(context, w),
                              tooltip: '퇴사 처리',
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('오류: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        isActive ? '재직' : '퇴사',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => WorkerFormDialog(
        onSave: (name, phone, part) async {
          await ref.read(workersRepositoryProvider).addWorker(name, phone, part, '서이천');
          ref.invalidate(workersProvider);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic worker) {
    showDialog(
      context: context,
      builder: (_) => WorkerFormDialog(
        initialName: worker.name,
        initialPhone: worker.phone,
        initialPart: worker.part,
        onSave: (name, phone, part) async {
          await ref.read(workersRepositoryProvider).updateWorker(worker.id, name: name, phone: phone, part: part);
          ref.invalidate(workersProvider);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic worker) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('퇴사 처리'),
        content: Text('${worker.name}님을 퇴사 처리하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              await ref.read(workersRepositoryProvider).deactivateWorker(worker.id);
              ref.invalidate(workersProvider);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('퇴사 처리'),
          ),
        ],
      ),
    );
  }
}
