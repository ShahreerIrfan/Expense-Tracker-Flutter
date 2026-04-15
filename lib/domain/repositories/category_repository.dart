import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories(int userId);
  Future<List<CategoryEntity>> getExpenseCategories(int userId);
  Future<List<CategoryEntity>> getIncomeCategories(int userId);
  Stream<List<CategoryEntity>> watchAllCategories(int userId);
  Future<List<CategoryEntity>> getChildCategories(int parentId);
  Future<int> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(int id);
  Future<CategoryEntity> getCategoryById(int id);
  Future<void> copyDefaultCategoriesToUser(int userId);
}
