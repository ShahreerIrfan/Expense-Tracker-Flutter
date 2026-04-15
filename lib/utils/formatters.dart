import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

class AppFormatters {
  AppFormatters._();

  static String currency(double amount, {String currencyCode = 'BDT'}) {
    final symbol = AppConstants.currencySymbols[currencyCode] ?? currencyCode;
    final formatter = NumberFormat('#,##0.00');
    return '$symbol${formatter.format(amount)}';
  }

  static String compactCurrency(double amount, {String currencyCode = 'BDT'}) {
    final symbol = AppConstants.currencySymbols[currencyCode] ?? currencyCode;
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime date, {String? format}) {
    return DateFormat(format ?? 'MMM dd, yyyy').format(date);
  }

  static String dateShort(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String dayMonth(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static Color parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static IconData getIconData(String iconName) {
    return _iconMap[iconName] ?? Icons.category;
  }

  static List<MapEntry<String, IconData>> get availableIcons =>
      _iconMap.entries.toList();

  static const Map<String, IconData> _iconMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'movie': Icons.movie,
    'receipt_long': Icons.receipt_long,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'home': Icons.home,
    'spa': Icons.spa,
    'card_giftcard': Icons.card_giftcard,
    'flight': Icons.flight,
    'more_horiz': Icons.more_horiz,
    'work': Icons.work,
    'laptop': Icons.laptop,
    'trending_up': Icons.trending_up,
    'business': Icons.business,
    'apartment': Icons.apartment,
    'redeem': Icons.redeem,
    'category': Icons.category,
    'money': Icons.money,
    'account_balance': Icons.account_balance,
    'phone_android': Icons.phone_android,
    'account_balance_wallet': Icons.account_balance_wallet,
    'credit_card': Icons.credit_card,
    'savings': Icons.savings,
    'attach_money': Icons.attach_money,
    'local_atm': Icons.local_atm,
    'store': Icons.store,
    'local_grocery_store': Icons.local_grocery_store,
    'local_cafe': Icons.local_cafe,
    'fitness_center': Icons.fitness_center,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'local_gas_station': Icons.local_gas_station,
    'build': Icons.build,
    'wifi': Icons.wifi,
    'phone': Icons.phone,
    'local_library': Icons.local_library,
    'medical_services': Icons.medical_services,
    'sports_esports': Icons.sports_esports,
    'music_note': Icons.music_note,
    'shopping_cart': Icons.shopping_cart,
    'checkroom': Icons.checkroom,
    'celebration': Icons.celebration,
  };
}
