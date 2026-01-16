import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orderly/core/di/injection_container.dart';
import 'package:orderly/core/theme/app_colors.dart';
import 'package:orderly/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:orderly/core/navigation/app_routes.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/plan_selection_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..loadProfile(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state.profile == null) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.editProfile,
                  arguments: state.profile,
                ).then((_) => context.read<ProfileCubit>().loadProfile()),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profile'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.error != null && state.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = state.profile!;
          return RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().loadProfile(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Profile Details'),
                  const SizedBox(height: 12),
                  _buildContactCard(profile),
                  const SizedBox(height: 24),
                  _buildBusinessCard(profile),
                  const SizedBox(height: 24),
                  _buildSocialCard(profile),
                  const SizedBox(height: 24),
                  _buildPlanSection(context, profile),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Column(
      children: [
        const Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.business_rounded, size: 40, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.businessName ?? 'No Business Name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          'Manage your account settings and business details',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildContactCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email Address', profile.email, subtitle: 'Email cannot be changed.'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.phone_outlined, 'Phone Number', profile.phone, subtitle: 'Phone number cannot be changed.'),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'User Name', profile.userName),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.business_outlined, 'Business Name', profile.businessName ?? 'N/A'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.link_outlined, 'Business URL', profile.businessUrl ?? 'N/A'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.location_on_outlined, 'Business Address', profile.businessAddress ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildSocialCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Social Media Links', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.chat_outlined, 'WhatsApp', profile.whatsapp ?? 'N/A'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.facebook_outlined, 'Facebook', profile.facebook ?? 'N/A'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.play_circle_outline, 'YouTube', profile.youtube ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildPlanSection(BuildContext context, dynamic profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Plan & Subscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (modalContext) => BlocProvider.value(
                  value: context.read<ProfileCubit>(),
                  child: const PlanSelectionSheet(),
                ),
              ),
              icon: const Icon(Icons.upgrade_rounded, size: 18),
              label: const Text('Update Plan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${profile.plan} Plan',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Current active subscription',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: const Color(0xFF64748B).withValues(alpha: 0.7), fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.read<AuthCubit>().signOut(),
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
        label: const Text('Logout Account', style: TextStyle(color: Color(0xFFEF4444))),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
