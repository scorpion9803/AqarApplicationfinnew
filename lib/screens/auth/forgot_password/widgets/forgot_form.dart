import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class ForgotForm extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSend;

  const ForgotForm({
    super.key,
    required this.emailController,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppTheme.textLight),
          decoration: InputDecoration(
            labelText: 'البريد الإلكتروني',
            labelStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.goldAccent),
            filled: true,
            fillColor: AppTheme.fieldBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.goldAccent, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 30),
        isLoading
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent))
            : SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: AppTheme.secondaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إرسال رمز التفعيل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}