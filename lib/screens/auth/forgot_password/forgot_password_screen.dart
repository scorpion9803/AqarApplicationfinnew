import 'package:flutter/material.dart';
import '../../../services/auth_service.dart'; // استخدام الخدمة الجديدة النظيفة
import '../../../theme/app_theme.dart';
import '../reset_password/reset_password_confirm_screen.dart';

import 'widgets/forgot_header.dart';
import 'widgets/forgot_app_bar.dart';
import 'widgets/forgot_form.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // نفس منطق العمل الأصلي تماماً
  void _sendOTP() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showCustomSnackBar('الرجاء إدخال البريد الإلكتروني', Colors.orangeAccent);
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.requestPasswordResetOTP(email);
    setState(() => _isLoading = false);

    if (result.containsKey('error')) {
      _showCustomSnackBar(result['error'], Colors.redAccent);
    } else {
      _showCustomSnackBar(result['message'] ?? 'تم إرسال رمز الاستعادة بنجاح.', Colors.green);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordConfirmScreen(email: email)));
      }
    }
  }

  void _showCustomSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.textLight)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const ForgotAppBar(), // استدعاء ويدجت البار العلوي
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      children: [
                        const ForgotHeader(), // استدعاء ويدجت الهيدر
                        ForgotForm( // استدعاء ويدجت الفورم مع تمرير القيم
                          emailController: _emailController,
                          isLoading: _isLoading,
                          onSend: _sendOTP,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}