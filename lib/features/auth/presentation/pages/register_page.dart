import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    try {
      await ref
          .read(authProvider.notifier)
          .register(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            password: passwordController.text,
          );
      if (mounted) {
        context.go('/user/home');
      }
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(
            label: 'Nama',
            controller: nameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'No HP',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
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
            label: 'Daftar',
            icon: Icons.person_add_alt,
            onPressed: _register,
            isLoading: auth.isLoading,
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sudah punya akun? Masuk'),
          ),
        ],
      ),
    );
  }
}
