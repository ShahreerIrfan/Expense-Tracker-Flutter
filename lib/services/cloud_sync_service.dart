import 'package:postgres/postgres.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

/// Cloud sync service for PostgreSQL on Hostinger Dokploy.
///
/// ⚠️ SECURITY WARNING: Direct DB credentials embedded in a mobile app
/// can be extracted by anyone who decompiles the APK. For production,
/// use a backend API (Node.js / FastAPI) instead.
class CloudSyncService {
  static const String host = '187.127.141.36';
  static const int port = 5434;
  static const String database = 'ET_DB';
  static const String username = 'postgres';
  static const String password = 'etdb@123';

  final AppDatabase _db;
  Connection? _connection;

  CloudSyncService(this._db);

  Future<Connection> _connect() async {
    if (_connection != null && _connection!.isOpen) return _connection!;
    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  /// Test connection
  Future<bool> testConnection() async {
    try {
      final conn = await _connect();
      await conn.execute('SELECT 1');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Initialize remote schema if it doesn't exist
  Future<void> initSchema() async {
    final conn = await _connect();
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        avatar_color TEXT,
        biometric_enabled BOOLEAN DEFAULT FALSE,
        currency TEXT DEFAULT 'BDT',
        language TEXT DEFAULT 'en',
        is_dark_mode BOOLEAN DEFAULT FALSE,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMPTZ,
        updated_at TIMESTAMPTZ
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        type TEXT NOT NULL,
        parent_id INTEGER,
        sort_order INTEGER DEFAULT 0,
        is_default BOOLEAN DEFAULT FALSE,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMPTZ
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS accounts (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance DOUBLE PRECISION DEFAULT 0,
        initial_balance DOUBLE PRECISION DEFAULT 0,
        currency TEXT DEFAULT 'BDT',
        color TEXT,
        icon TEXT,
        bank_name TEXT,
        account_number TEXT,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMPTZ,
        updated_at TIMESTAMPTZ
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount DOUBLE PRECISION NOT NULL,
        date TIMESTAMPTZ NOT NULL,
        description TEXT,
        location TEXT,
        receipt_path TEXT,
        tags TEXT,
        is_recurring BOOLEAN DEFAULT FALSE,
        recurring_type TEXT,
        recurring_interval INTEGER,
        next_recurring_date TIMESTAMPTZ,
        latitude DOUBLE PRECISION,
        longitude DOUBLE PRECISION,
        created_at TIMESTAMPTZ,
        updated_at TIMESTAMPTZ
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS incomes (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount DOUBLE PRECISION NOT NULL,
        source TEXT,
        date TIMESTAMPTZ NOT NULL,
        description TEXT,
        is_recurring BOOLEAN DEFAULT FALSE,
        recurring_type TEXT,
        created_at TIMESTAMPTZ,
        updated_at TIMESTAMPTZ
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        category_id INTEGER,
        amount DOUBLE PRECISION NOT NULL,
        spent DOUBLE PRECISION DEFAULT 0,
        period TEXT NOT NULL,
        start_date TIMESTAMPTZ NOT NULL,
        end_date TIMESTAMPTZ NOT NULL,
        rollover BOOLEAN DEFAULT FALSE,
        rollover_amount DOUBLE PRECISION DEFAULT 0,
        alert_at_50 BOOLEAN DEFAULT TRUE,
        alert_at_80 BOOLEAN DEFAULT TRUE,
        alert_at_100 BOOLEAN DEFAULT TRUE,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMPTZ,
        updated_at TIMESTAMPTZ
      );
    ''');
  }

  /// Push all local data to cloud (overwrites remote)
  Future<SyncResult> pushAll(int userId) async {
    final result = SyncResult();
    try {
      final conn = await _connect();
      await initSchema();

      // Wipe remote data for this user
      await conn.execute(Sql.named('DELETE FROM expenses WHERE user_id = @uid'),
          parameters: {'uid': userId});
      await conn.execute(Sql.named('DELETE FROM incomes WHERE user_id = @uid'),
          parameters: {'uid': userId});
      await conn.execute(Sql.named('DELETE FROM budgets WHERE user_id = @uid'),
          parameters: {'uid': userId});
      await conn.execute(Sql.named('DELETE FROM accounts WHERE user_id = @uid'),
          parameters: {'uid': userId});
      await conn.execute(Sql.named('DELETE FROM categories WHERE user_id = @uid'),
          parameters: {'uid': userId});
      await conn.execute(Sql.named('DELETE FROM users WHERE id = @uid'),
          parameters: {'uid': userId});

      // Push user
      final user = await _db.userDao.getUserById(userId);
      if (user != null) {
        await conn.execute(
          Sql.named('''INSERT INTO users (id, name, email, avatar_color, biometric_enabled, currency, language, is_dark_mode, is_active, created_at, updated_at)
            VALUES (@id, @name, @email, @ac, @be, @cur, @lang, @dm, @ia, @ca, @ua)'''),
          parameters: {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'ac': user.avatarColor,
            'be': user.biometricEnabled,
            'cur': user.currency,
            'lang': user.language,
            'dm': user.isDarkMode,
            'ia': user.isActive,
            'ca': user.createdAt,
            'ua': user.updatedAt,
          },
        );
        result.users = 1;
      }

      // Push categories
      final categories = await _db.categoryDao.getAllCategories(userId);
      for (final c in categories) {
        await conn.execute(
          Sql.named('''INSERT INTO categories (id, user_id, name, icon, color, type, parent_id, sort_order, is_default, is_active, created_at)
            VALUES (@id, @uid, @name, @icon, @color, @type, @pid, @so, @def, @ia, @ca)'''),
          parameters: {
            'id': c.id,
            'uid': c.userId,
            'name': c.name,
            'icon': c.icon,
            'color': c.color,
            'type': c.type,
            'pid': c.parentId,
            'so': c.sortOrder,
            'def': c.isDefault,
            'ia': c.isActive,
            'ca': c.createdAt,
          },
        );
        result.categories++;
      }

      // Push accounts
      final accounts = await _db.accountDao.getAllAccounts(userId);
      for (final a in accounts) {
        await conn.execute(
          Sql.named('''INSERT INTO accounts (id, user_id, name, type, balance, initial_balance, currency, color, icon, bank_name, account_number, is_active, created_at, updated_at)
            VALUES (@id, @uid, @name, @type, @bal, @ib, @cur, @col, @icon, @bn, @an, @ia, @ca, @ua)'''),
          parameters: {
            'id': a.id,
            'uid': a.userId,
            'name': a.name,
            'type': a.type,
            'bal': a.balance,
            'ib': a.initialBalance,
            'cur': a.currency,
            'col': a.color,
            'icon': a.icon,
            'bn': a.bankName,
            'an': a.accountNumber,
            'ia': a.isActive,
            'ca': a.createdAt,
            'ua': a.updatedAt,
          },
        );
        result.accounts++;
      }

      // Push expenses
      final expenses = await _db.expenseDao.getAllExpenses(userId);
      for (final e in expenses) {
        await conn.execute(
          Sql.named('''INSERT INTO expenses (id, user_id, category_id, account_id, title, amount, date, description, location, receipt_path, tags, is_recurring, recurring_type, recurring_interval, next_recurring_date, latitude, longitude, created_at, updated_at)
            VALUES (@id, @uid, @cid, @aid, @t, @amt, @d, @desc, @loc, @rp, @tags, @ir, @rt, @ri, @nrd, @lat, @lng, @ca, @ua)'''),
          parameters: {
            'id': e.id,
            'uid': e.userId,
            'cid': e.categoryId,
            'aid': e.accountId,
            't': e.title,
            'amt': e.amount,
            'd': e.date,
            'desc': e.description,
            'loc': e.location,
            'rp': e.receiptPath,
            'tags': e.tags,
            'ir': e.isRecurring,
            'rt': e.recurringType,
            'ri': e.recurringInterval,
            'nrd': e.nextRecurringDate,
            'lat': e.latitude,
            'lng': e.longitude,
            'ca': e.createdAt,
            'ua': e.updatedAt,
          },
        );
        result.expenses++;
      }

      // Push incomes
      final incomes = await _db.incomeDao.getAllIncomes(userId);
      for (final i in incomes) {
        await conn.execute(
          Sql.named('''INSERT INTO incomes (id, user_id, category_id, account_id, title, amount, source, date, description, is_recurring, recurring_type, created_at, updated_at)
            VALUES (@id, @uid, @cid, @aid, @t, @amt, @src, @d, @desc, @ir, @rt, @ca, @ua)'''),
          parameters: {
            'id': i.id,
            'uid': i.userId,
            'cid': i.categoryId,
            'aid': i.accountId,
            't': i.title,
            'amt': i.amount,
            'src': i.source,
            'd': i.date,
            'desc': i.description,
            'ir': i.isRecurring,
            'rt': i.recurringType,
            'ca': i.createdAt,
            'ua': i.updatedAt,
          },
        );
        result.incomes++;
      }

      // Push budgets
      final budgets = await _db.budgetDao.getAllBudgets(userId);
      for (final b in budgets) {
        await conn.execute(
          Sql.named('''INSERT INTO budgets (id, user_id, category_id, amount, spent, period, start_date, end_date, rollover, rollover_amount, alert_at_50, alert_at_80, alert_at_100, is_active, created_at, updated_at)
            VALUES (@id, @uid, @cid, @amt, @sp, @p, @sd, @ed, @ro, @ra, @a50, @a80, @a100, @ia, @ca, @ua)'''),
          parameters: {
            'id': b.id,
            'uid': b.userId,
            'cid': b.categoryId,
            'amt': b.amount,
            'sp': b.spent,
            'p': b.period,
            'sd': b.startDate,
            'ed': b.endDate,
            'ro': b.rollover,
            'ra': b.rolloverAmount,
            'a50': b.alertAt50,
            'a80': b.alertAt80,
            'a100': b.alertAt100,
            'ia': b.isActive,
            'ca': b.createdAt,
            'ua': b.updatedAt,
          },
        );
        result.budgets++;
      }

      result.success = true;
      return result;
    } catch (e) {
      result.success = false;
      result.error = e.toString();
      return result;
    }
  }

  /// Pull all remote data to local (overwrites local for that user)
  Future<SyncResult> pullAll(int userId) async {
    final result = SyncResult();
    try {
      final conn = await _connect();
      await initSchema();

      // Clear local data for this user (keep user record)
      await (_db.delete(_db.expenses)..where((t) => t.userId.equals(userId))).go();
      await (_db.delete(_db.incomes)..where((t) => t.userId.equals(userId))).go();
      await (_db.delete(_db.budgets)..where((t) => t.userId.equals(userId))).go();
      await (_db.delete(_db.accounts)..where((t) => t.userId.equals(userId))).go();
      await (_db.delete(_db.categories)..where((t) => t.userId.equals(userId))).go();

      // Pull categories
      final catRows = await conn.execute(
        Sql.named('SELECT * FROM categories WHERE user_id = @uid'),
        parameters: {'uid': userId},
      );
      for (final r in catRows) {
        final m = r.toColumnMap();
        await _db.into(_db.categories).insert(CategoriesCompanion.insert(
              userId: m['user_id'] as int,
              name: m['name'] as String,
              type: m['type'] as String,
              icon: drift.Value(m['icon'] as String? ?? 'category'),
              color: drift.Value(m['color'] as String? ?? '#4CAF50'),
              parentId: drift.Value(m['parent_id'] as int?),
              sortOrder: drift.Value(m['sort_order'] as int? ?? 0),
              isDefault: drift.Value(m['is_default'] as bool? ?? false),
              isActive: drift.Value(m['is_active'] as bool? ?? true),
            ));
        result.categories++;
      }

      // Pull accounts
      final accRows = await conn.execute(
        Sql.named('SELECT * FROM accounts WHERE user_id = @uid'),
        parameters: {'uid': userId},
      );
      for (final r in accRows) {
        final m = r.toColumnMap();
        await _db.into(_db.accounts).insert(AccountsCompanion.insert(
              userId: m['user_id'] as int,
              name: (m['name'] as String?) ?? '',
              type: (m['type'] as String?) ?? 'cash',
              balance: drift.Value(m['balance'] as double? ?? 0),
              initialBalance: drift.Value(m['initial_balance'] as double? ?? 0),
              currency: drift.Value(m['currency'] as String? ?? 'BDT'),
              color: drift.Value((m['color'] as String?) ?? '#2196F3'),
              icon: drift.Value((m['icon'] as String?) ?? 'account_balance_wallet'),
              bankName: drift.Value<String?>(m['bank_name'] as String?),
              accountNumber: drift.Value<String?>(m['account_number'] as String?),
              isActive: drift.Value(m['is_active'] as bool? ?? true),
            ));
        result.accounts++;
      }

      // Pull expenses
      final expRows = await conn.execute(
        Sql.named('SELECT * FROM expenses WHERE user_id = @uid'),
        parameters: {'uid': userId},
      );
      for (final r in expRows) {
        final m = r.toColumnMap();
        await _db.into(_db.expenses).insert(ExpensesCompanion.insert(
              userId: m['user_id'] as int,
              categoryId: m['category_id'] as int,
              accountId: m['account_id'] as int,
              title: m['title'] as String,
              amount: m['amount'] as double,
              date: (m['date'] as DateTime),
              description: drift.Value(m['description'] as String?),
              location: drift.Value(m['location'] as String?),
              receiptPath: drift.Value(m['receipt_path'] as String?),
              tags: drift.Value(m['tags'] as String?),
              isRecurring: drift.Value(m['is_recurring'] as bool? ?? false),
              recurringType: drift.Value(m['recurring_type'] as String?),
              latitude: drift.Value(m['latitude'] as double?),
              longitude: drift.Value(m['longitude'] as double?),
            ));
        result.expenses++;
      }

      // Pull incomes
      final incRows = await conn.execute(
        Sql.named('SELECT * FROM incomes WHERE user_id = @uid'),
        parameters: {'uid': userId},
      );
      for (final r in incRows) {
        final m = r.toColumnMap();
        await _db.into(_db.incomes).insert(IncomesCompanion.insert(
              userId: m['user_id'] as int,
              categoryId: m['category_id'] as int,
              accountId: m['account_id'] as int,
              title: m['title'] as String,
              amount: m['amount'] as double,
              date: (m['date'] as DateTime),
              source: drift.Value(m['source'] as String?),
              description: drift.Value(m['description'] as String?),
              isRecurring: drift.Value(m['is_recurring'] as bool? ?? false),
              recurringType: drift.Value(m['recurring_type'] as String?),
            ));
        result.incomes++;
      }

      // Pull budgets
      final budRows = await conn.execute(
        Sql.named('SELECT * FROM budgets WHERE user_id = @uid'),
        parameters: {'uid': userId},
      );
      for (final r in budRows) {
        final m = r.toColumnMap();
        await _db.into(_db.budgets).insert(BudgetsCompanion.insert(
              userId: m['user_id'] as int,
              categoryId: drift.Value(m['category_id'] as int?),
              amount: m['amount'] as double,
              spent: drift.Value(m['spent'] as double? ?? 0),
              period: m['period'] as String,
              startDate: (m['start_date'] as DateTime),
              endDate: (m['end_date'] as DateTime),
              rollover: drift.Value(m['rollover'] as bool? ?? false),
              rolloverAmount:
                  drift.Value(m['rollover_amount'] as double? ?? 0),
              alertAt50: drift.Value(m['alert_at_50'] as bool? ?? true),
              alertAt80: drift.Value(m['alert_at_80'] as bool? ?? true),
              alertAt100: drift.Value(m['alert_at_100'] as bool? ?? true),
              isActive: drift.Value(m['is_active'] as bool? ?? true),
            ));
        result.budgets++;
      }

      result.success = true;
      return result;
    } catch (e) {
      result.success = false;
      result.error = e.toString();
      return result;
    }
  }
}

class SyncResult {
  bool success = false;
  String? error;
  int users = 0;
  int categories = 0;
  int accounts = 0;
  int expenses = 0;
  int incomes = 0;
  int budgets = 0;

  String summary() {
    final total = users + categories + accounts + expenses + incomes + budgets;
    return '$total records (Cat: $categories, Acc: $accounts, Exp: $expenses, Inc: $incomes, Bud: $budgets)';
  }
}
