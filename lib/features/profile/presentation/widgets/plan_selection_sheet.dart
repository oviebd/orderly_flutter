import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orderly/core/theme/app_colors.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'plan_card.dart';

class PlanSelectionSheet extends StatefulWidget {
  const PlanSelectionSheet({super.key});

  @override
  State<PlanSelectionSheet> createState() => _PlanSelectionSheetState();
}

class _PlanSelectionSheetState extends State<PlanSelectionSheet> {
  String? selectedPlanId;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadPlans();
    selectedPlanId = context.read<ProfileCubit>().state.profile?.plan;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Select a plan that fits your business needs.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state.plans == null) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                return ListView.separated(
                  itemCount: state.plans!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final plan = state.plans![index];
                    return PlanCard(
                      plan: plan,
                      isSelected: selectedPlanId == plan.id,
                      onTap: () {
                        setState(() {
                          selectedPlanId = plan.id;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedPlanId != null
                      ? () {
                          context.read<ProfileCubit>().updatePlan(selectedPlanId!);
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Update Plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
