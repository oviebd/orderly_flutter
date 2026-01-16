import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../cubit/create_product_cubit.dart';

class EditProductPage extends StatelessWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CreateProductCubit>()..initForEdit(product),
      child: const _EditProductView(),
    );
  }
}

class _EditProductView extends StatefulWidget {
  const _EditProductView();

  @override
  State<_EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<_EditProductView> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _priceController;
  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CreateProductCubit>();
    _nameController = TextEditingController(text: cubit.state.name);
    _codeController = TextEditingController(text: cubit.state.code);
    _priceController = TextEditingController(text: cubit.state.price.toString());
    _detailsController = TextEditingController(text: cubit.state.details);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateProductCubit, CreateProductState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pop(context, state.createdProduct);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Product updated successfully!'),
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
          context.read<CreateProductCubit>().clearError();
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
                        _buildProductDetailsCard(context, state),
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
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF64748B)),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Edit Product',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Product',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Modify the details of your product',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsCard(BuildContext context, CreateProductState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            label: 'Product Name',
            isRequired: true,
            child: TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(hint: 'e.g., Chocolate Cake'),
              onChanged: (value) => context.read<CreateProductCubit>().setName(value),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Product Code',
            isOptional: true,
            child: TextField(
              controller: _codeController,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(hint: 'e.g., P-100'),
              onChanged: (value) => context.read<CreateProductCubit>().setCode(value),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Price',
            isRequired: true,
            child: TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(hint: '0.00', prefixIcon: Icons.attach_money),
              onChanged: (value) {
                final price = double.tryParse(value) ?? 0.0;
                context.read<CreateProductCubit>().setPrice(price);
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Details',
            isOptional: true,
            child: TextField(
              controller: _detailsController,
              maxLines: 4,
              style: const TextStyle(fontSize: 15),
              decoration: _inputDecoration(hint: 'Product description...'),
              onChanged: (value) => context.read<CreateProductCubit>().setDetails(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required Widget child, bool isRequired = false, bool isOptional = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
            if (isRequired) const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
            if (isOptional) const Text(' (Optional)', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: const Color(0xFF64748B)) : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
    );
  }

  Widget _buildBottomBar(BuildContext context, CreateProductState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: state.isSubmitting || !state.isValid ? null : () => context.read<CreateProductCubit>().submitProduct(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: state.isSubmitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Text('Update Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
