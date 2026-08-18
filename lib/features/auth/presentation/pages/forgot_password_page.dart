import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Masukkan email akun Anda untuk membuat token reset password.',
          ),
          const SizedBox(height: 16),
          const AppTextField(label: 'Email', prefixIcon: Icons.email_outlined),
          const SizedBox(height: 20),
          AppButton(
            label: 'Kirim Instruksi',
            icon: Icons.send_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fitur reset akan disambungkan pada tahap berikutnya.',
                  ),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Kembali ke Masuk'),
          ),
        ],
      ),
    );
  }
}
