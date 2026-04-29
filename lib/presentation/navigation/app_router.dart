import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/profile_select_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/expenses/expense_detail_screen.dart';
import '../screens/income/add_income_screen.dart';
import '../screens/budgets/add_budget_screen.dart';
import '../screens/accounts/account_list_screen.dart';
import '../screens/accounts/add_account_screen.dart';
import '../screens/categories/category_manager_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/backup/backup_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/cloud/cloud_sync_screen.dart';
import 'home_shell.dart';

class AppRouter {
  static const String splash = '/';
  static const String profileSelect = '/profile-select';
  static const String home = '/home';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String expenseDetail = '/expense-detail';
  static const String addIncome = '/add-income';
  static const String addBudget = '/add-budget';
  static const String accounts = '/accounts';
  static const String addAccount = '/add-account';
  static const String categories = '/categories';
  static const String reports = '/reports';
  static const String search = '/search';
  static const String backup = '/backup';
  static const String about = '/about';
  static const String cloudSync = '/cloud-sync';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case profileSelect:
        return MaterialPageRoute(builder: (_) => const ProfileSelectScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case addExpense:
        return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
      case editExpense:
        final id = settings.arguments as int?;
        return MaterialPageRoute(
            builder: (_) => AddExpenseScreen(expenseId: id));
      case expenseDetail:
        final id = settings.arguments as int;
        return MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(expenseId: id));
      case addIncome:
        return MaterialPageRoute(builder: (_) => const AddIncomeScreen());
      case addBudget:
        return MaterialPageRoute(builder: (_) => const AddBudgetScreen());
      case accounts:
        return MaterialPageRoute(builder: (_) => const AccountListScreen());
      case addAccount:
        return MaterialPageRoute(builder: (_) => const AddAccountScreen());
      case categories:
        return MaterialPageRoute(
            builder: (_) => const CategoryManagerScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case backup:
        return MaterialPageRoute(builder: (_) => const BackupScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case cloudSync:
        return MaterialPageRoute(builder: (_) => const CloudSyncScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
