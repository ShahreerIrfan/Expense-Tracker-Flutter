import 'package:drift/drift.dart';
import 'users_table.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // cash, bank, mobile_wallet, credit_card
  TextColumn get icon => text().withDefault(const Constant('account_balance_wallet'))();
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('BDT'))();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get bankName => text().nullable()();
  BoolColumn get includeInTotal =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
