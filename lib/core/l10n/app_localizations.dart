import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _enTranslations,
    'bn': _bnTranslations,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static List<Locale> get supportedLocales => const [Locale('en'), Locale('bn')];

  // Convenience getters
  String get appName => translate('app_name');
  String get dashboard => translate('dashboard');
  String get expenses => translate('expenses');
  String get income => translate('income');
  String get budgets => translate('budgets');
  String get accounts => translate('accounts');
  String get categories => translate('categories');
  String get reports => translate('reports');
  String get settings => translate('settings');
  String get search => translate('search');
  String get backup => translate('backup');
  String get about => translate('about');
  String get addExpense => translate('add_expense');
  String get addIncome => translate('add_income');
  String get addBudget => translate('add_budget');
  String get addAccount => translate('add_account');
  String get addCategory => translate('add_category');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get total => translate('total');
  String get balance => translate('balance');
  String get amount => translate('amount');
  String get title => translate('title_field');
  String get description => translate('description');
  String get date => translate('date');
  String get category => translate('category');
  String get account => translate('account');
  String get daily => translate('daily');
  String get weekly => translate('weekly');
  String get monthly => translate('monthly');
  String get yearly => translate('yearly');
  String get today => translate('today');
  String get thisWeek => translate('this_week');
  String get thisMonth => translate('this_month');
  String get thisYear => translate('this_year');
  String get noData => translate('no_data');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get darkMode => translate('dark_mode');
  String get language => translate('language');
  String get currency => translate('currency');
  String get notifications => translate('notifications');
  String get security => translate('security');
  String get pin => translate('pin');
  String get biometric => translate('biometric');
  String get exportData => translate('export_data');
  String get importData => translate('import_data');
  String get profile => translate('profile');
  String get switchAccount => translate('switch_account');
  String get createProfile => translate('create_profile');
  String get totalIncome => translate('total_income');
  String get totalExpense => translate('total_expense');
  String get netBalance => translate('net_balance');
  String get recentTransactions => translate('recent_transactions');
  String get viewAll => translate('view_all');
  String get budgetAlert => translate('budget_alert');
  String get overBudget => translate('over_budget');
  String get remaining => translate('remaining');
  String get spent => translate('spent');
  String get transfer => translate('transfer');
  String get recurring => translate('recurring');
  String get receipt => translate('receipt');
  String get location => translate('location');
  String get tags => translate('tags');
  String get split => translate('split');
  String get voiceInput => translate('voice_input');
  String get insights => translate('insights');
}

const Map<String, String> _enTranslations = {
  'app_name': 'Expense Tracker',
  'dashboard': 'Dashboard',
  'expenses': 'Expenses',
  'income': 'Income',
  'budgets': 'Budgets',
  'accounts': 'Accounts',
  'categories': 'Categories',
  'reports': 'Reports',
  'settings': 'Settings',
  'search': 'Search',
  'backup': 'Backup & Restore',
  'about': 'About',
  'add_expense': 'Add Expense',
  'add_income': 'Add Income',
  'add_budget': 'Add Budget',
  'add_account': 'Add Account',
  'add_category': 'Add Category',
  'edit': 'Edit',
  'delete': 'Delete',
  'save': 'Save',
  'cancel': 'Cancel',
  'confirm': 'Confirm',
  'total': 'Total',
  'balance': 'Balance',
  'amount': 'Amount',
  'title_field': 'Title',
  'description': 'Description',
  'date': 'Date',
  'category': 'Category',
  'account': 'Account',
  'daily': 'Daily',
  'weekly': 'Weekly',
  'monthly': 'Monthly',
  'yearly': 'Yearly',
  'today': 'Today',
  'this_week': 'This Week',
  'this_month': 'This Month',
  'this_year': 'This Year',
  'no_data': 'No data found',
  'loading': 'Loading...',
  'error': 'An error occurred',
  'success': 'Success',
  'dark_mode': 'Dark Mode',
  'language': 'Language',
  'currency': 'Currency',
  'notifications': 'Notifications',
  'security': 'Security',
  'pin': 'PIN',
  'biometric': 'Biometric',
  'export_data': 'Export Data',
  'import_data': 'Import Data',
  'profile': 'Profile',
  'switch_account': 'Switch Account',
  'create_profile': 'Create Profile',
  'total_income': 'Total Income',
  'total_expense': 'Total Expense',
  'net_balance': 'Net Balance',
  'recent_transactions': 'Recent Transactions',
  'view_all': 'View All',
  'budget_alert': 'Budget Alert',
  'over_budget': 'Over Budget!',
  'remaining': 'Remaining',
  'spent': 'Spent',
  'transfer': 'Transfer',
  'recurring': 'Recurring',
  'receipt': 'Receipt',
  'location': 'Location',
  'tags': 'Tags',
  'split': 'Split',
  'voice_input': 'Voice Input',
  'insights': 'Smart Insights',
};

