import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/daos/expense_dao.dart';
import '../database/daos/income_dao.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/account_dao.dart';
import '../database/daos/budget_dao.dart';
import '../database/daos/user_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../data/repositories/expense_repository_impl.dart';
import '../data/repositories/income_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/account_repository_impl.dart';
import '../data/repositories/budget_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/income_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../services/backup_service.dart';
import '../services/export_service.dart';
import '../services/ai_insight_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/cloud_auth_service.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// DAO providers
final userDaoProvider = Provider<UserDao>((ref) {
  return ref.watch(databaseProvider).userDao;
});

final expenseDaoProvider = Provider<ExpenseDao>((ref) {
  return ref.watch(databaseProvider).expenseDao;
});

final incomeDaoProvider = Provider<IncomeDao>((ref) {
  return ref.watch(databaseProvider).incomeDao;
});

final categoryDaoProvider = Provider<CategoryDao>((ref) {
  return ref.watch(databaseProvider).categoryDao;
});

final accountDaoProvider = Provider<AccountDao>((ref) {
  return ref.watch(databaseProvider).accountDao;
});

final budgetDaoProvider = Provider<BudgetDao>((ref) {
  return ref.watch(databaseProvider).budgetDao;
});

final transactionDaoProvider = Provider<TransactionDao>((ref) {
  return ref.watch(databaseProvider).transactionDao;
});

// Repository providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userDaoProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseDaoProvider));
});

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  return IncomeRepositoryImpl(ref.watch(incomeDaoProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryDaoProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountDaoProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(budgetDaoProvider));
});

// Service providers
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

final aiInsightServiceProvider = Provider<AiInsightService>((ref) {
  return AiInsightService();
});

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(ref.watch(databaseProvider));
});

final cloudAuthServiceProvider = Provider<CloudAuthService>((ref) {
  return CloudAuthService(ref.watch(databaseProvider));
});
