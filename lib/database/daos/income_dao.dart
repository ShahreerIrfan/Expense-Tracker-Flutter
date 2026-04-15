import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/incomes_table.dart';
import '../tables/categories_table.dart';
import '../tables/accounts_table.dart';

part 'income_dao.g.dart';

@DriftAccessor(tables: [Incomes, Categories, Accounts])
class IncomeDao extends DatabaseAccessor<AppDatabase> with _$IncomeDaoMixin {
  IncomeDao(super.db);

  Future<List<Income>> getAllIncomes(int userId) =>
      (select(incomes)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<Income>> watchAllIncomes(int userId) =>
      (select(incomes)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<Income>> getIncomesByDateRange(
      int userId, DateTime start, DateTime end) =>
      (select(incomes)
            ..where((t) =>
                t.userId.equals(userId) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<Income>> watchIncomesByDateRange(
      int userId, DateTime start, DateTime end) =>
      (select(incomes)
            ..where((t) =>
                t.userId.equals(userId) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<double> getTotalIncome(
      int userId, DateTime start, DateTime end) async {
    final query = selectOnly(incomes)
      ..addColumns([incomes.amount.sum()])
      ..where(incomes.userId.equals(userId) &
          incomes.date.isBiggerOrEqualValue(start) &
          incomes.date.isSmallerOrEqualValue(end));
    final result = await query.getSingle();
    return result.read(incomes.amount.sum()) ?? 0.0;
  }

  Future<List<Income>> getRecurringIncomes(int userId) =>
      (select(incomes)
            ..where(
                (t) => t.userId.equals(userId) & t.isRecurring.equals(true)))
          .get();

  Future<int> insertIncome(IncomesCompanion income) =>
      into(incomes).insert(income);

  Future<bool> updateIncome(Income income) =>
      update(incomes).replace(income);

  Future<int> deleteIncome(int id) =>
      (delete(incomes)..where((t) => t.id.equals(id))).go();

  Future<Income> getIncomeById(int id) =>
      (select(incomes)..where((t) => t.id.equals(id))).getSingle();
}
