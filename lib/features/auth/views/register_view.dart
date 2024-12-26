import 'package:flutter/material.dart';
import 'package:portfolio_tracker/features/auth/services/auth_service.dart';
import 'package:portfolio_tracker/app/theme/app_theme.dart';
import 'package:portfolio_tracker/features/shared/widgets/custom_snackbar.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-posta',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'E-posta gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Şifre gerekli';
                              }
                              if ((value?.length ?? 0) < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          if (_isLoading)
                            const CircularProgressIndicator()
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleRegister,
                                child: const Text('Kayıt Ol'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _authService.register(
          _emailController.text,
          _passwordController.text,
        );
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: 'Kayıt başarılı! Yönlendiriliyorsunuz...',
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Bir hata oluştu';

          if (e.toString().contains('email-already-in-use')) {
            errorMessage = 'Bu e-posta adresi zaten kullanımda';
          } else if (e.toString().contains('weak-password')) {
            errorMessage = 'Şifre çok zayıf';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'Geçersiz e-posta formatı';
          }

          CustomSnackbar.show(
            context: context,
            message: errorMessage,
            isError: true,
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
