import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import '../database/app_database.dart';
import '../domain/entities/user.dart';
import '../providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;

/// Handles registration and login against the PostgreSQL cloud database.
/// On success, the user is also persisted locally in SQLite.
class CloudAuthService {
  final AppDatabase _db;

  CloudAuthService(this._db);

  static const _host = '187.127.141.36';
  static const _port = 5434;
  static const _database = 'ET_DB';
  static const _username = 'postgres';
  static const _password = 'etdb@123';

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Connection> _connect() async {
    return Connection.open(
      Endpoint(
        host: _host,
        port: _port,
        database: _database,
        username: _username,
        password: _password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  Future<void> _ensureUsersTable(Connection conn) async {
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        avatar_color TEXT DEFAULT '#4CAF50',
        pin TEXT,
        biometric_enabled BOOLEAN DEFAULT FALSE,
        currency TEXT DEFAULT 'BDT',
        language TEXT DEFAULT 'en',
        is_dark_mode BOOLEAN DEFAULT FALSE,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    ''');
  }

  /// Register a new user. Returns the created [UserEntity] or throws [AuthException].
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String avatarColor = '#4CAF50',
  }) async {
    final conn = await _connect();
    try {
      await _ensureUsersTable(conn);

      // Check if email already exists
      final existing = await conn.execute(
        Sql.named('SELECT id FROM users WHERE email = @email'),
        parameters: {'email': email.toLowerCase().trim()},
      );
      if (existing.isNotEmpty) {
        throw AuthException('An account with this email already exists.');
      }

      final hash = _hashPassword(password);
      final now = DateTime.now().toUtc();

      // Insert into cloud
      final result = await conn.execute(
        Sql.named('''
          INSERT INTO users (name, email, password_hash, avatar_color, created_at, updated_at)
          VALUES (@name, @email, @hash, @color, @ca, @ua)
          RETURNING id
        '''),
        parameters: {
          'name': name.trim(),
          'email': email.toLowerCase().trim(),
          'hash': hash,
          'color': avatarColor,
          'ca': now,
          'ua': now,
        },
      );

      final cloudId = result.first.toColumnMap()['id'] as int;

      // Save locally in SQLite
      final localId = await _db.into(_db.users).insert(
            UsersCompanion.insert(
              name: name.trim(),
              email: drift.Value(email.toLowerCase().trim()),
              passwordHash: drift.Value(hash),
              avatarColor: drift.Value(avatarColor),
            ),
          );

      // Copy default categories for new user
      await _db.categoryDao.copyDefaultCategoriesToUser(localId);
      await _db.accountDao.seedDefaultAccounts(localId);

      return UserEntity(
        id: localId,
        name: name.trim(),
        email: email.toLowerCase().trim(),
        passwordHash: hash,
        avatarColor: avatarColor,
        createdAt: now,
        updatedAt: now,
      );
    } finally {
      await conn.close();
    }
  }

  /// Login with email + password. Returns [UserEntity] or throws [AuthException].
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final conn = await _connect();
    try {
      await _ensureUsersTable(conn);

      final hash = _hashPassword(password);
      final rows = await conn.execute(
        Sql.named('''
          SELECT id, name, email, password_hash, avatar_color, pin,
                 biometric_enabled, currency, language, is_dark_mode,
                 is_active, created_at, updated_at
          FROM users
          WHERE email = @email AND password_hash = @hash AND is_active = TRUE
        '''),
        parameters: {
          'email': email.toLowerCase().trim(),
          'hash': hash,
        },
      );

      if (rows.isEmpty) {
        throw AuthException('Incorrect email or password.');
      }

      final m = rows.first.toColumnMap();
      final cloudId = m['id'] as int;
      final userName = m['name'] as String;
      final userEmail = m['email'] as String;
      final userColor = m['avatar_color'] as String? ?? '#4CAF50';
      final userPin = m['pin'] as String?;
      final userBiometric = m['biometric_enabled'] as bool? ?? false;
      final userCurrency = m['currency'] as String? ?? 'BDT';
      final userLanguage = m['language'] as String? ?? 'en';
      final userDarkMode = m['is_dark_mode'] as bool? ?? false;

      // Check if user exists locally by email
      final localUsers = await (_db.select(_db.users)
            ..where((u) => u.email.equals(userEmail)))
          .get();

      int localId;
      if (localUsers.isNotEmpty) {
        localId = localUsers.first.id;
        // Update local record to match cloud
        await (_db.update(_db.users)..where((u) => u.id.equals(localId)))
            .write(UsersCompanion(
          name: drift.Value(userName),
          passwordHash: drift.Value(hash),
          avatarColor: drift.Value(userColor),
          pin: drift.Value(userPin),
          biometricEnabled: drift.Value(userBiometric),
          currency: drift.Value(userCurrency),
          language: drift.Value(userLanguage),
          isDarkMode: drift.Value(userDarkMode),
          updatedAt: drift.Value(DateTime.now()),
        ));
      } else {
        // First login on this device — create local record
        localId = await _db.into(_db.users).insert(
              UsersCompanion.insert(
                name: userName,
                email: drift.Value(userEmail),
                passwordHash: drift.Value(hash),
                avatarColor: drift.Value(userColor),
                pin: drift.Value(userPin),
                biometricEnabled: drift.Value(userBiometric),
                currency: drift.Value(userCurrency),
                language: drift.Value(userLanguage),
                isDarkMode: drift.Value(userDarkMode),
              ),
            );
        await _db.categoryDao.copyDefaultCategoriesToUser(localId);
        await _db.accountDao.seedDefaultAccounts(localId);
      }

      return UserEntity(
        id: localId,
        name: userName,
        email: userEmail,
        passwordHash: hash,
        avatarColor: userColor,
        pin: userPin,
        biometricEnabled: userBiometric,
        currency: userCurrency,
        language: userLanguage,
        isDarkMode: userDarkMode,
      );
    } finally {
      await conn.close();
    }
  }

  /// Update PIN and biometric flag in cloud
  Future<void> syncSecuritySettings(UserEntity user) async {
    if (user.email == null) return;
    final conn = await _connect();
    try {
      await conn.execute(
        Sql.named('''
          UPDATE users SET pin = @pin, biometric_enabled = @be, updated_at = NOW()
          WHERE email = @email
        '''),
        parameters: {
          'pin': user.pin,
          'be': user.biometricEnabled,
          'email': user.email,
        },
      );
    } finally {
      await conn.close();
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
