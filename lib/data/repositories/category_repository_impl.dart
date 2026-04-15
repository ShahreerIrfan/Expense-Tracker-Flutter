import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/daos/category_dao.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDao _categoryDao;

  CategoryRepositoryImpl(this._categoryDao);

  CategoryEntity _mapToEntity(Category c) => CategoryEntity(
        id: c.id,
        userId: c.userId,
        name: c.name,
        icon: c.icon,
        color: c.color,
        type: c.type,
        parentId: c.parentId,
        sortOrder: c.sortOrder,
        isDefault: c.isDefault,
        isActive: c.isActive,
        createdAt: c.createdAt,
      );

  @override
  Future<List<CategoryEntity>> getAllCategories(int userId) async {
    final results = await _categoryDao.getAllCategories(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getExpenseCategories(int userId) async {
    final results = await _categoryDao.getExpenseCategories(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getIncomeCategories(int userId) async {
    final results = await _categoryDao.getIncomeCategories(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<CategoryEntity>> watchAllCategories(int userId) {
    return _categoryDao
        .watchAllCategories(userId)
        .map((list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<List<CategoryEntity>> getChildCategories(int parentId) async {
    final results = await _categoryDao.getChildCategories(parentId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<int> addCategory(CategoryEntity category) =>
      _categoryDao.insertCategory(CategoriesCompanion.insert(
        userId: category.userId,
        name: category.name,
        icon: Value(category.icon),
        color: Value(category.color),
        type: category.type,
        parentId: Value(category.parentId),
        sortOrder: Value(category.sortOrder),
        isDefault: Value(category.isDefault),
      ));

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    if (category.id == null) return;
    final existing = await _categoryDao.getCategoryById(category.id!);
    final updated = existing.copyWith(
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
      parentId: Value(category.parentId),
      sortOrder: category.sortOrder,
    );
    await _categoryDao.updateCategory(updated);
  }

  @override
  Future<void> deleteCategory(int id) => _categoryDao.deleteCategory(id);

  @override
  Future<CategoryEntity> getCategoryById(int id) async {
    final result = await _categoryDao.getCategoryById(id);
    return _mapToEntity(result);
  }

  @override
  Future<void> copyDefaultCategoriesToUser(int userId) =>
      _categoryDao.copyDefaultCategoriesToUser(userId);
}
