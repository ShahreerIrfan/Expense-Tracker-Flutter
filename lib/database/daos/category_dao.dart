import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<Category>> getAllCategories(int userId) =>
      (select(categories)
            ..where((t) =>
                t.userId.equals(userId) | t.userId.equals(0))
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<List<Category>> getExpenseCategories(int userId) =>
      (select(categories)
            ..where((t) =>
                (t.userId.equals(userId) | t.userId.equals(0)) &
                (t.type.equals('expense') | t.type.equals('both')))
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<List<Category>> getIncomeCategories(int userId) =>
      (select(categories)
            ..where((t) =>
                (t.userId.equals(userId) | t.userId.equals(0)) &
                (t.type.equals('income') | t.type.equals('both')))
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Stream<List<Category>> watchAllCategories(int userId) =>
      (select(categories)
            ..where((t) =>
                t.userId.equals(userId) | t.userId.equals(0))
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<List<Category>> getChildCategories(int parentId) =>
      (select(categories)
            ..where((t) => t.parentId.equals(parentId))
            ..where((t) => t.isActive.equals(true)))
          .get();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(int id) =>
      (update(categories)..where((t) => t.id.equals(id)))
          .write(const CategoriesCompanion(isActive: Value(false)));

  Future<Category> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingle();

  Future<void> copyDefaultCategoriesToUser(int userId) async {
    final defaults = await (select(categories)
          ..where((t) => t.userId.equals(0) & t.isDefault.equals(true)))
        .get();

    for (final cat in defaults) {
      await into(categories).insert(CategoriesCompanion.insert(
        userId: userId,
        name: cat.name,
        icon: Value(cat.icon),
        color: Value(cat.color),
        type: cat.type,
        isDefault: const Value(true),
      ));
    }
  }
}
