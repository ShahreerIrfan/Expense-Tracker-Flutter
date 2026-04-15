import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/income_provider.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/ai_insight_service.dart';
import '../../../utils/formatters.dart';
import '../../../utils/helpers.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/expense.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedPeriod = 2; // 0=daily, 1=weekly, 2=monthly, 3=yearly

  DateTimeRange get _currentRange {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 0:
        return DateTimeRange(start: now.startOfDay, end: now.endOfDay);
      case 1:
        return DateTimeRange(start: now.startOfWeek, end: now.endOfWeek);
      case 2:
        return DateTimeRange(start: now.startOfMonth, end: now.endOfMonth);
      case 3:
        return DateTimeRange(start: now.startOfYear, end: now.endOfYear);
      default:
        return DateTimeRange(start: now.startOfMonth, end: now.endOfMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final currency = user?.currency ?? AppConstants.defaultCurrency;
    final range = (start: _currentRange.start, end: _currentRange.end);

    final totalExpenseAsync = ref.watch(totalExpenseProvider(range));
    final totalIncomeAsync = ref.watch(totalIncomeProvider(range));
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final expensesAsync = ref.watch(expensesByDateRangeProvider(range));
    final categoryTotalsAsync = ref.watch(categoryTotalsProvider(range));

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(totalExpenseProvider(range));
            ref.invalidate(totalIncomeProvider(range));
            ref.invalidate(totalBalanceProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/profile-select'),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppFormatters.parseColor(
                              user?.avatarColor ?? '#4CAF50'),
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.name ?? "User"} 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              AppFormatters.date(DateTime.now()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/search'),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                ),
              ),

              // Balance Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      totalBalanceAsync.when(
                        data: (balance) => Text(
                          AppFormatters.currency(balance,
                              currencyCode: currency),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const SizedBox(
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        error: (_, __) => const Text(
                          '---',
                          style: TextStyle(color: Colors.white, fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _BalanceItem(
                              label: 'Income',
                              icon: Icons.arrow_downward,
                              iconColor: AppColors.income,
                              amount: totalIncomeAsync.when(
                                data: (v) => AppFormatters.compactCurrency(v,
                                    currencyCode: currency),
                                loading: () => '...',
                                error: (_, __) => '---',
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: _BalanceItem(
                              label: 'Expense',
                              icon: Icons.arrow_upward,
                              iconColor: AppColors.expense,
                              amount: totalExpenseAsync.when(
                                data: (v) => AppFormatters.compactCurrency(v,
                                    currencyCode: currency),
                                loading: () => '...',
                                error: (_, __) => '---',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.1),
              ),

              // Period selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                        .asMap()
                        .entries
                        .map(
                          (e) => Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPeriod = e.key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedPeriod == e.key
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  e.value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedPeriod == e.key
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              ),

              // Category spending breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spending by Category',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/reports'),
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      categoryTotalsAsync.when(
                        data: (totals) {
                          if (totals.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'No expenses recorded yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }
                          final totalExpense = totals.fold<double>(
                              0.0, (sum, t) => sum + t.total);
                          return Column(
                            children: totals.take(5).map((ct) {
                              final pct = totalExpense > 0
                                  ? ct.total / totalExpense
                                  : 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppFormatters.parseColor(
                                              ct.categoryColor)
                                          .withValues(alpha: 0.15),
                                      child: Icon(
                                        AppFormatters.getIconData(
                                            ct.categoryIcon),
                                        size: 18,
                                        color: AppFormatters.parseColor(
                                            ct.categoryColor),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ct.categoryName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: pct,
                                              backgroundColor: Colors.grey[200],
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                AppFormatters.parseColor(
                                                    ct.categoryColor),
                                              ),
                                              minHeight: 6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppFormatters.currency(ct.total,
                                          currencyCode: currency),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (_, __) =>
                            const Center(child: Text('Error loading data')),
                      ),
                    ],
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              ),

              // Recent transactions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/expenses'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
              ),

              expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'No transactions yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= expenses.length || index >= 10) return null;
                        final expense = expenses[index];
                        return _ExpenseTile(
                          expense: expense,
                          currency: currency,
                        )
                            .animate(
                                delay: Duration(milliseconds: 50 * index))
                            .fadeIn(duration: 200.ms)
                            .slideX(begin: 0.05);
                      },
                      childCount: expenses.length > 10 ? 10 : expenses.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                  child: Center(child: Text('Error')),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String amount;

  const _BalanceItem({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseEntity expense;
  final String currency;

  const _ExpenseTile({required this.expense, required this.currency});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: AppColors.expense.withValues(alpha: 0.1),
        child: const Icon(Icons.arrow_upward, color: AppColors.expense, size: 20),
      ),
      title: Text(
        expense.title,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        AppFormatters.relativeDate(expense.date),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Text(
        '-${AppFormatters.currency(expense.amount, currencyCode: currency)}',
        style: const TextStyle(
          color: AppColors.expense,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => Navigator.pushNamed(context, '/expense-detail',
          arguments: expense.id),
    );
  }
}
