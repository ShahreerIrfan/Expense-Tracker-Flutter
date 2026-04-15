import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../utils/validators.dart';
import '../../../utils/helpers.dart';
import '../../../domain/entities/budget.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  int? _selectedCategoryId;
  String _period = 'monthly';
  DateTime _startDate = DateTime.now().startOfMonth;
  DateTime _endDate = DateTime.now().endOfMonth;
  bool _rollover = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateDatesForPeriod() {
    final now = DateTime.now();
    switch (_period) {
      case 'daily':
        _startDate = now.startOfDay;
        _endDate = now.endOfDay;
        break;
      case 'weekly':
        _startDate = now.startOfWeek;
        _endDate = now.endOfWeek;
        break;
      case 'monthly':
        _startDate = now.startOfMonth;
        _endDate = now.endOfMonth;
        break;
      case 'yearly':
        _startDate = now.startOfYear;
        _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[300]),
                labelText: 'Budget Limit',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 20),

            // Category (optional)
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<int?>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category (optional - leave empty for overall)',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Overall Budget (all categories)'),
                  ),
                  ...categories.map((c) => DropdownMenuItem<int?>(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(AppFormatters.getIconData(c.icon),
                                size: 20,
                                color: AppFormatters.parseColor(c.color)),
                            const SizedBox(width: 8),
                            Text(c.name),
                          ],
                        ),
                      )),
                ],
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading categories'),
            ),
            const SizedBox(height: 16),

            // Period
            DropdownButtonFormField<String>(
              value: _period,
              decoration: InputDecoration(
                labelText: 'Budget Period',
                prefixIcon: const Icon(Icons.date_range),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: AppConstants.budgetPeriods
                  .map((p) => DropdownMenuItem(
                      value: p, child: Text(p.capitalize)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _period = v;
                    _updateDatesForPeriod();
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Date range display
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppFormatters.date(_startDate)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppFormatters.date(_endDate)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Rollover Unused Budget'),
              subtitle: const Text(
                  'Carry unused budget to the next period'),
              value: _rollover,
              onChanged: (v) => setState(() => _rollover = v),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _isLoading ? null : _saveBudget,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: const Text('Create Budget'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final budget = BudgetEntity(
        id: 0,
        userId: user?.id ?? 1,
        categoryId: _selectedCategoryId,
        amount: double.parse(_amountController.text),
        spent: 0,
        period: _period,
        startDate: _startDate,
        endDate: _endDate,
        rollover: _rollover,
        rolloverAmount: 0,
        alertAt50: true,
        alertAt80: true,
        alertAt100: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(budgetActionsProvider).addBudget(budget);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget created'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
