import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/daos/expense_dao.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import 'dart:convert';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDao _expenseDao;

  ExpenseRepositoryImpl(this._expenseDao);

  ExpenseEntity _mapToEntity(Expense e) => ExpenseEntity(
        id: e.id,
        userId: e.userId,
        categoryId: e.categoryId,
        accountId: e.accountId,
        amount: e.amount,
        title: e.title,
        description: e.description,
        date: e.date,
        isRecurring: e.isRecurring,
        recurringType: e.recurringType,
        recurringInterval: e.recurringInterval,
        nextRecurringDate: e.nextRecurringDate,
        location: e.location,
        latitude: e.latitude,
        longitude: e.longitude,
        receiptPath: e.receiptPath,
        tags: e.tags != null
            ? (jsonDecode(e.tags!) as List).cast<String>()
            : null,
        splitWith: e.splitWith != null
            ? (jsonDecode(e.splitWith!) as List)
                .map((s) => SplitDetail.fromJson(s as Map<String, dynamic>))
                .toList()
            : null,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  ExpensesCompanion _mapToCompanion(ExpenseEntity e) => ExpensesCompanion(
        userId: Value(e.userId),
        categoryId: Value(e.categoryId),
        accountId: Value(e.accountId),
        amount: Value(e.amount),
        title: Value(e.title),
        description: Value(e.description),
        date: Value(e.date),
        isRecurring: Value(e.isRecurring),
        recurringType: Value(e.recurringType),
        recurringInterval: Value(e.recurringInterval),
        nextRecurringDate: Value(e.nextRecurringDate),
        location: Value(e.location),
        latitude: Value(e.latitude),
        longitude: Value(e.longitude),
        receiptPath: Value(e.receiptPath),
        tags: Value(e.tags != null ? jsonEncode(e.tags) : null),
        splitWith: Value(e.splitWith != null
            ? jsonEncode(e.splitWith!.map((s) => s.toJson()).toList())
            : null),
      );

  @override
  Future<List<ExpenseEntity>> getAllExpenses(int userId) async {
    final results = await _expenseDao.getAllExpenses(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<ExpenseEntity>> watchAllExpenses(int userId) {
    return _expenseDao.watchAllExpenses(userId).map(
        (list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByDateRange(
      int userId, DateTime start, DateTime end) async {
    final results =
        await _expenseDao.getExpensesByDateRange(userId, start, end);
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<ExpenseEntity>> watchExpensesByDateRange(
      int userId, DateTime start, DateTime end) {
    return _expenseDao.watchExpensesByDateRange(userId, start, end).map(
        (list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByCategory(
      int userId, int categoryId) async {
    final results =
        await _expenseDao.getExpensesByCategory(userId, categoryId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByAccount(
      int userId, int accountId) async {
    final results =
        await _expenseDao.getExpensesByAccount(userId, accountId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<double> getTotalExpense(
          int userId, DateTime start, DateTime end) =>
      _expenseDao.getTotalExpense(userId, start, end);

  @override
  Future<List<CategoryTotal>> getTotalByCategory(
          int userId, DateTime start, DateTime end) =>
      _expenseDao.getTotalByCategory(userId, start, end);

  @override
  Future<List<ExpenseEntity>> searchExpenses(
      int userId, String query) async {
    final results = await _expenseDao.searchExpenses(userId, query);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<List<ExpenseEntity>> filterExpenses({
    required int userId,
    int? categoryId,
    int? accountId,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final results = await _expenseDao.filterExpenses(
      userId: userId,
      categoryId: categoryId,
      accountId: accountId,
      minAmount: minAmount,
      maxAmount: maxAmount,
      startDate: startDate,
      endDate: endDate,
    );
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<List<ExpenseEntity>> getRecurringExpenses(int userId) async {
    final results = await _expenseDao.getRecurringExpenses(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<int> addExpense(ExpenseEntity expense) =>
      _expenseDao.insertExpense(_mapToCompanion(expense));

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    if (expense.id == null) return;
    final existing = await _expenseDao.getExpenseById(expense.id!);
    final updated = existing.copyWith(
      categoryId: expense.categoryId,
      accountId: expense.accountId,
      amount: expense.amount,
      title: expense.title,
      description: Value(expense.description),
      date: expense.date,
      isRecurring: expense.isRecurring,
      recurringType: Value(expense.recurringType),
      recurringInterval: Value(expense.recurringInterval),
      nextRecurringDate: Value(expense.nextRecurringDate),
      location: Value(expense.location),
      latitude: Value(expense.latitude),
      longitude: Value(expense.longitude),
      receiptPath: Value(expense.receiptPath),
      tags: Value(expense.tags != null ? jsonEncode(expense.tags) : null),
      splitWith: Value(expense.splitWith != null
          ? jsonEncode(expense.splitWith!.map((s) => s.toJson()).toList())
          : null),
      updatedAt: DateTime.now(),
    );
    await _expenseDao.updateExpense(updated);
  }

  @override
  Future<void> deleteExpense(int id) => _expenseDao.deleteExpense(id);

  @override
  Future<ExpenseEntity> getExpenseById(int id) async {
    final result = await _expenseDao.getExpenseById(id);
    return _mapToEntity(result);
  }

  @override
  Future<List<DailyTotal>> getDailyTotals(
          int userId, DateTime start, DateTime end) =>
      _expenseDao.getDailyTotals(userId, start, end);
}
