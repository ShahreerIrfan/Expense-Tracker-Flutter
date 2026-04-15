import '../domain/entities/expense.dart';
import '../database/daos/expense_dao.dart';

class AiInsightService {
  List<InsightItem> generateInsights({
    required List<ExpenseEntity> recentExpenses,
    required List<CategoryTotal> categoryTotals,
    required double totalIncome,
    required double totalExpense,
    required double lastMonthExpense,
  }) {
    final insights = <InsightItem>[];

    // 1. Spending trend
    if (lastMonthExpense > 0) {
      final changePercent =
          ((totalExpense - lastMonthExpense) / lastMonthExpense * 100);
      if (changePercent > 20) {
        insights.add(InsightItem(
          type: InsightType.warning,
          title: 'Spending Increased',
          description:
              'Your spending increased by ${changePercent.toStringAsFixed(0)}% compared to last month. Consider reviewing your expenses.',
          icon: 'trending_up',
        ));
      } else if (changePercent < -10) {
        insights.add(InsightItem(
          type: InsightType.positive,
          title: 'Great Savings!',
          description:
              'Your spending decreased by ${changePercent.abs().toStringAsFixed(0)}% compared to last month. Keep it up!',
          icon: 'trending_down',
        ));
      }
    }

    // 2. Savings rate
    if (totalIncome > 0) {
      final savingsRate = ((totalIncome - totalExpense) / totalIncome * 100);
      if (savingsRate < 10) {
        insights.add(InsightItem(
          type: InsightType.warning,
          title: 'Low Savings Rate',
          description:
              'You\'re saving only ${savingsRate.toStringAsFixed(0)}% of your income. Try to save at least 20%.',
          icon: 'savings',
        ));
      } else if (savingsRate >= 30) {
        insights.add(InsightItem(
          type: InsightType.positive,
          title: 'Excellent Saver!',
          description:
              'You\'re saving ${savingsRate.toStringAsFixed(0)}% of your income. That\'s excellent financial discipline!',
          icon: 'savings',
        ));
      }
    }

    // 3. Top spending category
    if (categoryTotals.isNotEmpty) {
      categoryTotals.sort((a, b) => b.total.compareTo(a.total));
      final topCategory = categoryTotals.first;
      final topPercentage = totalExpense > 0
          ? (topCategory.total / totalExpense * 100)
          : 0.0;

      if (topPercentage > 40) {
        insights.add(InsightItem(
          type: InsightType.tip,
          title: 'High Category Spending',
          description:
              '${topCategory.categoryName} accounts for ${topPercentage.toStringAsFixed(0)}% of your expenses. Consider reducing spending in this area.',
          icon: 'pie_chart',
        ));
      }
    }

    // 4. Frequent small expenses
    final smallExpenses =
        recentExpenses.where((e) => e.amount < 100).toList();
    if (smallExpenses.length > 10) {
      final totalSmall =
          smallExpenses.fold<double>(0, (sum, e) => sum + e.amount);
      insights.add(InsightItem(
        type: InsightType.tip,
        title: 'Watch Small Expenses',
        description:
            'You made ${smallExpenses.length} small transactions totaling ${totalSmall.toStringAsFixed(0)}. Small expenses add up quickly!',
        icon: 'attach_money',
      ));
    }

    // 5. Weekend spending pattern
    final weekendExpenses = recentExpenses
        .where((e) =>
            e.date.weekday == DateTime.saturday ||
            e.date.weekday == DateTime.sunday)
        .toList();
    if (weekendExpenses.isNotEmpty) {
      final weekendTotal =
          weekendExpenses.fold<double>(0, (sum, e) => sum + e.amount);
      final weekendPercent =
          totalExpense > 0 ? (weekendTotal / totalExpense * 100) : 0;
      if (weekendPercent > 40) {
        insights.add(InsightItem(
          type: InsightType.tip,
          title: 'Weekend Spending High',
          description:
              '${weekendPercent.toStringAsFixed(0)}% of your spending happens on weekends. Plan weekend activities to save more.',
          icon: 'weekend',
        ));
      }
    }

    // 6. Income vs Expense balance
    if (totalExpense > totalIncome && totalIncome > 0) {
      insights.add(InsightItem(
        type: InsightType.warning,
        title: 'Spending Exceeds Income',
        description:
            'You\'re spending more than you earn. Reduce expenses or find additional income sources.',
        icon: 'warning',
      ));
    }

    // Default positive message
    if (insights.isEmpty) {
      insights.add(InsightItem(
        type: InsightType.positive,
        title: 'Looking Good!',
        description:
            'Your finances are on track. Keep maintaining good spending habits!',
        icon: 'thumb_up',
      ));
    }

    return insights;
  }
}

class InsightItem {
  final InsightType type;
  final String title;
  final String description;
  final String icon;

  const InsightItem({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });
}

enum InsightType { positive, warning, tip }
