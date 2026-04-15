import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';

class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  Future<String> exportToJson(int userId) async {
    final expenses = await _db.expenseDao.getAllExpenses(userId);
    final incomes = await _db.incomeDao.getAllIncomes(userId);
    final categories = await _db.categoryDao.getAllCategories(userId);
    final accounts = await _db.accountDao.getAllAccounts(userId);
    final budgets = await _db.budgetDao.getAllBudgets(userId);

    final data = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
      'expenses': expenses
          .map((e) => {
                'id': e.id,
                'categoryId': e.categoryId,
                'accountId': e.accountId,
                'amount': e.amount,
                'title': e.title,
                'description': e.description,
                'date': e.date.toIso8601String(),
                'isRecurring': e.isRecurring,
                'recurringType': e.recurringType,
                'location': e.location,
                'tags': e.tags,
              })
          .toList(),
      'incomes': incomes
          .map((i) => {
                'id': i.id,
                'categoryId': i.categoryId,
                'accountId': i.accountId,
                'amount': i.amount,
                'title': i.title,
                'description': i.description,
                'source': i.source,
                'date': i.date.toIso8601String(),
                'isRecurring': i.isRecurring,
              })
          .toList(),
      'categories': categories
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'icon': c.icon,
                'color': c.color,
                'type': c.type,
                'parentId': c.parentId,
              })
          .toList(),
      'accounts': accounts
          .map((a) => {
                'id': a.id,
                'name': a.name,
                'type': a.type,
                'balance': a.balance,
                'initialBalance': a.initialBalance,
                'currency': a.currency,
              })
          .toList(),
      'budgets': budgets
          .map((b) => {
                'id': b.id,
                'categoryId': b.categoryId,
                'amount': b.amount,
                'spent': b.spent,
                'period': b.period,
                'startDate': b.startDate.toIso8601String(),
                'endDate': b.endDate.toIso8601String(),
                'rollover': b.rollover,
              })
          .toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/expense_backup_$timestamp.json');
    await file.writeAsString(jsonStr);
    return file.path;
  }

  Future<String> exportToCsv(int userId) async {
    final expenses = await _db.expenseDao.getAllExpenses(userId);

    final rows = <List<dynamic>>[
      ['ID', 'Title', 'Amount', 'Date', 'Category ID', 'Account ID', 'Description', 'Recurring', 'Location'],
      ...expenses.map((e) => [
            e.id,
            e.title,
            e.amount,
            DateFormat('yyyy-MM-dd').format(e.date),
            e.categoryId,
            e.accountId,
            e.description ?? '',
            e.isRecurring ? 'Yes' : 'No',
            e.location ?? '',
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/expenses_$timestamp.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  Future<Map<String, dynamic>?> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      if (data['version'] == null) return null;
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getBackupFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir
        .listSync()
        .where((f) =>
            f.path.endsWith('.json') &&
            f.path.contains('expense_backup'))
        .map((f) => f.path)
        .toList();
    files.sort((a, b) => b.compareTo(a));
    return files;
  }

  Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
