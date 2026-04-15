import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/budget.dart';
import 'database_provider.dart';
import 'auth_provider.dart';

// All budgets
final budgetsProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return Stream.value([]);
  return ref.watch(budgetRepositoryProvider).watchAllBudgets(user!.id!);
});

// Active budgets
final activeBudgetsProvider =
    FutureProvider<List<BudgetEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return [];
  return ref
      .watch(budgetRepositoryProvider)
      .getActiveBudgets(user!.id!, DateTime.now());
});

// Budget actions
final budgetActionsProvider =
    Provider<BudgetActions>((ref) => BudgetActions(ref));

class BudgetActions {
  final Ref _ref;

  BudgetActions(this._ref);

  Future<int> addBudget(BudgetEntity budget) =>
      _ref.read(budgetRepositoryProvider).addBudget(budget);

  Future<void> updateBudget(BudgetEntity budget) =>
      _ref.read(budgetRepositoryProvider).updateBudget(budget);

  Future<void> deleteBudget(int id) =>
      _ref.read(budgetRepositoryProvider).deleteBudget(id);

  Future<void> updateSpent(int budgetId, double spent) =>
      _ref.read(budgetRepositoryProvider).updateSpent(budgetId, spent);
}
