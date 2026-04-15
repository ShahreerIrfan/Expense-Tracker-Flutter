import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/daos/user_dao.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _userDao;

  UserRepositoryImpl(this._userDao);

  UserEntity _mapToEntity(User u) => UserEntity(
        id: u.id,
        name: u.name,
        email: u.email,
        avatarColor: u.avatarColor,
        pin: u.pin,
        biometricEnabled: u.biometricEnabled,
        currency: u.currency,
        language: u.language,
        isDarkMode: u.isDarkMode,
        isActive: u.isActive,
        createdAt: u.createdAt,
        updatedAt: u.updatedAt,
      );

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final results = await _userDao.getAllUsers();
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<UserEntity>> watchAllUsers() {
    return _userDao
        .watchAllUsers()
        .map((list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<UserEntity> getUserById(int id) async {
    final result = await _userDao.getUserById(id);
    return _mapToEntity(result);
  }

  @override
  Future<UserEntity?> getActiveUser() async {
    final result = await _userDao.getActiveUser();
    return result != null ? _mapToEntity(result) : null;
  }

  @override
  Future<int> addUser(UserEntity user) =>
      _userDao.insertUser(UsersCompanion.insert(
        name: user.name,
        email: Value(user.email),
        avatarColor: Value(user.avatarColor),
        pin: Value(user.pin),
        biometricEnabled: Value(user.biometricEnabled),
        currency: Value(user.currency),
        language: Value(user.language),
        isDarkMode: Value(user.isDarkMode),
      ));

  @override
  Future<void> updateUser(UserEntity user) async {
    if (user.id == null) return;
    final existing = await _userDao.getUserById(user.id!);
    final updated = existing.copyWith(
      name: user.name,
      email: Value(user.email),
      avatarColor: user.avatarColor,
      pin: Value(user.pin),
      biometricEnabled: user.biometricEnabled,
      currency: user.currency,
      language: user.language,
      isDarkMode: user.isDarkMode,
      updatedAt: DateTime.now(),
    );
    await _userDao.updateUser(updated);
  }

  @override
  Future<void> deleteUser(int id) => _userDao.deleteUser(id);

  @override
  Future<void> setActiveUser(int userId) =>
      _userDao.setActiveUser(userId);

  @override
  Future<UserEntity?> validatePin(int userId, String pin) async {
    final result = await _userDao.validatePin(userId, pin);
    return result != null ? _mapToEntity(result) : null;
  }
}
