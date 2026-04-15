import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../domain/entities/budget.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currency = user?.currency ?? AppConstants.defaultCurrency;
    final budgetsAsync = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No budgets set',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/add-budget'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Budget'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _BudgetCard(budget: budget, currency: currency)
                  .animate(delay: Duration(milliseconds: 50 * index))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_budget',
        onPressed: () => Navigator.pushNamed(context, '/add-budget'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetEntity budget;
  final String currency;

  const _BudgetCard({required this.budget, required this.currency});

  Color get _progressColor {
    final pct = budget.utilizationPercent;
    if (pct >= 100) return AppColors.error;
    if (pct >= 80) return AppColors.warning;
    if (pct >= 50) return Colors.orange;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final pct = budget.utilizationPercent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.categoryName ?? 'Overall Budget',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        budget.period.toUpperCase(),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _progressColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _progressColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(_progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${AppFormatters.currency(budget.spent, currencyCode: currency)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Text(
                  'Budget: ${AppFormatters.currency(budget.amount, currencyCode: currency)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            if (budget.remaining > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Remaining: ${AppFormatters.currency(budget.remaining, currencyCode: currency)}',
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
              ),
            if (budget.isOverBudget)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Over budget by ${AppFormatters.currency(budget.spent - budget.amount, currencyCode: currency)}!',
                  style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
