import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/order.dart'; // Import Order entity
import '../../domain/entities/order.dart' as order_entity; // Prefix import to avoid conflicts? No, Order is top level.
import '../cubit/order_cubit.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  // Simplified for MVP: Manual product entry for now or dummy selection
  // In real implementation, this would be complex.
  
  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  void _submitOrder(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // Create a dummy order for demonstration
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email ?? '';
      
      final newOrder = Order(
        id: '', // Empty ID for Firestore generation
        businessId: email,
        ownerId: user?.uid ?? '',
        customerId: _customerController.text, // This is actually name
        status: 'pending',
        source: 'manual',
        address: 'No Address',
        notes: '',
        orderDate: DateTime.now(),
        deliveryDate: DateTime.now().add(const Duration(days: 1)),
        deliveryCharge: 10.0,
        totalAmount: 100.0, // Dummy amount
        products: [], // Empty products for now
      );

      context.read<OrderCubit>().createOrder(newOrder);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.createOrder)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _customerController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.selectCustomer,
                    hintText: "Enter customer name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text("Products Selector (Coming Soon)"),
                const SizedBox(height: 32),
                Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () => _submitOrder(context),
                      child: const Text(AppStrings.createOrder),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
