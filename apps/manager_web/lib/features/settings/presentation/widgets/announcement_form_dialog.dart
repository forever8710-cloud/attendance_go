import 'package:flutter/material.dart';

class AnnouncementFormDialog extends StatefulWidget {
  const AnnouncementFormDialog({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.initialSiteId,
    this.sites = const [],
    this.isEdit = false,
  });

  final String? initialTitle;
  final String? initialContent;
  final String? initialSiteId;
  final List<Map<String, String>> sites;
  final bool isEdit;

  @override
  State<AnnouncementFormDialog> createState() => _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends State<AnnouncementFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedSiteId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? '');
    _selectedSiteId = widget.initialSiteId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.campaign, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(widget.isEdit ? '공지사항 수정' : '공지사항 작성'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                validator: (v) => (v == null || v.trim().isEmpty) ? '제목을 입력해주세요' : null,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty) ? '내용을 입력해주세요' : null,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _selectedSiteId,
                decoration: const InputDecoration(
                  labelText: '대상 사업장',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('전체 (모든 사업장)')),
                  ...widget.sites.map((s) => DropdownMenuItem(
                        value: s['id'],
                        child: Text(s['name'] ?? ''),
                      )),
                ],
                onChanged: (v) => setState(() => _selectedSiteId = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'title': _titleController.text.trim(),
                'content': _contentController.text.trim(),
                'siteId': _selectedSiteId,
              });
            }
          },
          child: Text(widget.isEdit ? '수정' : '등록'),
        ),
      ],
    );
  }
}
