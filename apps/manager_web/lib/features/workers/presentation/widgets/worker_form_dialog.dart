import 'package:flutter/material.dart';

class WorkerFormDialog extends StatefulWidget {
  const WorkerFormDialog({
    super.key,
    this.initialName,
    this.initialPhone,
    this.initialPart,
    required this.onSave,
  });

  final String? initialName;
  final String? initialPhone;
  final String? initialPart;
  final Future<void> Function(String name, String phone, String part) onSave;

  @override
  State<WorkerFormDialog> createState() => _WorkerFormDialogState();
}

class _WorkerFormDialogState extends State<WorkerFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String _selectedPart = '현장';
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _selectedPart = widget.initialPart ?? '현장';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialName != null;

    return AlertDialog(
      title: Text(isEdit ? '근로자 수정' : '근로자 등록'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.length < 2) return '이름을 2자 이상 입력하세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '전화번호', hintText: '010-1234-5678', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return '전화번호를 입력하세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPart,
                decoration: const InputDecoration(labelText: '파트', border: OutlineInputBorder()),
                items: ['현장', '사무', '지게차', '일용직']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPart = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _saving = true);
                  await widget.onSave(_nameController.text, _phoneController.text, _selectedPart);
                  if (context.mounted) Navigator.pop(context);
                },
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isEdit ? '수정' : '등록'),
        ),
      ],
    );
  }
}
