import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/daos/budget_dao.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDao _budgetDao;

  BudgetRepositoryImpl(this._budgetDao);

  BudgetEntity _mapToEntity(Budget b) => BudgetEntity(
        id: b.id,
        userId: b.userId,
        categoryId: b.categoryId,
        amount: b.amount,
        spent: b.spent,
        period: b.period,
        startDate: b.startDate,
        endDate: b.endDate,
        rollover: b.rollover,
        rolloverAmount: b.rolloverAmount,
        alertAt50: b.alertAt50,
        alertAt80: b.alertAt80,
        alertAt100: b.alertAt100,
        isActive: b.isActive,
        createdAt: b.createdAt,
        updatedAt: b.updatedAt,
      );

  @override
  Future<List<BudgetEntity>> getAllBudgets(int userId) async {
    final results = await _budgetDao.getAllBudgets(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<BudgetEntity>> watchAllBudgets(int userId) {
    return _budgetDao
        .watchAllBudgets(userId)
        .map((list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<List<BudgetEntity>> getActiveBudgets(
      int userId, DateTime now) async {
    final results = await _budgetDao.getActiveBudgets(userId, now);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<BudgetEntity?> getBudgetForCategory(
      int userId, int categoryId, DateTime now) async {
    final result =
        await _budgetDao.getBudgetForCategory(userId, categoryId, now);
    return result != null ? _mapToEntity(result) : null;
  }

  @override
  Future<int> addBudget(BudgetEntity budget) =>
      _budgetDao.insertBudget(BudgetsCompanion.insert(
        userId: budget.userId,
        categoryId: Value(budget.categoryId),
        amount: budget.amount,
        period: budget.period,
        startDate: budget.startDate,
        endDate: budget.endDate,
        rollover: Value(budget.rollover),
        alertAt50: Value(budget.alertAt50),
        alertAt80: Value(budget.alertAt80),
        alertAt100: Value(budget.alertAt100),
      ));

  @override
  Future<void> updateBudget(BudgetEntity budget) async {
    if (budget.id == null) return;
    final existing = await _budgetDao.getBudgetById(budget.id!);
    final updated = existing.copyWith(
      categoryId: Value(budget.categoryId),
      amount: budget.amount,
      spent: budget.spent,
      period: budget.period,
      startDate: budget.startDate,
      endDate: budget.endDate,
      rollover: budget.rollover,
      rolloverAmount: budget.rolloverAmount,
      alertAt50: budget.alertAt50,
      alertAt80: budget.alertAt80,
      alertAt100: budget.alertAt100,
      updatedAt: DateTime.now(),
    );
    await _budgetDao.updateBudget(updated);
  }

  @override
  Future<void> deleteBudget(int id) => _budgetDao.deleteBudget(id);

  @override
  Future<void> updateSpent(int budgetId, double spent) =>
      _budgetDao.updateSpent(budgetId, spent);

  @override
  Future<BudgetEntity> getBudgetById(int id) async {
    final result = await _budgetDao.getBudgetById(id);
    return _mapToEntity(result);
  }

  @override
  Future<double> getBudgetUtilization(int budgetId) =>
      _budgetDao.getBudgetUtilization(budgetId);
}
