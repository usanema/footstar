import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'widgets/stadium_background.dart';

import '../data/auth_repository.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  final _authRepository = AuthRepository();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _authRepository.signUpWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          if (response.user != null) {
            // TODO: Handle profile creation logic (Name/Surname)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Player Contract Signed! Welcome aboard.'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(); // Go back to login
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
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'CONTRACT NEGOTIATION',
          style: AppTextStyles.titleMedium.copyWith(
            letterSpacing: 1.5,
            color: AppColors.secondary,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: StadiumBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'BUILD YOUR\nPLAYER',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.primary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your career in the league.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 40),

                    // --- PLAYER DETAILS ---
                    Text(
                      'PLAYER DETAILS',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            style: AppTextStyles.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'NAME',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _surnameController,
                            style: AppTextStyles.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'SURNAME',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- LOGIN CREDENTIALS ---
                    Text(
                      'CREDENTIALS',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                        if (value == null || value.isEmpty) return 'Required';
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'PASSWORD',
                        prefixIcon: Icon(Icons.lock_outline),
                        helperText: 'Min. 6 characters',
                        helperStyle: TextStyle(color: AppColors.secondary),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (value.length < 6) return 'Password too short';
                        return null;
                      },
                    ),

                    const SizedBox(height: 48),

                    // --- ACTION BUTTON ---
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _signUp,
                            child: const Text('START CAREER'),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
