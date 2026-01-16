import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            userName: _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
          // After successful signup, user will be in NeedsBusiness state
          // Pop back to root so main.dart's BlocBuilder shows BusinessSetupPage
          if (state is NeedsBusiness || state is Authenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'OrderFlow',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Simple order management for small businesses',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Create an account',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter your details to get started',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 24),

                            // Full Name
                            _buildLabel('Full Name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: _buildInputDecoration('John Doe'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _buildInputDecoration('hello@example.com'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: _buildInputDecoration('••••••••').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            _buildLabel('Confirm Password'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: _buildInputDecoration('••••••••').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                ),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading ? null : _onSignUpPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account? ', style: TextStyle(color: Colors.grey.shade600)),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Text('Sign in', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Free plan note
                    Text(
                      'Free plan includes 50 orders per month',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
