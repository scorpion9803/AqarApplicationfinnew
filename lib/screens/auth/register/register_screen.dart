import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../verify_code/verify_code_screen.dart';

import 'widgets/register_step_one.dart';
import 'widgets/register_step_two.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1;
  final AuthService _authService = AuthService();

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  String _accountType = 'normal';
  bool _isLoading = false;
  bool _obscure1 = true, _obscure2 = true;

  @override
  void dispose() {
    for (var c in [_usernameController, _emailController, _phoneController, _passwordController, _password2Controller]) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Logic ---
  Future<void> _handleRegister() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    final result = await _authService.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      password2: _password2Controller.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text.trim() : null,
      accountType: _accountType,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.containsKey('error')) {
      _showSnack(result['error'], Colors.redAccent);
    } else {
      _showSnack('تم إنشاء الحساب بنجاح!', Colors.green);
      Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: _emailController.text.trim())));
    }
  }

  bool _validate() {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack('الرجاء ملء الحقول الإلزامية', Colors.orangeAccent);
      return false;
    }
    if (_passwordController.text != _password2Controller.text) {
      _showSnack('كلمتا المرور غير متطابقتين', Colors.redAccent);
      return false;
    }
    return true;
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryDark, AppTheme.secondaryDark], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 1
                        ? RegisterStepOne(
                      accountType: _accountType,
                      onTypeSelected: (val) => setState(() => _accountType = val),
                      onNext: () => setState(() => _currentStep = 2),
                    )
                        : RegisterStepTwo(
                      accountType: _accountType,
                      isLoading: _isLoading,
                      onSubmit: _handleRegister,
                      fields: _buildFields(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textLight, size: 20),
            onPressed: () => _currentStep == 2 ? setState(() => _currentStep = 1) : Navigator.pop(context),
          ),
          Text(_currentStep == 1 ? 'نوع العضوية' : 'بيانات الحساب', style: const TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Widget> _buildFields() {
    return [
      _input(_usernameController, 'اسم المستخدم', Icons.person_outline),
      const SizedBox(height: 16),
      _input(_emailController, 'البريد الإلكتروني', Icons.email_outlined, type: TextInputType.emailAddress),
      const SizedBox(height: 16),
      _input(_phoneController, 'رقم الهاتف (اختياري)', Icons.phone_android_outlined, type: TextInputType.phone),
      const SizedBox(height: 16),
      _input(_passwordController, 'كلمة المرور', Icons.lock_outline, isPass: true, obs: _obscure1, onToggle: () => setState(() => _obscure1 = !_obscure1)),
      const SizedBox(height: 16),
      _input(_password2Controller, 'تأكيد كلمة المرور', Icons.lock_person_outlined, isPass: true, obs: _obscure2, onToggle: () => setState(() => _obscure2 = !_obscure2)),
    ];
  }

  Widget _input(TextEditingController ctrl, String label, IconData icon, {bool isPass = false, bool? obs, VoidCallback? onToggle, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl, obscureText: obs ?? false, keyboardType: type,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.goldAccent, size: 20),
        suffixIcon: isPass ? IconButton(icon: Icon(obs! ? Icons.visibility_off : Icons.visibility, color: Colors.white38), onPressed: onToggle) : null,
        filled: true, fillColor: AppTheme.fieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.goldAccent)),
      ),
    );
  }
}