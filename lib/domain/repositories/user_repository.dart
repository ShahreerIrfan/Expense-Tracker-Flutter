import '../entities/user.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers();
  Stream<List<UserEntity>> watchAllUsers();
  Future<UserEntity> getUserById(int id);
  Future<UserEntity?> getActiveUser();
  Future<int> addUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(int id);
  Future<void> setActiveUser(int userId);
  Future<UserEntity?> validatePin(int userId, String pin);
}
