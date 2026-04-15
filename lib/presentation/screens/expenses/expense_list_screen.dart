import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../utils/helpers.dart';
import '../../../domain/entities/expense.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  int _selectedFilter = 0; // 0=all, 1=today, 2=week, 3=month
  String _sortBy = 'date'; // date, amount

  DateTimeRange? get _filterRange {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 1:
        return DateTimeRange(start: now.startOfDay, end: now.endOfDay);
      case 2:
        return DateTimeRange(start: now.startOfWeek, end: now.endOfWeek);
      case 3:
        return DateTimeRange(start: now.startOfMonth, end: now.endOfMonth);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final currency = user?.currency ?? AppConstants.defaultCurrency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18,
                        color: _sortBy == 'date'
                            ? Theme.of(context).colorScheme.primary
                            : null),
                    const SizedBox(width: 8),
                    const Text('Sort by Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'amount',
                child: Row(
                  children: [
                    Icon(Icons.attach_money,
                        size: 18,
                        color: _sortBy == 'amount'
                            ? Theme.of(context).colorScheme.primary
                            : null),
                    const SizedBox(width: 8),
                    const Text('Sort by Amount'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Today', 'This Week', 'This Month']
                  .asMap()
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: _selectedFilter == e.key,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = e.key),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Total
          _buildTotalBar(currency),

          // List
          Expanded(child: _buildExpenseList(currency)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_expense',
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalBar(String currency) {
    final range = _filterRange;
    if (range == null) return const SizedBox.shrink();

    final total = ref.watch(
        totalExpenseProvider((start: range.start, end: range.end)));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.expense.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Expenses',
              style: TextStyle(fontWeight: FontWeight.w500)),
          total.when(
            data: (v) => Text(
              AppFormatters.currency(v, currencyCode: currency),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.expense,
                fontSize: 18,
              ),
            ),
            loading: () =>
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Text('---'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(String currency) {
    final range = _filterRange;
    final AsyncValue<List<ExpenseEntity>> expensesAsync;

    if (range != null) {
      expensesAsync = ref.watch(
          expensesByDateRangeProvider((start: range.start, end: range.end)));
    } else {
      expensesAsync = ref.watch(expensesProvider);
    }

    return expensesAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No expenses found',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/add-expense'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                ),
              ],
            ),
          );
        }

        final sorted = List<ExpenseEntity>.from(expenses);
        if (_sortBy == 'amount') {
          sorted.sort((a, b) => b.amount.compareTo(a.amount));
        } else {
          sorted.sort((a, b) => b.date.compareTo(a.date));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final expense = sorted[index];
            return Dismissible(
              key: Key('expense_${expense.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: AppColors.error,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) => showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Expense'),
                  content: Text('Delete "${expense.title}"?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete',
                            style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
              onDismissed: (_) {
                ref.read(expenseActionsProvider).deleteExpense(expense.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${expense.title} deleted')),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.expense.withValues(alpha: 0.1),
                  child: const Icon(Icons.arrow_upward,
                      color: AppColors.expense, size: 20),
                ),
                title: Text(expense.title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  '${expense.categoryName ?? "Uncategorized"} • ${AppFormatters.relativeDate(expense.date)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  AppFormatters.currency(expense.amount,
                      currencyCode: currency),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.expense,
                  ),
                ),
                onTap: () => Navigator.pushNamed(context, '/expense-detail',
                    arguments: expense.id),
              ).animate(delay: Duration(milliseconds: 30 * index)).fadeIn(duration: 200.ms),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
