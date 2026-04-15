import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/daos/income_dao.dart';
import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeDao _incomeDao;

  IncomeRepositoryImpl(this._incomeDao);

  IncomeEntity _mapToEntity(Income i) => IncomeEntity(
        id: i.id,
        userId: i.userId,
        categoryId: i.categoryId,
        accountId: i.accountId,
        amount: i.amount,
        title: i.title,
        description: i.description,
        source: i.source,
        date: i.date,
        isRecurring: i.isRecurring,
        recurringType: i.recurringType,
        recurringInterval: i.recurringInterval,
        nextRecurringDate: i.nextRecurringDate,
        createdAt: i.createdAt,
        updatedAt: i.updatedAt,
      );

  IncomesCompanion _mapToCompanion(IncomeEntity i) => IncomesCompanion(
        userId: Value(i.userId),
        categoryId: Value(i.categoryId),
        accountId: Value(i.accountId),
        amount: Value(i.amount),
        title: Value(i.title),
        description: Value(i.description),
        source: Value(i.source),
        date: Value(i.date),
        isRecurring: Value(i.isRecurring),
        recurringType: Value(i.recurringType),
        recurringInterval: Value(i.recurringInterval),
        nextRecurringDate: Value(i.nextRecurringDate),
      );

  @override
  Future<List<IncomeEntity>> getAllIncomes(int userId) async {
    final results = await _incomeDao.getAllIncomes(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<IncomeEntity>> watchAllIncomes(int userId) {
    return _incomeDao
        .watchAllIncomes(userId)
        .map((list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<List<IncomeEntity>> getIncomesByDateRange(
      int userId, DateTime start, DateTime end) async {
    final results =
        await _incomeDao.getIncomesByDateRange(userId, start, end);
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<IncomeEntity>> watchIncomesByDateRange(
      int userId, DateTime start, DateTime end) {
    return _incomeDao
        .watchIncomesByDateRange(userId, start, end)
        .map((list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<double> getTotalIncome(int userId, DateTime start, DateTime end) =>
      _incomeDao.getTotalIncome(userId, start, end);

  @override
  Future<List<IncomeEntity>> getRecurringIncomes(int userId) async {
    final results = await _incomeDao.getRecurringIncomes(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<int> addIncome(IncomeEntity income) =>
      _incomeDao.insertIncome(_mapToCompanion(income));

  @override
  Future<void> updateIncome(IncomeEntity income) async {
    if (income.id == null) return;
    final existing = await _incomeDao.getIncomeById(income.id!);
    final updated = existing.copyWith(
      categoryId: income.categoryId,
      accountId: income.accountId,
      amount: income.amount,
      title: income.title,
      description: Value(income.description),
      source: Value(income.source),
      date: income.date,
      isRecurring: income.isRecurring,
      recurringType: Value(income.recurringType),
      recurringInterval: Value(income.recurringInterval),
      nextRecurringDate: Value(income.nextRecurringDate),
      updatedAt: DateTime.now(),
    );
    await _incomeDao.updateIncome(updated);
  }

  @override
  Future<void> deleteIncome(int id) => _incomeDao.deleteIncome(id);

  @override
  Future<IncomeEntity> getIncomeById(int id) async {
    final result = await _incomeDao.getIncomeById(id);
    return _mapToEntity(result);
  }
}
