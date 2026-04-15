import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/security/secure_storage.dart';
import '../domain/entities/user.dart';
import 'database_provider.dart';

// Current user provider
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserEntity?>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<UserEntity?> {
  final Ref _ref;

  CurrentUserNotifier(this._ref) : super(null);

  Future<void> loadCurrentUser() async {
    final userId = await SecureStorageService.getCurrentUserId();
    if (userId != null) {
      try {
        final user = await _ref.read(userRepositoryProvider).getUserById(userId);
        state = user;
      } catch (_) {
        state = null;
      }
    }
  }

  Future<void> setCurrentUser(UserEntity user) async {
    state = user;
    if (user.id != null) {
      await SecureStorageService.saveCurrentUserId(user.id!);
      await _ref.read(userRepositoryProvider).setActiveUser(user.id!);
    }
  }

  Future<int> createUser(UserEntity user) async {
    final id = await _ref.read(userRepositoryProvider).addUser(user);
    final createdUser = await _ref.read(userRepositoryProvider).getUserById(id);
    state = createdUser;
    await SecureStorageService.saveCurrentUserId(id);

    // Copy default categories and create default accounts
    await _ref.read(categoryRepositoryProvider).copyDefaultCategoriesToUser(id);
    await _ref.read(accountRepositoryProvider).seedDefaultAccounts(id);

    return id;
  }

  Future<void> updateUser(UserEntity user) async {
    await _ref.read(userRepositoryProvider).updateUser(user);
    state = user;
  }

  void logout() {
    state = null;
  }
}

// All users provider
final allUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  return ref.watch(userRepositoryProvider).getAllUsers();
});

// Auth state
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
final isLockedProvider = StateProvider<bool>((ref) => true);

// Theme mode
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleDarkMode() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

// Locale
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    state = locale;
  }
}
