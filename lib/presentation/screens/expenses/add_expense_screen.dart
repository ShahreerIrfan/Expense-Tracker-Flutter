import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../utils/validators.dart';
import '../../../utils/helpers.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/account.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final int? expenseId;
  const AddExpenseScreen({super.key, this.expenseId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int? _selectedCategoryId;
  int? _selectedAccountId;
  bool _isRecurring = false;
  String _recurringType = 'monthly';
  bool _isLoading = false;

  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExpense();
    }
  }

  Future<void> _loadExpense() async {
    // Load existing expense data for editing
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Amount field (big)
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
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('৳',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expense)),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: AppColors.expense.withValues(alpha: 0.05),
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: Validators.required,
            ),
            const SizedBox(height: 16),

            // Category selector
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(
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
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading categories'),
            ),
            const SizedBox(height: 16),

            // Account selector
            accountsAsync.when(
              data: (accounts) => DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: 'Account',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: accounts
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Row(
                            children: [
                              Icon(AppFormatters.getIconData(a.icon), size: 20),
                              const SizedBox(width: 8),
                              Text('${a.name} (${AppFormatters.compactCurrency(a.balance)})'),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAccountId = v),
                validator: (v) => v == null ? 'Select an account' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading accounts'),
            ),
            const SizedBox(height: 16),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppFormatters.date(_selectedDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Time',
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Tags (comma separated)',
                prefixIcon: const Icon(Icons.tag),
                hintText: 'e.g., food, lunch, office',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Recurring toggle
            SwitchListTile(
              title: const Text('Recurring Expense'),
              subtitle: const Text('Repeat this expense periodically'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
              contentPadding: EdgeInsets.zero,
            ),

            if (_isRecurring) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _recurringType,
                decoration: InputDecoration(
                  labelText: 'Repeat',
                  prefixIcon: const Icon(Icons.repeat),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: AppConstants.recurringTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.capitalize),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _recurringType = v ?? 'monthly'),
              ),
            ],

            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _isLoading ? null : _saveExpense,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(_isEditing ? 'Update Expense' : 'Save Expense'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.expense,
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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final tags = _tagsController.text.isNotEmpty
          ? _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
          : <String>[];

      final expense = ExpenseEntity(
        id: widget.expenseId ?? 0,
        userId: user?.id ?? 1,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        amount: double.parse(_amountController.text),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: dateTime,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final actions = ref.read(expenseActionsProvider);
      if (_isEditing) {
        await actions.updateExpense(expense, 0, expense.accountId);
      } else {
        await actions.addExpense(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Expense updated' : 'Expense added'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
      // Auto-sync in background
      final uid = user?.id;
      if (uid != null) {
        ref.read(cloudSyncServiceProvider).autoSync(uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
