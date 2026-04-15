import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/income_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../utils/helpers.dart';
import '../../../domain/entities/income.dart';

class IncomeListScreen extends ConsumerStatefulWidget {
  const IncomeListScreen({super.key});

  @override
  ConsumerState<IncomeListScreen> createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends ConsumerState<IncomeListScreen> {
  int _selectedFilter = 0;

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
    final incomesAsync = ref.watch(incomesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Income')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Today', 'Week', 'Month']
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(e.value),
                          selected: _selectedFilter == e.key,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = e.key),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: incomesAsync.when(
              data: (incomes) {
                var filtered = incomes;
                final range = _filterRange;
                if (range != null) {
                  filtered = incomes
                      .where((i) =>
                          i.date.isAfter(
                              range.start.subtract(const Duration(seconds: 1))) &&
                          i.date.isBefore(
                              range.end.add(const Duration(seconds: 1))))
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No income recorded',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/add-income'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Income'),
                        ),
                      ],
                    ),
                  );
                }

                final totalIncome =
                    filtered.fold<double>(0, (s, i) => s + i.amount);

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Income',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            AppFormatters.currency(totalIncome,
                                currencyCode: currency),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.income,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final income = filtered[index];
                          return Dismissible(
                            key: Key('income_${income.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: AppColors.error,
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) => showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Income'),
                                content:
                                    Text('Delete "${income.title}"?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Delete',
                                          style: TextStyle(
                                              color: AppColors.error))),
                                ],
                              ),
                            ),
                            onDismissed: (_) {
                              ref.read(incomeActionsProvider).deleteIncome(income.id!);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.income.withValues(alpha: 0.1),
                                child: const Icon(Icons.arrow_downward,
                                    color: AppColors.income, size: 20),
                              ),
                              title: Text(income.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                '${income.source ?? "Income"} • ${AppFormatters.relativeDate(income.date)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                '+${AppFormatters.currency(income.amount, currencyCode: currency)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.income,
                                ),
                              ),
                            )
                                .animate(
                                    delay:
                                        Duration(milliseconds: 30 * index))
                                .fadeIn(duration: 200.ms),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_income',
        onPressed: () => Navigator.pushNamed(context, '/add-income'),
        backgroundColor: AppColors.income,
        child: const Icon(Icons.add),
      ),
    );
  }
}
