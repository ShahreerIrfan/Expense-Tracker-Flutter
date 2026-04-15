import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../domain/entities/expense.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final int expenseId;
  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currency = user?.currency ?? AppConstants.defaultCurrency;
    final expensesAsync = ref.watch(expensesProvider);

    return expensesAsync.when(
      data: (expenses) {
        final expense = expenses.where((e) => e.id == expenseId).firstOrNull;
        if (expense == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Expense')),
            body: const Center(child: Text('Expense not found')),
          );
        }
        return _buildDetail(context, ref, expense, currency);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Expense')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Expense')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetail(
      BuildContext context, WidgetRef ref, ExpenseEntity expense, String currency) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-expense',
                arguments: expense.id),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref, expense),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Amount header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.expense.withValues(alpha: 0.8),
                  AppColors.expense,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  AppFormatters.currency(expense.amount,
                      currencyCode: currency),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Details
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: AppFormatters.dateTime(expense.date),
          ),
          if (expense.categoryName != null)
            _DetailRow(
              icon: Icons.category,
              label: 'Category',
              value: expense.categoryName!,
            ),
          if (expense.accountName != null)
            _DetailRow(
              icon: Icons.account_balance_wallet,
              label: 'Account',
              value: expense.accountName!,
            ),
          if (expense.description != null && expense.description!.isNotEmpty)
            _DetailRow(
              icon: Icons.notes,
              label: 'Description',
              value: expense.description!,
            ),
          if (expense.isRecurring)
            _DetailRow(
              icon: Icons.repeat,
              label: 'Recurring',
              value: expense.recurringType?.toUpperCase() ?? 'Yes',
            ),
          if (expense.tags != null && expense.tags!.isNotEmpty)
            _DetailRow(
              icon: Icons.tag,
              label: 'Tags',
              value: expense.tags!.join(', '),
            ),
          if (expense.location != null && expense.location!.isNotEmpty)
            _DetailRow(
              icon: Icons.location_on,
              label: 'Location',
              value: expense.location!,
            ),
          _DetailRow(
            icon: Icons.access_time,
            label: 'Created',
            value: AppFormatters.dateTime(expense.createdAt ?? DateTime.now()),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, ExpenseEntity expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Delete "${expense.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(expenseActionsProvider).deleteExpense(expense.id!);
      Navigator.pop(context);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
