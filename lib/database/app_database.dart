import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/users_table.dart';
import 'tables/expenses_table.dart';
import 'tables/incomes_table.dart';
import 'tables/categories_table.dart';
import 'tables/accounts_table.dart';
import 'tables/budgets_table.dart';
import 'tables/transactions_table.dart';
import 'tables/attachments_table.dart';
import 'daos/user_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/income_dao.dart';
import 'daos/category_dao.dart';
import 'daos/account_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/transaction_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Expenses,
    Incomes,
    Categories,
    Accounts,
    Budgets,
    Transactions,
    Attachments,
  ],
  daos: [
    UserDao,
    ExpenseDao,
    IncomeDao,
    CategoryDao,
    AccountDao,
    BudgetDao,
    TransactionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(users, users.passwordHash);
        }
      },
    );
  }

  Future<void> _seedDefaultData() async {
    // Seed default categories
    final defaultExpenseCategories = [
      {'name': 'Food & Dining', 'icon': 'restaurant', 'color': '#FF5722', 'type': 'expense'},
      {'name': 'Transportation', 'icon': 'directions_car', 'color': '#2196F3', 'type': 'expense'},
      {'name': 'Shopping', 'icon': 'shopping_bag', 'color': '#9C27B0', 'type': 'expense'},
      {'name': 'Entertainment', 'icon': 'movie', 'color': '#E91E63', 'type': 'expense'},
      {'name': 'Bills & Utilities', 'icon': 'receipt_long', 'color': '#FF9800', 'type': 'expense'},
      {'name': 'Health', 'icon': 'local_hospital', 'color': '#4CAF50', 'type': 'expense'},
      {'name': 'Education', 'icon': 'school', 'color': '#3F51B5', 'type': 'expense'},
      {'name': 'Housing', 'icon': 'home', 'color': '#795548', 'type': 'expense'},
      {'name': 'Personal Care', 'icon': 'spa', 'color': '#00BCD4', 'type': 'expense'},
      {'name': 'Gifts & Donations', 'icon': 'card_giftcard', 'color': '#F44336', 'type': 'expense'},
      {'name': 'Travel', 'icon': 'flight', 'color': '#009688', 'type': 'expense'},
      {'name': 'Others', 'icon': 'more_horiz', 'color': '#607D8B', 'type': 'expense'},
    ];

    final defaultIncomeCategories = [
      {'name': 'Salary', 'icon': 'work', 'color': '#4CAF50', 'type': 'income'},
      {'name': 'Freelance', 'icon': 'laptop', 'color': '#2196F3', 'type': 'income'},
      {'name': 'Investment', 'icon': 'trending_up', 'color': '#FF9800', 'type': 'income'},
      {'name': 'Business', 'icon': 'business', 'color': '#9C27B0', 'type': 'income'},
      {'name': 'Rental', 'icon': 'apartment', 'color': '#795548', 'type': 'income'},
      {'name': 'Gift', 'icon': 'redeem', 'color': '#E91E63', 'type': 'income'},
      {'name': 'Others', 'icon': 'more_horiz', 'color': '#607D8B', 'type': 'income'},
    ];

    // We'll seed these when a user is created
    // Store them as userId=0 (template categories)
    for (final cat in defaultExpenseCategories) {
      await into(categories).insert(CategoriesCompanion.insert(
        userId: 0,
        name: cat['name']!,
        icon: Value(cat['icon']!),
        color: Value(cat['color']!),
        type: cat['type']!,
        isDefault: const Value(true),
      ));
    }

    for (final cat in defaultIncomeCategories) {
      await into(categories).insert(CategoriesCompanion.insert(
        userId: 0,
        name: cat['name']!,
        icon: Value(cat['icon']!),
        color: Value(cat['color']!),
        type: cat['type']!,
        isDefault: const Value(true),
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expense_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
