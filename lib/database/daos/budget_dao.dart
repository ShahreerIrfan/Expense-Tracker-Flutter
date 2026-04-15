import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/budgets_table.dart';
import '../tables/categories_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets, Categories])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Future<List<Budget>> getAllBudgets(int userId) =>
      (select(budgets)
            ..where((t) =>
                t.userId.equals(userId) & t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .get();

  Stream<List<Budget>> watchAllBudgets(int userId) =>
      (select(budgets)
            ..where((t) =>
                t.userId.equals(userId) & t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .watch();

  Future<List<Budget>> getActiveBudgets(int userId, DateTime now) =>
      (select(budgets)
            ..where((t) =>
                t.userId.equals(userId) &
                t.isActive.equals(true) &
                t.startDate.isSmallerOrEqualValue(now) &
                t.endDate.isBiggerOrEqualValue(now)))
          .get();

  Future<Budget?> getBudgetForCategory(
      int userId, int categoryId, DateTime now) =>
      (select(budgets)
            ..where((t) =>
                t.userId.equals(userId) &
                t.categoryId.equals(categoryId) &
                t.isActive.equals(true) &
                t.startDate.isSmallerOrEqualValue(now) &
                t.endDate.isBiggerOrEqualValue(now)))
          .getSingleOrNull();

  Future<int> insertBudget(BudgetsCompanion budget) =>
      into(budgets).insert(budget);

  Future<bool> updateBudget(Budget budget) =>
      update(budgets).replace(budget);

  Future<int> deleteBudget(int id) =>
      (update(budgets)..where((t) => t.id.equals(id)))
          .write(const BudgetsCompanion(isActive: Value(false)));

  Future<void> updateSpent(int budgetId, double spent) async {
    await (update(budgets)..where((t) => t.id.equals(budgetId))).write(
      BudgetsCompanion(
        spent: Value(spent),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<Budget> getBudgetById(int id) =>
      (select(budgets)..where((t) => t.id.equals(id))).getSingle();

  // Get budget utilization percentage
  Future<double> getBudgetUtilization(int budgetId) async {
    final budget = await getBudgetById(budgetId);
    if (budget.amount == 0) return 0;
    return (budget.spent / budget.amount) * 100;
  }
}
