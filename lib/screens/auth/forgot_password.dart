import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent       = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.resetPassword(_emailCtrl.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Failed to send email'),
          backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppColors.bgDark,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _sentUI() : _formUI(auth),
      ),
    );
  }

  Widget _sentUI() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.mark_email_read_outlined,
        color: AppColors.success, size: 80),
      const SizedBox(height: 24),
      const Text('Email Sent!',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 24,
          fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text('We sent a password reset link to ${_emailCtrl.text}',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
      const SizedBox(height: 32),
      OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Back to Login'),
      ),
    ],
  );

  Widget _formUI(AuthProvider auth) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.lock_reset, color: AppColors.primary, size: 64),
        const SizedBox(height: 24),
        const Text('Forgot Password?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 24,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Enter your email and we\'ll send you a link to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 40),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
          ),
          validator: Validators.email,
        ),
        const SizedBox(height: 24),
        CustomButton(label: 'Send Reset Link', loading: auth.loading, onPressed: _send),
      ],
    ),
  );
}
