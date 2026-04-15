class AppConstants {
  AppConstants._();

  static const String appName = 'Expense Tracker';
  static const String developerName = 'Muhammad Shahreer Irfan';
  static const String appVersion = '1.0.0';
  static const String defaultCurrency = 'BDT';
  static const String defaultLanguage = 'en';

  // Auto-lock timeout in minutes
  static const int autoLockTimeout = 5;

  // Budget alert thresholds
  static const double budgetAlert50 = 50.0;
  static const double budgetAlert80 = 80.0;
  static const double budgetAlert100 = 100.0;

  // Image compression
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 80;

  // Pagination
  static const int defaultPageSize = 20;

  // Currency symbols
  static const Map<String, String> currencySymbols = {
    'BDT': '৳',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
    'SAR': '﷼',
    'AED': 'د.إ',
    'MYR': 'RM',
  };

  // Account types
  static const List<String> accountTypes = [
    'cash',
    'bank',
    'mobile_wallet',
    'credit_card',
  ];

  // Recurring types
  static const List<String> recurringTypes = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];

  // Budget periods
  static const List<String> budgetPeriods = [
    'weekly',
    'monthly',
    'yearly',
  ];
}
