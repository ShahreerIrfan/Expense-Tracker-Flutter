import '../entities/income.dart';

abstract class IncomeRepository {
  Future<List<IncomeEntity>> getAllIncomes(int userId);
  Stream<List<IncomeEntity>> watchAllIncomes(int userId);
  Future<List<IncomeEntity>> getIncomesByDateRange(
      int userId, DateTime start, DateTime end);
  Stream<List<IncomeEntity>> watchIncomesByDateRange(
      int userId, DateTime start, DateTime end);
  Future<double> getTotalIncome(int userId, DateTime start, DateTime end);
  Future<List<IncomeEntity>> getRecurringIncomes(int userId);
  Future<int> addIncome(IncomeEntity income);
  Future<void> updateIncome(IncomeEntity income);
  Future<void> deleteIncome(int id);
  Future<IncomeEntity> getIncomeById(int id);
}
