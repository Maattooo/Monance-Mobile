import 'package:drift/drift.dart';

class SettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get defaultAllowance => integer().withDefault(const Constant(0))(); // cents (0..99999900)
  IntColumn get goalAmount => integer().withDefault(const Constant(0))();       // cents (0..9999999900)
  IntColumn get currentBalance => integer().withDefault(const Constant(0))();   // cents (0..9999999900)
  TextColumn get goalStartDate => text().nullable()();                          // YYYY-MM-DD or null
  TextColumn get currencyCode => text().withDefault(const Constant('PHP'))();
  TextColumn get currencySymbol => text().withDefault(const Constant('₱'))();
  TextColumn get lastBillsMonth => text().nullable()();                         // YYYY-MM
  BoolColumn get themeIsDark => boolean().withDefault(const Constant(true))();
  BoolColumn get privacyMode => boolean().withDefault(const Constant(false))();
  BoolColumn get billNotificationsEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class DailyRecordsTable extends Table {
  TextColumn get date => text()(); // PK: YYYY-MM-DD
  TextColumn get title => text().withDefault(const Constant('school'))();
  IntColumn get startingMoney => integer().withDefault(const Constant(0))(); // cents
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {date};
}

class ExpensesTable extends Table {
  TextColumn get id => text()(); // UUID or 'hangout-<sessionId>-<expId>'
  TextColumn get date => text().references(DailyRecordsTable, #date, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get amount => integer()(); // cents (> 0)
  TextColumn get category => text().withDefault(const Constant('Other'))();
  TextColumn get deductFrom => text().withDefault(const Constant('allowance'))(); // 'allowance' | 'balance'
  IntColumn get timestamp => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class MonthlyBillsTable extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text().withLength(min: 1, max: 40)();
  IntColumn get amount => integer()(); // cents (> 0)
  IntColumn get dueDay => integer()(); // 1..31
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoriesTable extends Table {
  TextColumn get name => text().withLength(min: 1, max: 30)();
  TextColumn get colorHex => text()(); // '#RRGGBB'
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {name};
}

class GoalHistoryTable extends Table {
  TextColumn get id => text()(); // UUID
  IntColumn get amount => integer()(); // Target goal amount in cents
  IntColumn get saved => integer()();  // Total saved in cents at archive time
  TextColumn get startDate => text().nullable()(); // YYYY-MM-DD
  TextColumn get endDate => text()();              // ISO-8601 or YYYY-MM-DD
  IntColumn get archivedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class HangoutSessionsTable extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get peopleJson => text()(); // JSON array of strings, always includes "You"
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();
  IntColumn get updatedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class HangoutExpensesTable extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get sessionId => text().references(HangoutSessionsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get totalAmount => integer()();     // cents (> 0)
  IntColumn get perPersonAmount => integer()(); // base share in cents (totalAmount ~/ participants.length)
  TextColumn get paidBy => text().withDefault(const Constant('You'))(); // Person who paid upfront
  TextColumn get splitType => text().withDefault(const Constant('equal'))(); // 'equal' | 'custom'
  TextColumn get participantsJson => text()(); // JSON array of participant names
  IntColumn get timestamp => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