const Map<String, String> _bnTranslations = {
  'app_name': 'ব্যয় ট্র্যাকার',
  'dashboard': 'ড্যাশবোর্ড',
  'expenses': 'ব্যয়',
  'income': 'আয়',
  'budgets': 'বাজেট',
  'accounts': 'অ্যাকাউন্ট',
  'categories': 'বিভাগ',
  'reports': 'রিপোর্ট',
  'settings': 'সেটিংস',
  'search': 'অনুসন্ধান',
  'backup': 'ব্যাকআপ ও পুনরুদ্ধার',
  'about': 'সম্পর্কে',
  'add_expense': 'ব্যয় যোগ করুন',
  'add_income': 'আয় যোগ করুন',
  'add_budget': 'বাজেট যোগ করুন',
  'add_account': 'অ্যাকাউন্ট যোগ করুন',
  'add_category': 'বিভাগ যোগ করুন',
  'edit': 'সম্পাদনা',
  'delete': 'মুছে ফেলুন',
  'save': 'সংরক্ষণ',
  'cancel': 'বাতিল',
  'confirm': 'নিশ্চিত',
  'total': 'মোট',
  'balance': 'ব্যালেন্স',
  'amount': 'পরিমাণ',
  'title_field': 'শিরোনাম',
  'description': 'বিবরণ',
  'date': 'তারিখ',
  'category': 'বিভাগ',
  'account': 'অ্যাকাউন্ট',
  'daily': 'দৈনিক',
  'weekly': 'সাপ্তাহিক',
  'monthly': 'মাসিক',
  'yearly': 'বার্ষিক',
  'today': 'আজ',
  'this_week': 'এই সপ্তাহ',
  'this_month': 'এই মাস',
  'this_year': 'এই বছর',
  'no_data': 'কোনো তথ্য পাওয়া যায়নি',
  'loading': 'লোড হচ্ছে...',
  'error': 'একটি ত্রুটি ঘটেছে',
  'success': 'সফল',
  'dark_mode': 'ডার্ক মোড',
  'language': 'ভাষা',
  'currency': 'মুদ্রা',
  'notifications': 'বিজ্ঞপ্তি',
  'security': 'নিরাপত্তা',
  'pin': 'পিন',
  'biometric': 'বায়োমেট্রিক',
  'export_data': 'ডেটা রপ্তানি',
  'import_data': 'ডেটা আমদানি',
  'profile': 'প্রোফাইল',
  'switch_account': 'অ্যাকাউন্ট পরিবর্তন',
  'create_profile': 'প্রোফাইল তৈরি করুন',
  'total_income': 'মোট আয়',
  'total_expense': 'মোট ব্যয়',
  'net_balance': 'নিট ব্যালেন্স',
  'recent_transactions': 'সাম্প্রতিক লেনদেন',
  'view_all': 'সব দেখুন',
  'budget_alert': 'বাজেট সতর্কতা',
  'over_budget': 'বাজেট ছাড়িয়েছে!',
  'remaining': 'অবশিষ্ট',
  'spent': 'ব্যয়িত',
  'transfer': 'স্থানান্তর',
  'recurring': 'পুনরাবৃত্তি',
  'receipt': 'রসিদ',
  'location': 'অবস্থান',
  'tags': 'ট্যাগ',
  'split': 'বিভক্ত',
  'voice_input': 'ভয়েস ইনপুট',
  'insights': 'স্মার্ট ইনসাইটস',
};

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
