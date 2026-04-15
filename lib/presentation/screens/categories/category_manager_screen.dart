import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../utils/validators.dart';
import '../../../domain/entities/category.dart';

class CategoryManagerScreen extends ConsumerStatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  ConsumerState<CategoryManagerScreen> createState() =>
      _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends ConsumerState<CategoryManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(type: 'expense'),
          _CategoryList(type: 'income'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_category',
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedIcon = 'category';
    String selectedColor = '#4CAF50';
    String type = _tabController.index == 0 ? 'expense' : 'income';

    const icons = [
      'restaurant', 'shopping_cart', 'directions_car', 'home',
      'local_hospital', 'school', 'movie', 'sports_esports',
      'flight', 'pets', 'phone', 'power', 'wifi',
      'card_giftcard', 'work', 'trending_up', 'savings', 'category',
    ];
    const colors = [
      '#4CAF50', '#2196F3', '#E91E63', '#FF9800', '#9C27B0',
      '#00BCD4', '#FF5722', '#607D8B', '#795548', '#F44336',
      '#3F51B5', '#009688', '#FFEB3B', '#673AB7', '#8BC34A',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add Category',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),

                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(
                        value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'both', child: Text('Both')),
                  ],
                  onChanged: (v) =>
                      setSheetState(() => type = v ?? 'expense'),
                ),
                const SizedBox(height: 16),

                Text('Icon', style: Theme.of(ctx).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () =>
                          setSheetState(() => selectedIcon = icon),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(ctx).colorScheme.primary
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Icon(
                          AppFormatters.getIconData(icon),
                          size: 22,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text('Color', style: Theme.of(ctx).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((c) {
                    final color = Color(
                        int.parse(c.substring(1), radix: 16) + 0xFF000000);
                    return GestureDetector(
                      onTap: () =>
                          setSheetState(() => selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == c
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: selectedColor == c
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final user = ref.read(currentUserProvider);
                      final cat = CategoryEntity(
                        id: 0,
                        userId: user?.id ?? 1,
                        name: nameController.text.trim(),
                        icon: selectedIcon,
                        color: selectedColor,
                        type: type,
                        sortOrder: 0,
                        isDefault: false,
                        isActive: true,
                        createdAt: DateTime.now(),
                      );
                      ref.read(categoryActionsProvider).addCategory(cat);
                      Navigator.pop(ctx);
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Category'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    nameController.dispose();
  }
}

class _CategoryList extends ConsumerWidget {
  final String type;
  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = type == 'expense'
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text('No categories', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppFormatters.parseColor(cat.color)
                      .withValues(alpha: 0.15),
                  child: Icon(
                    AppFormatters.getIconData(cat.icon),
                    color: AppFormatters.parseColor(cat.color),
                    size: 22,
                  ),
                ),
                title: Text(cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: !cat.isDefault
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error, size: 20),
                        onPressed: () => _confirmDelete(context, ref, cat),
                      )
                    : const Chip(
                        label: Text('Default',
                            style: TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                      ),
              ),
            )
                .animate(delay: Duration(milliseconds: 30 * index))
                .fadeIn(duration: 200.ms);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, CategoryEntity cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${cat.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(categoryActionsProvider).deleteCategory(cat.id!);
    }
  }
}
