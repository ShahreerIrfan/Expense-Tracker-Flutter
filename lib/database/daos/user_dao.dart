import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<List<User>> getAllUsers() => select(users).get();

  Stream<List<User>> watchAllUsers() => select(users).watch();

  Future<User> getUserById(int id) =>
      (select(users)..where((t) => t.id.equals(id))).getSingle();

  Future<User?> getActiveUser() =>
      (select(users)..where((t) => t.isActive.equals(true))).getSingleOrNull();

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<bool> updateUser(User user) => update(users).replace(user);

  Future<int> deleteUser(int id) =>
      (delete(users)..where((t) => t.id.equals(id))).go();

  Future<void> setActiveUser(int userId) async {
    await (update(users)..where((t) => t.isActive.equals(true)))
        .write(const UsersCompanion(isActive: Value(false)));
    await (update(users)..where((t) => t.id.equals(userId)))
        .write(const UsersCompanion(isActive: Value(true)));
  }

  Future<User?> validatePin(int userId, String pin) =>
      (select(users)
            ..where(
                (t) => t.id.equals(userId) & t.pin.equals(pin)))
          .getSingleOrNull();
}
