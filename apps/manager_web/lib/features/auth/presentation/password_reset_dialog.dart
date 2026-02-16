import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// 비밀번호 재설정 링크 요청 다이얼로그 (로그인 화면에서 사용)
class PasswordResetRequestDialog extends ConsumerStatefulWidget {
  const PasswordResetRequestDialog({super.key});

  @override
  ConsumerState<PasswordResetRequestDialog> createState() => _PasswordResetRequestDialogState();
}

class _PasswordResetRequestDialogState extends ConsumerState<PasswordResetRequestDialog> {
  final _emailController = TextEditingController();
  bool _isSending = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = '이메일을 입력하세요.');
      return;
    }

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      final redirectTo = Uri.base.origin;
      await ref.read(authProvider.notifier).resetPassword(email, redirectTo: redirectTo);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호 재설정 링크가 이메일로 발송되었습니다.')),
        );
      }
    } catch (e) {
      setState(() => _error = '발송 실패: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('비밀번호 재설정', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('등록된 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _isSending ? null : _sendResetEmail,
          child: _isSending
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('발송'),
        ),
      ],
    );
  }
}

/// 새 비밀번호 설정 다이얼로그 (recovery 콜백 시 사용)
class PasswordChangeDialog extends ConsumerStatefulWidget {
  const PasswordChangeDialog({super.key});

  @override
  ConsumerState<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends ConsumerState<PasswordChangeDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final newPw = _newPasswordController.text;
    final confirm = _confirmController.text;

    if (newPw.isEmpty || confirm.isEmpty) {
      setState(() => _error = '모든 필드를 입력하세요.');
      return;
    }
    if (newPw.length < 6) {
      setState(() => _error = '비밀번호는 6자 이상이어야 합니다.');
      return;
    }
    if (newPw != confirm) {
      setState(() => _error = '비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).updatePassword(newPw);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
        );
      }
    } catch (e) {
      setState(() => _error = '변경 실패: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 비밀번호 설정', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('새로운 비밀번호를 입력하세요.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '새 비밀번호',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                helperText: '6자 이상',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(authProvider.notifier).clearRecovery();
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _changePassword,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('변경'),
        ),
      ],
    );
  }
}
