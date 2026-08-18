import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await ref
          .read(authProvider.notifier)
          .login(emailController.text.trim(), passwordController.text);
      if (!mounted) return;
      final auth = ref.read(authProvider);
      context.go(auth.isAdmin ? '/admin' : '/user/home');
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.primary,
              child: Icon(Icons.forum_outlined, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              'Masuk ke Konsulify',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola booking konsultasi Anda dengan aman dan mudah.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Password',
              controller: passwordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Masuk',
              icon: Icons.login,
              onPressed: _login,
              isLoading: auth.isLoading,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.go('/forgot-password'),
                  child: const Text('Lupa Password'),
                ),
                const Text(' | '),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Daftar Akun'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'Akun admin pengembangan: admin@konsulify.test',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
