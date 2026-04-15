import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/expense.dart';
import '../domain/repositories/expense_repository.dart';
import '../database/daos/expense_dao.dart';
import 'database_provider.dart';
import 'auth_provider.dart';

// All expenses for current user
final expensesProvider = StreamProvider<List<ExpenseEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return Stream.value([]);
  return ref.watch(expenseRepositoryProvider).watchAllExpenses(user!.id!);
});

// Expenses by date range
final expensesByDateRangeProvider = StreamProvider.family<
    List<ExpenseEntity>, ({DateTime start, DateTime end})>((ref, range) {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return Stream.value([]);
  return ref
      .watch(expenseRepositoryProvider)
      .watchExpensesByDateRange(user!.id!, range.start, range.end);
});

// Total expense for period
final totalExpenseProvider =
    FutureProvider.family<double, ({DateTime start, DateTime end})>(
        (ref, range) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return 0.0;
  return ref
      .watch(expenseRepositoryProvider)
      .getTotalExpense(user!.id!, range.start, range.end);
});

// Category totals
final categoryTotalsProvider = FutureProvider.family<List<CategoryTotal>,
    ({DateTime start, DateTime end})>((ref, range) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return [];
  return ref
      .watch(expenseRepositoryProvider)
      .getTotalByCategory(user!.id!, range.start, range.end);
});

// Daily totals for charts
final dailyTotalsProvider = FutureProvider.family<List<DailyTotal>,
    ({DateTime start, DateTime end})>((ref, range) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return [];
  return ref
      .watch(expenseRepositoryProvider)
      .getDailyTotals(user!.id!, range.start, range.end);
});

// Recurring expenses
final recurringExpensesProvider =
    FutureProvider<List<ExpenseEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return [];
  return ref
      .watch(expenseRepositoryProvider)
      .getRecurringExpenses(user!.id!);
});

// Search results
final expenseSearchQueryProvider = StateProvider<String>((ref) => '');

final expenseSearchResultsProvider =
    FutureProvider<List<ExpenseEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final query = ref.watch(expenseSearchQueryProvider);
  if (user?.id == null || query.isEmpty) return [];
  return ref
      .watch(expenseRepositoryProvider)
      .searchExpenses(user!.id!, query);
});

// Expense operations notifier
final expenseActionsProvider =
    Provider<ExpenseActions>((ref) => ExpenseActions(ref));

class ExpenseActions {
  final Ref _ref;

  ExpenseActions(this._ref);

  ExpenseRepository get _repo => _ref.read(expenseRepositoryProvider);

  Future<int> addExpense(ExpenseEntity expense) async {
    final id = await _repo.addExpense(expense);
    // Update account balance
    await _ref
        .read(accountRepositoryProvider)
        .updateBalance(expense.accountId, -expense.amount);
    return id;
  }

  Future<void> updateExpense(
      ExpenseEntity expense, double oldAmount, int oldAccountId) async {
    await _repo.updateExpense(expense);
    // Restore old account balance and deduct from new
    if (oldAccountId == expense.accountId) {
      await _ref
          .read(accountRepositoryProvider)
          .updateBalance(expense.accountId, oldAmount - expense.amount);
    } else {
      await _ref
          .read(accountRepositoryProvider)
          .updateBalance(oldAccountId, oldAmount);
      await _ref
          .read(accountRepositoryProvider)
          .updateBalance(expense.accountId, -expense.amount);
    }
  }

  Future<void> deleteExpense(int id) async {
    final expense = await _repo.getExpenseById(id);
    await _repo.deleteExpense(id);
    // Restore balance
    await _ref
        .read(accountRepositoryProvider)
        .updateBalance(expense.accountId, expense.amount);
  }
}
