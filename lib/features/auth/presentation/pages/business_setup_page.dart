import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';

class BusinessSetupPage extends StatefulWidget {
  const BusinessSetupPage({super.key});

  @override
  State<BusinessSetupPage> createState() => _BusinessSetupPageState();
}

class _BusinessSetupPageState extends State<BusinessSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().registerBusiness(
            businessName: _businessNameController.text.trim(),
            phone: _phoneController.text.trim(),
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
        },
        builder: (context, state) {
          final needsBusinessState = state is NeedsBusiness ? state : null;
          final email = needsBusinessState?.email ?? '';

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
                      child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Setup Business Profile',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell us about your business to get started',
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
                              'Business Details',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'We need a few more details to set up your OrderFlow account.',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 24),

                            // Email (Read-only)
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                    ),
                                  ),
                                  Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Business Name
                            _buildLabel('Business Name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _businessNameController,
                              decoration: _buildInputDecoration('e.g., Sweet Delights Bakery'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your business name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone Number
                            _buildLabel('Phone Number'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration('+1234567890'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading ? null : _onRegisterPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Complete Registration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
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
