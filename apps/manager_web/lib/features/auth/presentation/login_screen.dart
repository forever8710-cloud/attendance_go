import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_components/ui_components.dart';
import '../../../core/utils/permissions.dart';
import '../../../core/widgets/privacy_policy_dialog.dart';
import '../providers/auth_provider.dart';
import 'password_reset_dialog.dart';

class ManagerLoginScreen extends ConsumerStatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  ConsumerState<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends ConsumerState<ManagerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  AppRole _demoRole = AppRole.systemAdmin;

  static const _emailKey = 'last_login_email';

  @override
  void initState() {
    super.initState();
    // localStorage에서 마지막 로그인 이메일 복원
    final saved = web.window.localStorage.getItem(_emailKey);
    if (saved != null && saved.isNotEmpty) {
      _emailController.text = saved;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _doLogin() {
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.loading) return;
    // 로그인 시도 시 이메일 저장
    web.window.localStorage.setItem(_emailKey, _emailController.text);
    ref.read(authProvider.notifier).signIn(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF161624) : Colors.grey[100],
      body: Column(
        children: [
          const Spacer(),
          Card(
            elevation: 4,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                const THBrandIcon(size: 64),
                const SizedBox(height: 12),
                const Text(
                  'Workflow',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'by TKholdings',
                  style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 32),
                AutofillGroup(
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email, AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: '이메일',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _doLogin(),
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(authState.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : _doLogin,
                    child: authState.status == AuthStatus.loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('로그인', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const PasswordResetRequestDialog(),
                      );
                    },
                    child: Text(
                      '비밀번호를 잊으셨나요?',
                      style: TextStyle(fontSize: 13, color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: cs.outlineVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text('데모 로그인', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AppRole>(
                        initialValue: _demoRole,
                        style: TextStyle(fontSize: 13, color: cs.onSurface),
                        decoration: const InputDecoration(
                          labelText: '역할 선택',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: AppRole.systemAdmin, child: Text('시스템관리자')),
                          DropdownMenuItem(value: AppRole.owner, child: Text('대표이사')),
                          DropdownMenuItem(value: AppRole.centerManager, child: Text('센터장')),
                        ],
                        onChanged: (v) => setState(() => _demoRole = v ?? AppRole.systemAdmin),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      onPressed: () => ref.read(authProvider.notifier).demoLogin(_demoRole),
                      child: const Text('데모 진입', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => showDialog(context: context, builder: (_) => const PrivacyPolicyDialog()),
                child: Text(
                  '개인정보처리방침',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.primary, decoration: TextDecoration.underline, decorationColor: cs.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('|', style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.3))),
              ),
              Text(
                'COPYRIGHT © 2026 TaekyungHoldings. ALL RIGHTS RESERVED.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
