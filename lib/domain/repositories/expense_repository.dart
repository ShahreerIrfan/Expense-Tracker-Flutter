import '../entities/expense.dart';
import '../../database/daos/expense_dao.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getAllExpenses(int userId);
  Stream<List<ExpenseEntity>> watchAllExpenses(int userId);
  Future<List<ExpenseEntity>> getExpensesByDateRange(
      int userId, DateTime start, DateTime end);
  Stream<List<ExpenseEntity>> watchExpensesByDateRange(
      int userId, DateTime start, DateTime end);
  Future<List<ExpenseEntity>> getExpensesByCategory(
      int userId, int categoryId);
  Future<List<ExpenseEntity>> getExpensesByAccount(int userId, int accountId);
  Future<double> getTotalExpense(int userId, DateTime start, DateTime end);
  Future<List<CategoryTotal>> getTotalByCategory(
      int userId, DateTime start, DateTime end);
  Future<List<ExpenseEntity>> searchExpenses(int userId, String query);
  Future<List<ExpenseEntity>> filterExpenses({
    required int userId,
    int? categoryId,
    int? accountId,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<ExpenseEntity>> getRecurringExpenses(int userId);
  Future<int> addExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(int id);
  Future<ExpenseEntity> getExpenseById(int id);
  Future<List<DailyTotal>> getDailyTotals(
      int userId, DateTime start, DateTime end);
}
