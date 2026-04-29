import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().nullable()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get avatarColor => text().withDefault(const Constant('#4CAF50'))();
  TextColumn get pin => text().nullable()();
  BoolColumn get biometricEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get currency => text().withDefault(const Constant('BDT'))();
  TextColumn get language => text().withDefault(const Constant('en'))();
  BoolColumn get isDarkMode =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
