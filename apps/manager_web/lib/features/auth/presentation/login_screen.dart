import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/permissions.dart';
import '../providers/auth_provider.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF161624) : Colors.grey[100],
      body: Center(
        child: Card(
          elevation: 4,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield, size: 64, color: Colors.indigo),
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
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                        : () => ref.read(authProvider.notifier).signIn(
                              _emailController.text,
                              _passwordController.text,
                            ),
                    child: authState.status == AuthStatus.loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('로그인', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
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
      ),
    );
  }
}
