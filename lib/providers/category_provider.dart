import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/category.dart';
import 'database_provider.dart';
import 'auth_provider.dart';

// All categories
final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return [];
  return ref.watch(categoryRepositoryProvider).getAllCategories(user!.id!);
});

// Expense categories
final expenseCategoriesProvider =
    FutureProvider<List<CategoryEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return [];
  return ref
      .watch(categoryRepositoryProvider)
      .getExpenseCategories(user!.id!);
});

// Income categories
final incomeCategoriesProvider =
    FutureProvider<List<CategoryEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return [];
  return ref
      .watch(categoryRepositoryProvider)
      .getIncomeCategories(user!.id!);
});

// Category actions
final categoryActionsProvider =
    Provider<CategoryActions>((ref) => CategoryActions(ref));

class CategoryActions {
  final Ref _ref;

  CategoryActions(this._ref);

  Future<int> addCategory(CategoryEntity category) =>
      _ref.read(categoryRepositoryProvider).addCategory(category);

  Future<void> updateCategory(CategoryEntity category) =>
      _ref.read(categoryRepositoryProvider).updateCategory(category);

  Future<void> deleteCategory(int id) =>
      _ref.read(categoryRepositoryProvider).deleteCategory(id);
}
