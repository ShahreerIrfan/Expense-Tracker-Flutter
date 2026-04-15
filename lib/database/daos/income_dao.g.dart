// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_dao.dart';

// ignore_for_file: type=lint
mixin _$IncomeDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $IncomesTable get incomes => attachedDatabase.incomes;
  IncomeDaoManager get managers => IncomeDaoManager(this);
}

class IncomeDaoManager {
  final _$IncomeDaoMixin _db;
  IncomeDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db.attachedDatabase, _db.incomes);
}
