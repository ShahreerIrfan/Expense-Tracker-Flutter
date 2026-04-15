import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../domain/entities/expense.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  double? _minAmount;
  double? _maxAmount;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final currency = user?.currency ?? AppConstants.defaultCurrency;
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search expenses...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v.toLowerCase()),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters
                ? Icons.filter_list_off
                : Icons.filter_list),
            onPressed: () =>
                setState(() => _showFilters = !_showFilters),
          ),
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilters(),
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                var filtered = expenses.where((e) {
                  if (_query.isNotEmpty) {
                    final matchTitle =
                        e.title.toLowerCase().contains(_query);
                    final matchDesc =
                        e.description?.toLowerCase().contains(_query) ?? false;
                    final matchCategory =
                        e.categoryName?.toLowerCase().contains(_query) ??
                            false;
                    final matchTags = e.tags?.any(
                            (t) => t.toLowerCase().contains(_query)) ??
                        false;
                    if (!matchTitle &&
                        !matchDesc &&
                        !matchCategory &&
                        !matchTags) {
                      return false;
                    }
                  }
                  if (_minAmount != null && e.amount < _minAmount!) {
                    return false;
                  }
                  if (_maxAmount != null && e.amount > _maxAmount!) {
                    return false;
                  }
                  return true;
                }).toList();

                if (_query.isEmpty && !_showFilters) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Search your expenses',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('by title, category, tags, or description',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No results found',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final expense = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.expense.withValues(alpha: 0.1),
                        child: const Icon(Icons.arrow_upward,
                            color: AppColors.expense, size: 20),
                      ),
                      title: Text(expense.title,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        '${expense.categoryName ?? ""} • ${AppFormatters.relativeDate(expense.date)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        AppFormatters.currency(expense.amount,
                            currencyCode: currency),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.expense,
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(
                          context, '/expense-detail',
                          arguments: expense.id),
                    )
                        .animate(
                            delay: Duration(milliseconds: 20 * index))
                        .fadeIn(duration: 150.ms);
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount Range',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Min',
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) =>
                      setState(() => _minAmount = double.tryParse(v)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('—'),
              ),
              Expanded(
                child: TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Max',
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) =>
                      setState(() => _maxAmount = double.tryParse(v)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 200.ms);
  }
}
