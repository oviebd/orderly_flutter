import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/customer.dart';
import '../cubit/create_customer_cubit.dart';

class EditCustomerPage extends StatelessWidget {
  final Customer customer;
  const EditCustomerPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CreateCustomerCubit>()..initForEdit(customer),
      child: const _EditCustomerView(),
    );
  }
}

class _EditCustomerView extends StatefulWidget {
  const _EditCustomerView();

  @override
  State<_EditCustomerView> createState() => _EditCustomerViewState();
}

class _EditCustomerViewState extends State<_EditCustomerView> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CreateCustomerCubit>();
    _nameController = TextEditingController(text: cubit.state.name);
    _phoneController = TextEditingController(text: cubit.state.phone);
    _emailController = TextEditingController(text: cubit.state.email);
    _addressController = TextEditingController(text: cubit.state.address);
    _commentController = TextEditingController(text: cubit.state.comment);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCustomerCubit, CreateCustomerState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pop(context, state.createdCustomer);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Customer updated successfully!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<CreateCustomerCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildFormCard(context),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF64748B)),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Edit Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Update Customer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        SizedBox(height: 4),
        Text('Modify customer contact and delivery details', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(
        children: [
          _buildInputField(label: 'Full Name', isRequired: true, child: TextField(controller: _nameController, decoration: _inputDecoration(hint: 'e.g., John Doe'), onChanged: (v) => context.read<CreateCustomerCubit>().setName(v))),
          const SizedBox(height: 20),
          _buildInputField(label: 'Phone Number', isRequired: true, child: TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration(hint: '01XXXXXXXXX'), onChanged: (v) => context.read<CreateCustomerCubit>().setPhone(v))),
          const SizedBox(height: 20),
          _buildInputField(label: 'Email', isOptional: true, child: TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration(hint: 'example@mail.com'), onChanged: (v) => context.read<CreateCustomerCubit>().setEmail(v))),
          const SizedBox(height: 20),
          _buildInputField(label: 'Address', isOptional: true, child: TextField(controller: _addressController, maxLines: 2, decoration: _inputDecoration(hint: 'Delivery address...'), onChanged: (v) => context.read<CreateCustomerCubit>().setAddress(v))),
          const SizedBox(height: 20),
          _buildInputField(label: 'Notes', isOptional: true, child: TextField(controller: _commentController, maxLines: 2, decoration: _inputDecoration(hint: 'Any internal notes...'), onChanged: (v) => context.read<CreateCustomerCubit>().setComment(v))),
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required Widget child, bool isRequired = false, bool isOptional = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        if (isRequired) const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
        if (isOptional) const Text(' (Optional)', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      ]),
      const SizedBox(height: 8),
      child,
    ]);
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
    );
  }

  Widget _buildBottomBar(BuildContext context, CreateCustomerState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))]),
      child: Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))))),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: ElevatedButton(onPressed: state.isSubmitting || !state.isValid ? null : () => context.read<CreateCustomerCubit>().submitCustomer(), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), disabledBackgroundColor: const Color(0xFFCBD5E1), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: state.isSubmitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Text('Update Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))),
      ]),
    );
  }
}
