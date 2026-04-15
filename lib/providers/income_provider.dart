import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/income.dart';
import '../domain/repositories/income_repository.dart';
import 'database_provider.dart';
import 'auth_provider.dart';

// All incomes
final incomesProvider = StreamProvider<List<IncomeEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return Stream.value([]);
  return ref.watch(incomeRepositoryProvider).watchAllIncomes(user!.id!);
});

// Incomes by date range
final incomesByDateRangeProvider = StreamProvider.family<
    List<IncomeEntity>, ({DateTime start, DateTime end})>((ref, range) {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return Stream.value([]);
  return ref
      .watch(incomeRepositoryProvider)
      .watchIncomesByDateRange(user!.id!, range.start, range.end);
});

// Total income
final totalIncomeProvider =
    FutureProvider.family<double, ({DateTime start, DateTime end})>(
        (ref, range) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return 0.0;
  return ref
      .watch(incomeRepositoryProvider)
      .getTotalIncome(user!.id!, range.start, range.end);
});

// Income operations
final incomeActionsProvider =
    Provider<IncomeActions>((ref) => IncomeActions(ref));

class IncomeActions {
  final Ref _ref;

  IncomeActions(this._ref);

  IncomeRepository get _repo => _ref.read(incomeRepositoryProvider);

  Future<int> addIncome(IncomeEntity income) async {
    final id = await _repo.addIncome(income);
    await _ref
        .read(accountRepositoryProvider)
        .updateBalance(income.accountId, income.amount);
    return id;
  }

  Future<void> updateIncome(
      IncomeEntity income, double oldAmount, int oldAccountId) async {
    await _repo.updateIncome(income);
    if (oldAccountId == income.accountId) {
      await _ref
          .read(accountRepositoryProvider)
          .updateBalance(income.accountId, income.amount - oldAmount);
    } else {
      await _ref
          .read(accountRepositoryProvider)
          .updateBalance(oldAccountId, -oldAmount);
      await _ref
          .read(accountRepositoryProvider)
          .updateBalance(income.accountId, income.amount);
    }
  }

  Future<void> deleteIncome(int id) async {
    final income = await _repo.getIncomeById(id);
    await _repo.deleteIncome(id);
    await _ref
        .read(accountRepositoryProvider)
        .updateBalance(income.accountId, -income.amount);
  }
}
