import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/income_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../utils/helpers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedPeriod = 2; // monthly
  int _selectedChart = 0; // 0=pie, 1=bar

  DateTimeRange get _range {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 0:
        return DateTimeRange(start: now.startOfDay, end: now.endOfDay);
      case 1:
        return DateTimeRange(start: now.startOfWeek, end: now.endOfWeek);
      case 2:
        return DateTimeRange(start: now.startOfMonth, end: now.endOfMonth);
      case 3:
        return DateTimeRange(start: now.startOfYear, end: now.endOfYear);
      default:
        return DateTimeRange(start: now.startOfMonth, end: now.endOfMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final currency = user?.currency ?? AppConstants.defaultCurrency;
    final range = (start: _range.start, end: _range.end);
    final categoryTotalsAsync = ref.watch(categoryTotalsProvider(range));
    final totalExpenseAsync = ref.watch(totalExpenseProvider(range));
    final totalIncomeAsync = ref.watch(totalIncomeProvider(range));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period selector
          Row(
            children: ['Day', 'Week', 'Month', 'Year']
                .asMap()
                .entries
                .map((e) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(e.value),
                          selected: _selectedPeriod == e.key,
                          onSelected: (_) =>
                              setState(() => _selectedPeriod = e.key),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Income',
                  asyncValue: totalIncomeAsync,
                  currency: currency,
                  color: AppColors.income,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Expenses',
                  asyncValue: totalExpenseAsync,
                  currency: currency,
                  color: AppColors.expense,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 8),

          // Net savings
          totalExpenseAsync.when(
            data: (expense) => totalIncomeAsync.when(
              data: (income) {
                final net = income - expense;
                return Card(
                  color: net >= 0
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.error.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(net >= 0 ? 'Net Savings' : 'Net Loss',
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          AppFormatters.currency(net.abs(),
                              currencyCode: currency),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color:
                                net >= 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),

          // Chart type toggle
          Row(
            children: [
              Text('Expense Breakdown',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              ToggleButtons(
                isSelected: [_selectedChart == 0, _selectedChart == 1],
                onPressed: (i) => setState(() => _selectedChart = i),
                borderRadius: BorderRadius.circular(8),
                constraints:
                    const BoxConstraints(minWidth: 40, minHeight: 36),
                children: const [
                  Icon(Icons.pie_chart, size: 20),
                  Icon(Icons.bar_chart, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          categoryTotalsAsync.when(
            data: (totals) {
              if (totals.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                      child: Text('No data for this period',
                          style: TextStyle(color: Colors.grey))),
                );
              }

              if (_selectedChart == 0) {
                return _buildPieChart(totals, currency);
              } else {
                return _buildBarChart(totals, currency);
              }
            },
            loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(
                height: 200, child: Center(child: Text('Error'))),
          ),

          const SizedBox(height: 20),

          // Category details
          categoryTotalsAsync.when(
            data: (totals) {
              final total =
                  totals.fold<double>(0, (s, t) => s + t.total);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...totals.map((ct) {
                    final pct =
                        total > 0 ? (ct.total / total * 100) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color:
                                  AppFormatters.parseColor(ct.categoryColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(ct.categoryName)),
                          Text('${pct.toStringAsFixed(1)}%',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 12),
                          Text(
                            AppFormatters.currency(ct.total,
                                currencyCode: currency),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<dynamic> totals, String currency) {
    final total = totals.fold<double>(0, (s, t) => s + (t.total as double));
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: totals.map((ct) {
            final pct = total > 0 ? ct.total / total * 100 : 0.0;
            return PieChartSectionData(
              value: ct.total,
              title: '${pct.toStringAsFixed(0)}%',
              color: AppFormatters.parseColor(ct.categoryColor),
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            );
          }).toList(),
        ),
      ),
    ).animate().scale(duration: 400.ms, begin: const Offset(0.8, 0.8));
  }

  Widget _buildBarChart(List<dynamic> totals, String currency) {
    final maxVal = totals.fold<double>(
        0, (m, t) => (t.total as double) > m ? t.total : m);

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final ct = totals[groupIndex];
                return BarTooltipItem(
                  '${ct.categoryName}\n${AppFormatters.currency(ct.total, currencyCode: currency)}',
                  const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= totals.length) {
                    return const SizedBox.shrink();
                  }
                  final name = totals[value.toInt()].categoryName as String;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      name.length > 5 ? '${name.substring(0, 5)}..' : name,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: totals.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.total,
                  color: AppFormatters.parseColor(e.value.categoryColor),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(currentUserProvider);
      final currency = user?.currency ?? AppConstants.defaultCurrency;
      final range = (start: _range.start, end: _range.end);
      final totals = await ref.read(categoryTotalsProvider(range).future);
      final totalExp = await ref.read(totalExpenseProvider(range).future);
      final totalInc = await ref.read(totalIncomeProvider(range).future);

      final exportService = ref.read(exportServiceProvider);
      final path = await exportService.generatePdfReport(
        userName: user?.name ?? 'User',
        totalIncome: totalInc,
        totalExpense: totalExp,
        categoryTotals: totals,
        startDate: _range.start,
        endDate: _range.end,
        currency: currency,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final AsyncValue<double> asyncValue;
  final String currency;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.asyncValue,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            asyncValue.when(
              data: (v) => Text(
                AppFormatters.currency(v, currencyCode: currency),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
              loading: () => const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => const Text('---'),
            ),
          ],
        ),
      ),
    );
  }
}
