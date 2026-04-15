import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<BudgetEntity>> getAllBudgets(int userId);
  Stream<List<BudgetEntity>> watchAllBudgets(int userId);
  Future<List<BudgetEntity>> getActiveBudgets(int userId, DateTime now);
  Future<BudgetEntity?> getBudgetForCategory(
      int userId, int categoryId, DateTime now);
  Future<int> addBudget(BudgetEntity budget);
  Future<void> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(int id);
  Future<void> updateSpent(int budgetId, double spent);
  Future<BudgetEntity> getBudgetById(int id);
  Future<double> getBudgetUtilization(int budgetId);
}
