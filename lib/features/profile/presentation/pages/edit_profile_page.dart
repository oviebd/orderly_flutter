import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orderly/core/di/injection_container.dart';
import 'package:orderly/core/theme/app_colors.dart';
import '../../domain/entities/business_profile.dart';
import '../../data/models/business_profile_model.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  final BusinessProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _userNameController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessUrlController;
  late TextEditingController _businessAddressController;
  late TextEditingController _whatsappController;
  late TextEditingController _facebookController;
  late TextEditingController _youtubeController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.profile.userName);
    _businessNameController = TextEditingController(text: widget.profile.businessName);
    _businessUrlController = TextEditingController(text: widget.profile.businessUrl);
    _businessAddressController = TextEditingController(text: widget.profile.businessAddress);
    _whatsappController = TextEditingController(text: widget.profile.whatsapp);
    _facebookController = TextEditingController(text: widget.profile.facebook);
    _youtubeController = TextEditingController(text: widget.profile.youtube);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _businessNameController.dispose();
    _businessUrlController.dispose();
    _businessAddressController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.isUpdateSuccess) {
            Navigator.pop(context, state.profile);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Color(0xFF10B981)),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
            );
            context.read<ProfileCubit>().clearError();
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: const Text('Edit Profile'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 12),
                    _buildTextField(_userNameController, 'User Name', Icons.person_outline),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Business Information'),
                    const SizedBox(height: 12),
                    _buildTextField(_businessNameController, 'Business Name', Icons.business_outlined),
                    const SizedBox(height: 16),
                    _buildTextField(_businessUrlController, 'Business URL', Icons.link_outlined, hint: 'https://example.com'),
                    const SizedBox(height: 16),
                    _buildTextField(_businessAddressController, 'Business Address', Icons.location_on_outlined, maxLines: 3),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Social Media Links'),
                    const SizedBox(height: 12),
                    _buildTextField(_whatsappController, 'WhatsApp', Icons.chat_outlined, hint: 'Number or link'),
                    const SizedBox(height: 16),
                    _buildTextField(_facebookController, 'Facebook', Icons.facebook_outlined, hint: 'Profile link'),
                    const SizedBox(height: 16),
                    _buildTextField(_youtubeController, 'YouTube', Icons.play_circle_outline, hint: 'Channel link'),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : () => _onSave(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: state.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Update Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = (widget.profile as BusinessProfileModel).copyWith(
        userName: _userNameController.text,
        businessName: _businessNameController.text,
        businessUrl: _businessUrlController.text,
        businessAddress: _businessAddressController.text,
        whatsapp: _whatsappController.text,
        facebook: _facebookController.text,
        youtube: _youtubeController.text,
      );
      context.read<ProfileCubit>().updateProfile(updatedProfile);
    }
  }
}
