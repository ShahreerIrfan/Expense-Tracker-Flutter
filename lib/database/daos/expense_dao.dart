import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/expenses_table.dart';
import '../tables/categories_table.dart';
import '../tables/accounts_table.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses, Categories, Accounts])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  // Get all expenses for a user
  Future<List<Expense>> getAllExpenses(int userId) =>
      (select(expenses)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  // Watch all expenses
  Stream<List<Expense>> watchAllExpenses(int userId) =>
      (select(expenses)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
      int userId, DateTime start, DateTime end) =>
      (select(expenses)
            ..where((t) =>
                t.userId.equals(userId) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<Expense>> watchExpensesByDateRange(
      int userId, DateTime start, DateTime end) =>
      (select(expenses)
            ..where((t) =>
                t.userId.equals(userId) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(int userId, int categoryId) =>
      (select(expenses)
            ..where((t) =>
                t.userId.equals(userId) & t.categoryId.equals(categoryId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  // Get expenses by account
  Future<List<Expense>> getExpensesByAccount(int userId, int accountId) =>
      (select(expenses)
            ..where((t) =>
                t.userId.equals(userId) & t.accountId.equals(accountId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  // Get total expense for date range
  Future<double> getTotalExpense(
      int userId, DateTime start, DateTime end) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.userId.equals(userId) &
          expenses.date.isBiggerOrEqualValue(start) &
          expenses.date.isSmallerOrEqualValue(end));
    final result = await query.getSingle();
    return result.read(expenses.amount.sum()) ?? 0.0;
  }

  // Get total by category for date range
  Future<List<CategoryTotal>> getTotalByCategory(
      int userId, DateTime start, DateTime end) async {
    final query = select(expenses).join([
      innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
    ])
      ..where(expenses.userId.equals(userId) &
          expenses.date.isBiggerOrEqualValue(start) &
          expenses.date.isSmallerOrEqualValue(end))
      ..groupBy([categories.id, categories.name, categories.color, categories.icon])
      ..addColumns([expenses.amount.sum()]);

    final results = await query.get();
    return results.map((row) {
      return CategoryTotal(
        categoryId: row.readTable(categories).id,
        categoryName: row.readTable(categories).name,
        categoryColor: row.readTable(categories).color,
        categoryIcon: row.readTable(categories).icon,
        total: row.read(expenses.amount.sum()) ?? 0.0,
      );
    }).toList();
  }

  // Search expenses
  Future<List<Expense>> searchExpenses(int userId, String query) =>
      (select(expenses)
            ..where((t) =>
                t.userId.equals(userId) &
                (t.title.contains(query) | t.description.contains(query)))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  // Filter expenses
  Future<List<Expense>> filterExpenses({
    required int userId,
    int? categoryId,
    int? accountId,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = select(expenses)
      ..where((t) {
        Expression<bool> condition = t.userId.equals(userId);
        if (categoryId != null) {
          condition = condition & t.categoryId.equals(categoryId);
        }
        if (accountId != null) {
          condition = condition & t.accountId.equals(accountId);
        }
        if (minAmount != null) {
          condition = condition & t.amount.isBiggerOrEqualValue(minAmount);
        }
        if (maxAmount != null) {
          condition = condition & t.amount.isSmallerOrEqualValue(maxAmount);
        }
        if (startDate != null) {
          condition = condition & t.date.isBiggerOrEqualValue(startDate);
        }
        if (endDate != null) {
          condition = condition & t.date.isSmallerOrEqualValue(endDate);
        }
        return condition;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.get();
  }

  // Get recurring expenses
  Future<List<Expense>> getRecurringExpenses(int userId) =>
      (select(expenses)
            ..where(
                (t) => t.userId.equals(userId) & t.isRecurring.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  // CRUD
  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  Future<bool> updateExpense(Expense expense) =>
      update(expenses).replace(expense);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();

  Future<Expense> getExpenseById(int id) =>
      (select(expenses)..where((t) => t.id.equals(id))).getSingle();

  // Daily totals for charts
  Future<List<DailyTotal>> getDailyTotals(
      int userId, DateTime start, DateTime end) async {
    final results = await getExpensesByDateRange(userId, start, end);
    final Map<String, double> dailyMap = {};
    for (final expense in results) {
      final key =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      dailyMap[key] = (dailyMap[key] ?? 0) + expense.amount;
    }
    return dailyMap.entries
        .map((e) => DailyTotal(date: DateTime.parse(e.key), total: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

class CategoryTotal {
  final int categoryId;
  final String categoryName;
  final String categoryColor;
  final String categoryIcon;
  final double total;

  CategoryTotal({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.total,
  });
}

class DailyTotal {
  final DateTime date;
  final double total;

  DailyTotal({required this.date, required this.total});
}
