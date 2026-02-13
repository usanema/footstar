import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'widgets/stadium_background.dart';

import '../data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _authRepository.signInWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          if (response.user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome back to the Arena!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // --- BACKGROUND PATTERN ---
          // --- BACKGROUND PATTERN ---
          const Positioned.fill(child: StadiumBackground()),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- LOGO SECTION ---
                      const SizedBox(height: 40),
                      SvgPicture.asset(
                        'assets/logo/footstar-logo.svg',
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'FOOTSTAR',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'ENTER THE ARENA',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          letterSpacing: 4.0,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // --- INPUT FIELDS ---
                      TextFormField(
                        controller: _emailController,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'EMAIL',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'PASSWORD',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _signIn(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      // --- FORGOT PASSWORD ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- ACTION BUTTONS ---
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _signIn,
                              child: const Text('LOGIN'),
                            ),

                      const SizedBox(height: 24),

                      // --- SOCIAL LOGIN ---
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.surface,
                              thickness: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: AppTextStyles.bodySmall),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.surface,
                              thickness: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      OutlinedButton.icon(
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('SIGN IN WITH GOOGLE'),
                        onPressed: () async {
                          // Google Sign In Logic
                          try {
                            await _authRepository.signInWithGoogle();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Google Sign-In Error: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 40),

                      // --- SIGN UP LINK ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have a player card?",
                            style: AppTextStyles.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/register');
                            },
                            child: Text(
                              'JOIN THE SQUAD',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.secondary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
