// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _defaultAllowanceMeta =
      const VerificationMeta('defaultAllowance');
  @override
  late final GeneratedColumn<int> defaultAllowance = GeneratedColumn<int>(
      'default_allowance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _goalAmountMeta =
      const VerificationMeta('goalAmount');
  @override
  late final GeneratedColumn<int> goalAmount = GeneratedColumn<int>(
      'goal_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currentBalanceMeta =
      const VerificationMeta('currentBalance');
  @override
  late final GeneratedColumn<int> currentBalance = GeneratedColumn<int>(
      'current_balance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _goalStartDateMeta =
      const VerificationMeta('goalStartDate');
  @override
  late final GeneratedColumn<String> goalStartDate = GeneratedColumn<String>(
      'goal_start_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PHP'));
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('₱'));
  static const VerificationMeta _lastBillsMonthMeta =
      const VerificationMeta('lastBillsMonth');
  @override
  late final GeneratedColumn<String> lastBillsMonth = GeneratedColumn<String>(
      'last_bills_month', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _themeIsDarkMeta =
      const VerificationMeta('themeIsDark');
  @override
  late final GeneratedColumn<bool> themeIsDark = GeneratedColumn<bool>(
      'theme_is_dark', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("theme_is_dark" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _privacyModeMeta =
      const VerificationMeta('privacyMode');
  @override
  late final GeneratedColumn<bool> privacyMode = GeneratedColumn<bool>(
      'privacy_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("privacy_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _billNotificationsEnabledMeta =
      const VerificationMeta('billNotificationsEnabled');
  @override
  late final GeneratedColumn<bool> billNotificationsEnabled =
      GeneratedColumn<bool>(
          'bill_notifications_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("bill_notifications_enabled" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        defaultAllowance,
        goalAmount,
        currentBalance,
        goalStartDate,
        currencyCode,
        currencySymbol,
        lastBillsMonth,
        themeIsDark,
        privacyMode,
        billNotificationsEnabled,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_allowance')) {
      context.handle(
          _defaultAllowanceMeta,
          defaultAllowance.isAcceptableOrUnknown(
              data['default_allowance']!, _defaultAllowanceMeta));
    }
    if (data.containsKey('goal_amount')) {
      context.handle(
          _goalAmountMeta,
          goalAmount.isAcceptableOrUnknown(
              data['goal_amount']!, _goalAmountMeta));
    }
    if (data.containsKey('current_balance')) {
      context.handle(
          _currentBalanceMeta,
          currentBalance.isAcceptableOrUnknown(
              data['current_balance']!, _currentBalanceMeta));
    }
    if (data.containsKey('goal_start_date')) {
      context.handle(
          _goalStartDateMeta,
          goalStartDate.isAcceptableOrUnknown(
              data['goal_start_date']!, _goalStartDateMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    }
    if (data.containsKey('last_bills_month')) {
      context.handle(
          _lastBillsMonthMeta,
          lastBillsMonth.isAcceptableOrUnknown(
              data['last_bills_month']!, _lastBillsMonthMeta));
    }
    if (data.containsKey('theme_is_dark')) {
      context.handle(
          _themeIsDarkMeta,
          themeIsDark.isAcceptableOrUnknown(
              data['theme_is_dark']!, _themeIsDarkMeta));
    }
    if (data.containsKey('privacy_mode')) {
      context.handle(
          _privacyModeMeta,
          privacyMode.isAcceptableOrUnknown(
              data['privacy_mode']!, _privacyModeMeta));
    }
    if (data.containsKey('bill_notifications_enabled')) {
      context.handle(
          _billNotificationsEnabledMeta,
          billNotificationsEnabled.isAcceptableOrUnknown(
              data['bill_notifications_enabled']!,
              _billNotificationsEnabledMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      defaultAllowance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}default_allowance'])!,
      goalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_amount'])!,
      currentBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_balance'])!,
      goalStartDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_start_date']),
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      currencySymbol: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}currency_symbol'])!,
      lastBillsMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_bills_month']),
      themeIsDark: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}theme_is_dark'])!,
      privacyMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}privacy_mode'])!,
      billNotificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}bill_notifications_enabled'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final int id;
  final int defaultAllowance;
  final int goalAmount;
  final int currentBalance;
  final String? goalStartDate;
  final String currencyCode;
  final String currencySymbol;
  final String? lastBillsMonth;
  final bool themeIsDark;
  final bool privacyMode;
  final bool billNotificationsEnabled;
  final int updatedAt;
  const SettingsTableData(
      {required this.id,
      required this.defaultAllowance,
      required this.goalAmount,
      required this.currentBalance,
      this.goalStartDate,
      required this.currencyCode,
      required this.currencySymbol,
      this.lastBillsMonth,
      required this.themeIsDark,
      required this.privacyMode,
      required this.billNotificationsEnabled,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['default_allowance'] = Variable<int>(defaultAllowance);
    map['goal_amount'] = Variable<int>(goalAmount);
    map['current_balance'] = Variable<int>(currentBalance);
    if (!nullToAbsent || goalStartDate != null) {
      map['goal_start_date'] = Variable<String>(goalStartDate);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    if (!nullToAbsent || lastBillsMonth != null) {
      map['last_bills_month'] = Variable<String>(lastBillsMonth);
    }
    map['theme_is_dark'] = Variable<bool>(themeIsDark);
    map['privacy_mode'] = Variable<bool>(privacyMode);
    map['bill_notifications_enabled'] =
        Variable<bool>(billNotificationsEnabled);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      defaultAllowance: Value(defaultAllowance),
      goalAmount: Value(goalAmount),
      currentBalance: Value(currentBalance),
      goalStartDate: goalStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(goalStartDate),
      currencyCode: Value(currencyCode),
      currencySymbol: Value(currencySymbol),
      lastBillsMonth: lastBillsMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBillsMonth),
      themeIsDark: Value(themeIsDark),
      privacyMode: Value(privacyMode),
      billNotificationsEnabled: Value(billNotificationsEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      defaultAllowance: serializer.fromJson<int>(json['defaultAllowance']),
      goalAmount: serializer.fromJson<int>(json['goalAmount']),
      currentBalance: serializer.fromJson<int>(json['currentBalance']),
      goalStartDate: serializer.fromJson<String?>(json['goalStartDate']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      lastBillsMonth: serializer.fromJson<String?>(json['lastBillsMonth']),
      themeIsDark: serializer.fromJson<bool>(json['themeIsDark']),
      privacyMode: serializer.fromJson<bool>(json['privacyMode']),
      billNotificationsEnabled:
          serializer.fromJson<bool>(json['billNotificationsEnabled']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultAllowance': serializer.toJson<int>(defaultAllowance),
      'goalAmount': serializer.toJson<int>(goalAmount),
      'currentBalance': serializer.toJson<int>(currentBalance),
      'goalStartDate': serializer.toJson<String?>(goalStartDate),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'lastBillsMonth': serializer.toJson<String?>(lastBillsMonth),
      'themeIsDark': serializer.toJson<bool>(themeIsDark),
      'privacyMode': serializer.toJson<bool>(privacyMode),
      'billNotificationsEnabled':
          serializer.toJson<bool>(billNotificationsEnabled),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SettingsTableData copyWith(
          {int? id,
          int? defaultAllowance,
          int? goalAmount,
          int? currentBalance,
          Value<String?> goalStartDate = const Value.absent(),
          String? currencyCode,
          String? currencySymbol,
          Value<String?> lastBillsMonth = const Value.absent(),
          bool? themeIsDark,
          bool? privacyMode,
          bool? billNotificationsEnabled,
          int? updatedAt}) =>
      SettingsTableData(
        id: id ?? this.id,
        defaultAllowance: defaultAllowance ?? this.defaultAllowance,
        goalAmount: goalAmount ?? this.goalAmount,
        currentBalance: currentBalance ?? this.currentBalance,
        goalStartDate:
            goalStartDate.present ? goalStartDate.value : this.goalStartDate,
        currencyCode: currencyCode ?? this.currencyCode,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        lastBillsMonth:
            lastBillsMonth.present ? lastBillsMonth.value : this.lastBillsMonth,
        themeIsDark: themeIsDark ?? this.themeIsDark,
        privacyMode: privacyMode ?? this.privacyMode,
        billNotificationsEnabled:
            billNotificationsEnabled ?? this.billNotificationsEnabled,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      defaultAllowance: data.defaultAllowance.present
          ? data.defaultAllowance.value
          : this.defaultAllowance,
      goalAmount:
          data.goalAmount.present ? data.goalAmount.value : this.goalAmount,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      goalStartDate: data.goalStartDate.present
          ? data.goalStartDate.value
          : this.goalStartDate,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      lastBillsMonth: data.lastBillsMonth.present
          ? data.lastBillsMonth.value
          : this.lastBillsMonth,
      themeIsDark:
          data.themeIsDark.present ? data.themeIsDark.value : this.themeIsDark,
      privacyMode:
          data.privacyMode.present ? data.privacyMode.value : this.privacyMode,
      billNotificationsEnabled: data.billNotificationsEnabled.present
          ? data.billNotificationsEnabled.value
          : this.billNotificationsEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('id: $id, ')
          ..write('defaultAllowance: $defaultAllowance, ')
          ..write('goalAmount: $goalAmount, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('goalStartDate: $goalStartDate, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('lastBillsMonth: $lastBillsMonth, ')
          ..write('themeIsDark: $themeIsDark, ')
          ..write('privacyMode: $privacyMode, ')
          ..write('billNotificationsEnabled: $billNotificationsEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      defaultAllowance,
      goalAmount,
      currentBalance,
      goalStartDate,
      currencyCode,
      currencySymbol,
      lastBillsMonth,
      themeIsDark,
      privacyMode,
      billNotificationsEnabled,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.defaultAllowance == this.defaultAllowance &&
          other.goalAmount == this.goalAmount &&
          other.currentBalance == this.currentBalance &&
          other.goalStartDate == this.goalStartDate &&
          other.currencyCode == this.currencyCode &&
          other.currencySymbol == this.currencySymbol &&
          other.lastBillsMonth == this.lastBillsMonth &&
          other.themeIsDark == this.themeIsDark &&
          other.privacyMode == this.privacyMode &&
          other.billNotificationsEnabled == this.billNotificationsEnabled &&
          other.updatedAt == this.updatedAt);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<int> id;
  final Value<int> defaultAllowance;
  final Value<int> goalAmount;
  final Value<int> currentBalance;
  final Value<String?> goalStartDate;
  final Value<String> currencyCode;
  final Value<String> currencySymbol;
  final Value<String?> lastBillsMonth;
  final Value<bool> themeIsDark;
  final Value<bool> privacyMode;
  final Value<bool> billNotificationsEnabled;
  final Value<int> updatedAt;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.defaultAllowance = const Value.absent(),
    this.goalAmount = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.goalStartDate = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.lastBillsMonth = const Value.absent(),
    this.themeIsDark = const Value.absent(),
    this.privacyMode = const Value.absent(),
    this.billNotificationsEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.defaultAllowance = const Value.absent(),
    this.goalAmount = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.goalStartDate = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.lastBillsMonth = const Value.absent(),
    this.themeIsDark = const Value.absent(),
    this.privacyMode = const Value.absent(),
    this.billNotificationsEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<SettingsTableData> custom({
    Expression<int>? id,
    Expression<int>? defaultAllowance,
    Expression<int>? goalAmount,
    Expression<int>? currentBalance,
    Expression<String>? goalStartDate,
    Expression<String>? currencyCode,
    Expression<String>? currencySymbol,
    Expression<String>? lastBillsMonth,
    Expression<bool>? themeIsDark,
    Expression<bool>? privacyMode,
    Expression<bool>? billNotificationsEnabled,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultAllowance != null) 'default_allowance': defaultAllowance,
      if (goalAmount != null) 'goal_amount': goalAmount,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (goalStartDate != null) 'goal_start_date': goalStartDate,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (lastBillsMonth != null) 'last_bills_month': lastBillsMonth,
      if (themeIsDark != null) 'theme_is_dark': themeIsDark,
      if (privacyMode != null) 'privacy_mode': privacyMode,
      if (billNotificationsEnabled != null)
        'bill_notifications_enabled': billNotificationsEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? defaultAllowance,
      Value<int>? goalAmount,
      Value<int>? currentBalance,
      Value<String?>? goalStartDate,
      Value<String>? currencyCode,
      Value<String>? currencySymbol,
      Value<String?>? lastBillsMonth,
      Value<bool>? themeIsDark,
      Value<bool>? privacyMode,
      Value<bool>? billNotificationsEnabled,
      Value<int>? updatedAt}) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      defaultAllowance: defaultAllowance ?? this.defaultAllowance,
      goalAmount: goalAmount ?? this.goalAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      goalStartDate: goalStartDate ?? this.goalStartDate,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      lastBillsMonth: lastBillsMonth ?? this.lastBillsMonth,
      themeIsDark: themeIsDark ?? this.themeIsDark,
      privacyMode: privacyMode ?? this.privacyMode,
      billNotificationsEnabled:
          billNotificationsEnabled ?? this.billNotificationsEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultAllowance.present) {
      map['default_allowance'] = Variable<int>(defaultAllowance.value);
    }
    if (goalAmount.present) {
      map['goal_amount'] = Variable<int>(goalAmount.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<int>(currentBalance.value);
    }
    if (goalStartDate.present) {
      map['goal_start_date'] = Variable<String>(goalStartDate.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (lastBillsMonth.present) {
      map['last_bills_month'] = Variable<String>(lastBillsMonth.value);
    }
    if (themeIsDark.present) {
      map['theme_is_dark'] = Variable<bool>(themeIsDark.value);
    }
    if (privacyMode.present) {
      map['privacy_mode'] = Variable<bool>(privacyMode.value);
    }
    if (billNotificationsEnabled.present) {
      map['bill_notifications_enabled'] =
          Variable<bool>(billNotificationsEnabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('defaultAllowance: $defaultAllowance, ')
          ..write('goalAmount: $goalAmount, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('goalStartDate: $goalStartDate, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('lastBillsMonth: $lastBillsMonth, ')
          ..write('themeIsDark: $themeIsDark, ')
          ..write('privacyMode: $privacyMode, ')
          ..write('billNotificationsEnabled: $billNotificationsEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyRecordsTableTable extends DailyRecordsTable
    with TableInfo<$DailyRecordsTableTable, DailyRecordsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyRecordsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('school'));
  static const VerificationMeta _startingMoneyMeta =
      const VerificationMeta('startingMoney');
  @override
  late final GeneratedColumn<int> startingMoney = GeneratedColumn<int>(
      'starting_money', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  @override
  List<GeneratedColumn> get $columns =>
      [date, title, startingMoney, isDeleted, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_records_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DailyRecordsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('starting_money')) {
      context.handle(
          _startingMoneyMeta,
          startingMoney.isAcceptableOrUnknown(
              data['starting_money']!, _startingMoneyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyRecordsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyRecordsTableData(
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      startingMoney: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}starting_money'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DailyRecordsTableTable createAlias(String alias) {
    return $DailyRecordsTableTable(attachedDatabase, alias);
  }
}

class DailyRecordsTableData extends DataClass
    implements Insertable<DailyRecordsTableData> {
  final String date;
  final String title;
  final int startingMoney;
  final bool isDeleted;
  final int updatedAt;
  const DailyRecordsTableData(
      {required this.date,
      required this.title,
      required this.startingMoney,
      required this.isDeleted,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['title'] = Variable<String>(title);
    map['starting_money'] = Variable<int>(startingMoney);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DailyRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return DailyRecordsTableCompanion(
      date: Value(date),
      title: Value(title),
      startingMoney: Value(startingMoney),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyRecordsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyRecordsTableData(
      date: serializer.fromJson<String>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      startingMoney: serializer.fromJson<int>(json['startingMoney']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'title': serializer.toJson<String>(title),
      'startingMoney': serializer.toJson<int>(startingMoney),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DailyRecordsTableData copyWith(
          {String? date,
          String? title,
          int? startingMoney,
          bool? isDeleted,
          int? updatedAt}) =>
      DailyRecordsTableData(
        date: date ?? this.date,
        title: title ?? this.title,
        startingMoney: startingMoney ?? this.startingMoney,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DailyRecordsTableData copyWithCompanion(DailyRecordsTableCompanion data) {
    return DailyRecordsTableData(
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      startingMoney: data.startingMoney.present
          ? data.startingMoney.value
          : this.startingMoney,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyRecordsTableData(')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('startingMoney: $startingMoney, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, title, startingMoney, isDeleted, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyRecordsTableData &&
          other.date == this.date &&
          other.title == this.title &&
          other.startingMoney == this.startingMoney &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt);
}

class DailyRecordsTableCompanion
    extends UpdateCompanion<DailyRecordsTableData> {
  final Value<String> date;
  final Value<String> title;
  final Value<int> startingMoney;
  final Value<bool> isDeleted;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DailyRecordsTableCompanion({
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.startingMoney = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyRecordsTableCompanion.insert({
    required String date,
    this.title = const Value.absent(),
    this.startingMoney = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyRecordsTableData> custom({
    Expression<String>? date,
    Expression<String>? title,
    Expression<int>? startingMoney,
    Expression<bool>? isDeleted,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (startingMoney != null) 'starting_money': startingMoney,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyRecordsTableCompanion copyWith(
      {Value<String>? date,
      Value<String>? title,
      Value<int>? startingMoney,
      Value<bool>? isDeleted,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return DailyRecordsTableCompanion(
      date: date ?? this.date,
      title: title ?? this.title,
      startingMoney: startingMoney ?? this.startingMoney,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startingMoney.present) {
      map['starting_money'] = Variable<int>(startingMoney.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyRecordsTableCompanion(')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('startingMoney: $startingMoney, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTableTable extends ExpensesTable
    with TableInfo<$ExpensesTableTable, ExpensesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES daily_records_table (date) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Other'));
  static const VerificationMeta _deductFromMeta =
      const VerificationMeta('deductFrom');
  @override
  late final GeneratedColumn<String> deductFrom = GeneratedColumn<String>(
      'deduct_from', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('allowance'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, title, amount, category, deductFrom, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses_table';
  @override
  VerificationContext validateIntegrity(Insertable<ExpensesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('deduct_from')) {
      context.handle(
          _deductFromMeta,
          deductFrom.isAcceptableOrUnknown(
              data['deduct_from']!, _deductFromMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpensesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpensesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      deductFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deduct_from'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $ExpensesTableTable createAlias(String alias) {
    return $ExpensesTableTable(attachedDatabase, alias);
  }
}

class ExpensesTableData extends DataClass
    implements Insertable<ExpensesTableData> {
  final String id;
  final String date;
  final String title;
  final int amount;
  final String category;
  final String deductFrom;
  final int timestamp;
  const ExpensesTableData(
      {required this.id,
      required this.date,
      required this.title,
      required this.amount,
      required this.category,
      required this.deductFrom,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<int>(amount);
    map['category'] = Variable<String>(category);
    map['deduct_from'] = Variable<String>(deductFrom);
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  ExpensesTableCompanion toCompanion(bool nullToAbsent) {
    return ExpensesTableCompanion(
      id: Value(id),
      date: Value(date),
      title: Value(title),
      amount: Value(amount),
      category: Value(category),
      deductFrom: Value(deductFrom),
      timestamp: Value(timestamp),
    );
  }

  factory ExpensesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpensesTableData(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<int>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      deductFrom: serializer.fromJson<String>(json['deductFrom']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<int>(amount),
      'category': serializer.toJson<String>(category),
      'deductFrom': serializer.toJson<String>(deductFrom),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  ExpensesTableData copyWith(
          {String? id,
          String? date,
          String? title,
          int? amount,
          String? category,
          String? deductFrom,
          int? timestamp}) =>
      ExpensesTableData(
        id: id ?? this.id,
        date: date ?? this.date,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        deductFrom: deductFrom ?? this.deductFrom,
        timestamp: timestamp ?? this.timestamp,
      );
  ExpensesTableData copyWithCompanion(ExpensesTableCompanion data) {
    return ExpensesTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      deductFrom:
          data.deductFrom.present ? data.deductFrom.value : this.deductFrom,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('deductFrom: $deductFrom, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, title, amount, category, deductFrom, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpensesTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.deductFrom == this.deductFrom &&
          other.timestamp == this.timestamp);
}

class ExpensesTableCompanion extends UpdateCompanion<ExpensesTableData> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> title;
  final Value<int> amount;
  final Value<String> category;
  final Value<String> deductFrom;
  final Value<int> timestamp;
  final Value<int> rowid;
  const ExpensesTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.deductFrom = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesTableCompanion.insert({
    required String id,
    required String date,
    required String title,
    required int amount,
    this.category = const Value.absent(),
    this.deductFrom = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        title = Value(title),
        amount = Value(amount);
  static Insertable<ExpensesTableData> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? title,
    Expression<int>? amount,
    Expression<String>? category,
    Expression<String>? deductFrom,
    Expression<int>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (deductFrom != null) 'deduct_from': deductFrom,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? date,
      Value<String>? title,
      Value<int>? amount,
      Value<String>? category,
      Value<String>? deductFrom,
      Value<int>? timestamp,
      Value<int>? rowid}) {
    return ExpensesTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      deductFrom: deductFrom ?? this.deductFrom,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (deductFrom.present) {
      map['deduct_from'] = Variable<String>(deductFrom.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('deductFrom: $deductFrom, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthlyBillsTableTable extends MonthlyBillsTable
    with TableInfo<$MonthlyBillsTableTable, MonthlyBillsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyBillsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
      'due_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
      'is_paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, amount, dueDay, isPaid, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_bills_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MonthlyBillsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(_dueDayMeta,
          dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta));
    } else if (isInserting) {
      context.missing(_dueDayMeta);
    }
    if (data.containsKey('is_paid')) {
      context.handle(_isPaidMeta,
          isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonthlyBillsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyBillsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      dueDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_day'])!,
      isPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_paid'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $MonthlyBillsTableTable createAlias(String alias) {
    return $MonthlyBillsTableTable(attachedDatabase, alias);
  }
}

class MonthlyBillsTableData extends DataClass
    implements Insertable<MonthlyBillsTableData> {
  final String id;
  final String title;
  final int amount;
  final int dueDay;
  final bool isPaid;
  final int sortOrder;
  const MonthlyBillsTableData(
      {required this.id,
      required this.title,
      required this.amount,
      required this.dueDay,
      required this.isPaid,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<int>(amount);
    map['due_day'] = Variable<int>(dueDay);
    map['is_paid'] = Variable<bool>(isPaid);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MonthlyBillsTableCompanion toCompanion(bool nullToAbsent) {
    return MonthlyBillsTableCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      dueDay: Value(dueDay),
      isPaid: Value(isPaid),
      sortOrder: Value(sortOrder),
    );
  }

  factory MonthlyBillsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyBillsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<int>(json['amount']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<int>(amount),
      'dueDay': serializer.toJson<int>(dueDay),
      'isPaid': serializer.toJson<bool>(isPaid),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MonthlyBillsTableData copyWith(
          {String? id,
          String? title,
          int? amount,
          int? dueDay,
          bool? isPaid,
          int? sortOrder}) =>
      MonthlyBillsTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        dueDay: dueDay ?? this.dueDay,
        isPaid: isPaid ?? this.isPaid,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  MonthlyBillsTableData copyWithCompanion(MonthlyBillsTableCompanion data) {
    return MonthlyBillsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyBillsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('dueDay: $dueDay, ')
          ..write('isPaid: $isPaid, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, amount, dueDay, isPaid, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyBillsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.dueDay == this.dueDay &&
          other.isPaid == this.isPaid &&
          other.sortOrder == this.sortOrder);
}

class MonthlyBillsTableCompanion
    extends UpdateCompanion<MonthlyBillsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> amount;
  final Value<int> dueDay;
  final Value<bool> isPaid;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const MonthlyBillsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlyBillsTableCompanion.insert({
    required String id,
    required String title,
    required int amount,
    required int dueDay,
    this.isPaid = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        amount = Value(amount),
        dueDay = Value(dueDay);
  static Insertable<MonthlyBillsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? amount,
    Expression<int>? dueDay,
    Expression<bool>? isPaid,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (dueDay != null) 'due_day': dueDay,
      if (isPaid != null) 'is_paid': isPaid,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlyBillsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<int>? amount,
      Value<int>? dueDay,
      Value<bool>? isPaid,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return MonthlyBillsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      isPaid: isPaid ?? this.isPaid,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyBillsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('dueDay: $dueDay, ')
          ..write('isPaid: $isPaid, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [name, colorHex, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<CategoriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final String name;
  final String colorHex;
  final int sortOrder;
  const CategoriesTableData(
      {required this.name, required this.colorHex, required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      name: Value(name),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoriesTableData copyWith(
          {String? name, String? colorHex, int? sortOrder}) =>
      CategoriesTableData(
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  CategoriesTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoriesTableData(
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, colorHex, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<String> name;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesTableCompanion({
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    required String name,
    required String colorHex,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        colorHex = Value(colorHex);
  static Insertable<CategoriesTableData> custom({
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesTableCompanion copyWith(
      {Value<String>? name,
      Value<String>? colorHex,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return CategoriesTableCompanion(
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalHistoryTableTable extends GoalHistoryTable
    with TableInfo<$GoalHistoryTableTable, GoalHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _savedMeta = const VerificationMeta('saved');
  @override
  late final GeneratedColumn<int> saved = GeneratedColumn<int>(
      'saved', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'end_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
      'archived_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  @override
  List<GeneratedColumn> get $columns =>
      [id, amount, saved, startDate, endDate, archivedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_history_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<GoalHistoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('saved')) {
      context.handle(
          _savedMeta, saved.isAcceptableOrUnknown(data['saved']!, _savedMeta));
    } else if (isInserting) {
      context.missing(_savedMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalHistoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      saved: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}saved'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_date'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}archived_at'])!,
    );
  }

  @override
  $GoalHistoryTableTable createAlias(String alias) {
    return $GoalHistoryTableTable(attachedDatabase, alias);
  }
}

class GoalHistoryTableData extends DataClass
    implements Insertable<GoalHistoryTableData> {
  final String id;
  final int amount;
  final int saved;
  final String? startDate;
  final String endDate;
  final int archivedAt;
  const GoalHistoryTableData(
      {required this.id,
      required this.amount,
      required this.saved,
      this.startDate,
      required this.endDate,
      required this.archivedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<int>(amount);
    map['saved'] = Variable<int>(saved);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    map['end_date'] = Variable<String>(endDate);
    map['archived_at'] = Variable<int>(archivedAt);
    return map;
  }

  GoalHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return GoalHistoryTableCompanion(
      id: Value(id),
      amount: Value(amount),
      saved: Value(saved),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: Value(endDate),
      archivedAt: Value(archivedAt),
    );
  }

  factory GoalHistoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalHistoryTableData(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      saved: serializer.fromJson<int>(json['saved']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String>(json['endDate']),
      archivedAt: serializer.fromJson<int>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<int>(amount),
      'saved': serializer.toJson<int>(saved),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String>(endDate),
      'archivedAt': serializer.toJson<int>(archivedAt),
    };
  }

  GoalHistoryTableData copyWith(
          {String? id,
          int? amount,
          int? saved,
          Value<String?> startDate = const Value.absent(),
          String? endDate,
          int? archivedAt}) =>
      GoalHistoryTableData(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        saved: saved ?? this.saved,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate ?? this.endDate,
        archivedAt: archivedAt ?? this.archivedAt,
      );
  GoalHistoryTableData copyWithCompanion(GoalHistoryTableCompanion data) {
    return GoalHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      saved: data.saved.present ? data.saved.value : this.saved,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalHistoryTableData(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('saved: $saved, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amount, saved, startDate, endDate, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalHistoryTableData &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.saved == this.saved &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.archivedAt == this.archivedAt);
}

class GoalHistoryTableCompanion extends UpdateCompanion<GoalHistoryTableData> {
  final Value<String> id;
  final Value<int> amount;
  final Value<int> saved;
  final Value<String?> startDate;
  final Value<String> endDate;
  final Value<int> archivedAt;
  final Value<int> rowid;
  const GoalHistoryTableCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.saved = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalHistoryTableCompanion.insert({
    required String id,
    required int amount,
    required int saved,
    this.startDate = const Value.absent(),
    required String endDate,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        amount = Value(amount),
        saved = Value(saved),
        endDate = Value(endDate);
  static Insertable<GoalHistoryTableData> custom({
    Expression<String>? id,
    Expression<int>? amount,
    Expression<int>? saved,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (saved != null) 'saved': saved,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalHistoryTableCompanion copyWith(
      {Value<String>? id,
      Value<int>? amount,
      Value<int>? saved,
      Value<String?>? startDate,
      Value<String>? endDate,
      Value<int>? archivedAt,
      Value<int>? rowid}) {
    return GoalHistoryTableCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      saved: saved ?? this.saved,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (saved.present) {
      map['saved'] = Variable<int>(saved.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('saved: $saved, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HangoutSessionsTableTable extends HangoutSessionsTable
    with TableInfo<$HangoutSessionsTableTable, HangoutSessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HangoutSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _peopleJsonMeta =
      const VerificationMeta('peopleJson');
  @override
  late final GeneratedColumn<String> peopleJson = GeneratedColumn<String>(
      'people_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, date, peopleJson, isDeleted, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hangout_sessions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<HangoutSessionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('people_json')) {
      context.handle(
          _peopleJsonMeta,
          peopleJson.isAcceptableOrUnknown(
              data['people_json']!, _peopleJsonMeta));
    } else if (isInserting) {
      context.missing(_peopleJsonMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HangoutSessionsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HangoutSessionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      peopleJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}people_json'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $HangoutSessionsTableTable createAlias(String alias) {
    return $HangoutSessionsTableTable(attachedDatabase, alias);
  }
}

class HangoutSessionsTableData extends DataClass
    implements Insertable<HangoutSessionsTableData> {
  final String id;
  final String title;
  final String date;
  final String peopleJson;
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;
  const HangoutSessionsTableData(
      {required this.id,
      required this.title,
      required this.date,
      required this.peopleJson,
      required this.isDeleted,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    map['people_json'] = Variable<String>(peopleJson);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  HangoutSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return HangoutSessionsTableCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      peopleJson: Value(peopleJson),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HangoutSessionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HangoutSessionsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      peopleJson: serializer.fromJson<String>(json['peopleJson']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'peopleJson': serializer.toJson<String>(peopleJson),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  HangoutSessionsTableData copyWith(
          {String? id,
          String? title,
          String? date,
          String? peopleJson,
          bool? isDeleted,
          int? createdAt,
          int? updatedAt}) =>
      HangoutSessionsTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        peopleJson: peopleJson ?? this.peopleJson,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  HangoutSessionsTableData copyWithCompanion(
      HangoutSessionsTableCompanion data) {
    return HangoutSessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      peopleJson:
          data.peopleJson.present ? data.peopleJson.value : this.peopleJson,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HangoutSessionsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('peopleJson: $peopleJson, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, date, peopleJson, isDeleted, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HangoutSessionsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.peopleJson == this.peopleJson &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HangoutSessionsTableCompanion
    extends UpdateCompanion<HangoutSessionsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> date;
  final Value<String> peopleJson;
  final Value<bool> isDeleted;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const HangoutSessionsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.peopleJson = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HangoutSessionsTableCompanion.insert({
    required String id,
    required String title,
    required String date,
    required String peopleJson,
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        date = Value(date),
        peopleJson = Value(peopleJson);
  static Insertable<HangoutSessionsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? date,
    Expression<String>? peopleJson,
    Expression<bool>? isDeleted,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (peopleJson != null) 'people_json': peopleJson,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HangoutSessionsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? date,
      Value<String>? peopleJson,
      Value<bool>? isDeleted,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return HangoutSessionsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      peopleJson: peopleJson ?? this.peopleJson,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (peopleJson.present) {
      map['people_json'] = Variable<String>(peopleJson.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HangoutSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('peopleJson: $peopleJson, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HangoutExpensesTableTable extends HangoutExpensesTable
    with TableInfo<$HangoutExpensesTableTable, HangoutExpensesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HangoutExpensesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES hangout_sessions_table (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<int> totalAmount = GeneratedColumn<int>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _perPersonAmountMeta =
      const VerificationMeta('perPersonAmount');
  @override
  late final GeneratedColumn<int> perPersonAmount = GeneratedColumn<int>(
      'per_person_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paidByMeta = const VerificationMeta('paidBy');
  @override
  late final GeneratedColumn<String> paidBy = GeneratedColumn<String>(
      'paid_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('You'));
  static const VerificationMeta _splitTypeMeta =
      const VerificationMeta('splitType');
  @override
  late final GeneratedColumn<String> splitType = GeneratedColumn<String>(
      'split_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('equal'));
  static const VerificationMeta _participantsJsonMeta =
      const VerificationMeta('participantsJson');
  @override
  late final GeneratedColumn<String> participantsJson = GeneratedColumn<String>(
      'participants_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        title,
        totalAmount,
        perPersonAmount,
        paidBy,
        splitType,
        participantsJson,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hangout_expenses_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<HangoutExpensesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('per_person_amount')) {
      context.handle(
          _perPersonAmountMeta,
          perPersonAmount.isAcceptableOrUnknown(
              data['per_person_amount']!, _perPersonAmountMeta));
    } else if (isInserting) {
      context.missing(_perPersonAmountMeta);
    }
    if (data.containsKey('paid_by')) {
      context.handle(_paidByMeta,
          paidBy.isAcceptableOrUnknown(data['paid_by']!, _paidByMeta));
    }
    if (data.containsKey('split_type')) {
      context.handle(_splitTypeMeta,
          splitType.isAcceptableOrUnknown(data['split_type']!, _splitTypeMeta));
    }
    if (data.containsKey('participants_json')) {
      context.handle(
          _participantsJsonMeta,
          participantsJson.isAcceptableOrUnknown(
              data['participants_json']!, _participantsJsonMeta));
    } else if (isInserting) {
      context.missing(_participantsJsonMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HangoutExpensesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HangoutExpensesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_amount'])!,
      perPersonAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}per_person_amount'])!,
      paidBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}paid_by'])!,
      splitType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}split_type'])!,
      participantsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}participants_json'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $HangoutExpensesTableTable createAlias(String alias) {
    return $HangoutExpensesTableTable(attachedDatabase, alias);
  }
}

class HangoutExpensesTableData extends DataClass
    implements Insertable<HangoutExpensesTableData> {
  final String id;
  final String sessionId;
  final String title;
  final int totalAmount;
  final int perPersonAmount;
  final String paidBy;
  final String splitType;
  final String participantsJson;
  final int timestamp;
  const HangoutExpensesTableData(
      {required this.id,
      required this.sessionId,
      required this.title,
      required this.totalAmount,
      required this.perPersonAmount,
      required this.paidBy,
      required this.splitType,
      required this.participantsJson,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['title'] = Variable<String>(title);
    map['total_amount'] = Variable<int>(totalAmount);
    map['per_person_amount'] = Variable<int>(perPersonAmount);
    map['paid_by'] = Variable<String>(paidBy);
    map['split_type'] = Variable<String>(splitType);
    map['participants_json'] = Variable<String>(participantsJson);
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  HangoutExpensesTableCompanion toCompanion(bool nullToAbsent) {
    return HangoutExpensesTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      title: Value(title),
      totalAmount: Value(totalAmount),
      perPersonAmount: Value(perPersonAmount),
      paidBy: Value(paidBy),
      splitType: Value(splitType),
      participantsJson: Value(participantsJson),
      timestamp: Value(timestamp),
    );
  }

  factory HangoutExpensesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HangoutExpensesTableData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      title: serializer.fromJson<String>(json['title']),
      totalAmount: serializer.fromJson<int>(json['totalAmount']),
      perPersonAmount: serializer.fromJson<int>(json['perPersonAmount']),
      paidBy: serializer.fromJson<String>(json['paidBy']),
      splitType: serializer.fromJson<String>(json['splitType']),
      participantsJson: serializer.fromJson<String>(json['participantsJson']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'title': serializer.toJson<String>(title),
      'totalAmount': serializer.toJson<int>(totalAmount),
      'perPersonAmount': serializer.toJson<int>(perPersonAmount),
      'paidBy': serializer.toJson<String>(paidBy),
      'splitType': serializer.toJson<String>(splitType),
      'participantsJson': serializer.toJson<String>(participantsJson),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  HangoutExpensesTableData copyWith(
          {String? id,
          String? sessionId,
          String? title,
          int? totalAmount,
          int? perPersonAmount,
          String? paidBy,
          String? splitType,
          String? participantsJson,
          int? timestamp}) =>
      HangoutExpensesTableData(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        title: title ?? this.title,
        totalAmount: totalAmount ?? this.totalAmount,
        perPersonAmount: perPersonAmount ?? this.perPersonAmount,
        paidBy: paidBy ?? this.paidBy,
        splitType: splitType ?? this.splitType,
        participantsJson: participantsJson ?? this.participantsJson,
        timestamp: timestamp ?? this.timestamp,
      );
  HangoutExpensesTableData copyWithCompanion(
      HangoutExpensesTableCompanion data) {
    return HangoutExpensesTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      title: data.title.present ? data.title.value : this.title,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      perPersonAmount: data.perPersonAmount.present
          ? data.perPersonAmount.value
          : this.perPersonAmount,
      paidBy: data.paidBy.present ? data.paidBy.value : this.paidBy,
      splitType: data.splitType.present ? data.splitType.value : this.splitType,
      participantsJson: data.participantsJson.present
          ? data.participantsJson.value
          : this.participantsJson,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HangoutExpensesTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('title: $title, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('perPersonAmount: $perPersonAmount, ')
          ..write('paidBy: $paidBy, ')
          ..write('splitType: $splitType, ')
          ..write('participantsJson: $participantsJson, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, title, totalAmount,
      perPersonAmount, paidBy, splitType, participantsJson, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HangoutExpensesTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.title == this.title &&
          other.totalAmount == this.totalAmount &&
          other.perPersonAmount == this.perPersonAmount &&
          other.paidBy == this.paidBy &&
          other.splitType == this.splitType &&
          other.participantsJson == this.participantsJson &&
          other.timestamp == this.timestamp);
}

class HangoutExpensesTableCompanion
    extends UpdateCompanion<HangoutExpensesTableData> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> title;
  final Value<int> totalAmount;
  final Value<int> perPersonAmount;
  final Value<String> paidBy;
  final Value<String> splitType;
  final Value<String> participantsJson;
  final Value<int> timestamp;
  final Value<int> rowid;
  const HangoutExpensesTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.title = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.perPersonAmount = const Value.absent(),
    this.paidBy = const Value.absent(),
    this.splitType = const Value.absent(),
    this.participantsJson = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HangoutExpensesTableCompanion.insert({
    required String id,
    required String sessionId,
    required String title,
    required int totalAmount,
    required int perPersonAmount,
    this.paidBy = const Value.absent(),
    this.splitType = const Value.absent(),
    required String participantsJson,
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        title = Value(title),
        totalAmount = Value(totalAmount),
        perPersonAmount = Value(perPersonAmount),
        participantsJson = Value(participantsJson);
  static Insertable<HangoutExpensesTableData> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? title,
    Expression<int>? totalAmount,
    Expression<int>? perPersonAmount,
    Expression<String>? paidBy,
    Expression<String>? splitType,
    Expression<String>? participantsJson,
    Expression<int>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (title != null) 'title': title,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (perPersonAmount != null) 'per_person_amount': perPersonAmount,
      if (paidBy != null) 'paid_by': paidBy,
      if (splitType != null) 'split_type': splitType,
      if (participantsJson != null) 'participants_json': participantsJson,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HangoutExpensesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? title,
      Value<int>? totalAmount,
      Value<int>? perPersonAmount,
      Value<String>? paidBy,
      Value<String>? splitType,
      Value<String>? participantsJson,
      Value<int>? timestamp,
      Value<int>? rowid}) {
    return HangoutExpensesTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      perPersonAmount: perPersonAmount ?? this.perPersonAmount,
      paidBy: paidBy ?? this.paidBy,
      splitType: splitType ?? this.splitType,
      participantsJson: participantsJson ?? this.participantsJson,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<int>(totalAmount.value);
    }
    if (perPersonAmount.present) {
      map['per_person_amount'] = Variable<int>(perPersonAmount.value);
    }
    if (paidBy.present) {
      map['paid_by'] = Variable<String>(paidBy.value);
    }
    if (splitType.present) {
      map['split_type'] = Variable<String>(splitType.value);
    }
    if (participantsJson.present) {
      map['participants_json'] = Variable<String>(participantsJson.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HangoutExpensesTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('title: $title, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('perPersonAmount: $perPersonAmount, ')
          ..write('paidBy: $paidBy, ')
          ..write('splitType: $splitType, ')
          ..write('participantsJson: $participantsJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $DailyRecordsTableTable dailyRecordsTable =
      $DailyRecordsTableTable(this);
  late final $ExpensesTableTable expensesTable = $ExpensesTableTable(this);
  late final $MonthlyBillsTableTable monthlyBillsTable =
      $MonthlyBillsTableTable(this);
  late final $CategoriesTableTable categoriesTable =
      $CategoriesTableTable(this);
  late final $GoalHistoryTableTable goalHistoryTable =
      $GoalHistoryTableTable(this);
  late final $HangoutSessionsTableTable hangoutSessionsTable =
      $HangoutSessionsTableTable(this);
  late final $HangoutExpensesTableTable hangoutExpensesTable =
      $HangoutExpensesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        settingsTable,
        dailyRecordsTable,
        expensesTable,
        monthlyBillsTable,
        categoriesTable,
        goalHistoryTable,
        hangoutSessionsTable,
        hangoutExpensesTable
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('daily_records_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expenses_table', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('hangout_sessions_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('hangout_expenses_table', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<int> defaultAllowance,
  Value<int> goalAmount,
  Value<int> currentBalance,
  Value<String?> goalStartDate,
  Value<String> currencyCode,
  Value<String> currencySymbol,
  Value<String?> lastBillsMonth,
  Value<bool> themeIsDark,
  Value<bool> privacyMode,
  Value<bool> billNotificationsEnabled,
  Value<int> updatedAt,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<int> defaultAllowance,
  Value<int> goalAmount,
  Value<int> currentBalance,
  Value<String?> goalStartDate,
  Value<String> currencyCode,
  Value<String> currencySymbol,
  Value<String?> lastBillsMonth,
  Value<bool> themeIsDark,
  Value<bool> privacyMode,
  Value<bool> billNotificationsEnabled,
  Value<int> updatedAt,
});

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultAllowance => $composableBuilder(
      column: $table.defaultAllowance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goalAmount => $composableBuilder(
      column: $table.goalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalStartDate => $composableBuilder(
      column: $table.goalStartDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastBillsMonth => $composableBuilder(
      column: $table.lastBillsMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get themeIsDark => $composableBuilder(
      column: $table.themeIsDark, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get privacyMode => $composableBuilder(
      column: $table.privacyMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get billNotificationsEnabled => $composableBuilder(
      column: $table.billNotificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultAllowance => $composableBuilder(
      column: $table.defaultAllowance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goalAmount => $composableBuilder(
      column: $table.goalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalStartDate => $composableBuilder(
      column: $table.goalStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastBillsMonth => $composableBuilder(
      column: $table.lastBillsMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get themeIsDark => $composableBuilder(
      column: $table.themeIsDark, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get privacyMode => $composableBuilder(
      column: $table.privacyMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get billNotificationsEnabled => $composableBuilder(
      column: $table.billNotificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get defaultAllowance => $composableBuilder(
      column: $table.defaultAllowance, builder: (column) => column);

  GeneratedColumn<int> get goalAmount => $composableBuilder(
      column: $table.goalAmount, builder: (column) => column);

  GeneratedColumn<int> get currentBalance => $composableBuilder(
      column: $table.currentBalance, builder: (column) => column);

  GeneratedColumn<String> get goalStartDate => $composableBuilder(
      column: $table.goalStartDate, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol, builder: (column) => column);

  GeneratedColumn<String> get lastBillsMonth => $composableBuilder(
      column: $table.lastBillsMonth, builder: (column) => column);

  GeneratedColumn<bool> get themeIsDark => $composableBuilder(
      column: $table.themeIsDark, builder: (column) => column);

  GeneratedColumn<bool> get privacyMode => $composableBuilder(
      column: $table.privacyMode, builder: (column) => column);

  GeneratedColumn<bool> get billNotificationsEnabled => $composableBuilder(
      column: $table.billNotificationsEnabled, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()> {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> defaultAllowance = const Value.absent(),
            Value<int> goalAmount = const Value.absent(),
            Value<int> currentBalance = const Value.absent(),
            Value<String?> goalStartDate = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String?> lastBillsMonth = const Value.absent(),
            Value<bool> themeIsDark = const Value.absent(),
            Value<bool> privacyMode = const Value.absent(),
            Value<bool> billNotificationsEnabled = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            id: id,
            defaultAllowance: defaultAllowance,
            goalAmount: goalAmount,
            currentBalance: currentBalance,
            goalStartDate: goalStartDate,
            currencyCode: currencyCode,
            currencySymbol: currencySymbol,
            lastBillsMonth: lastBillsMonth,
            themeIsDark: themeIsDark,
            privacyMode: privacyMode,
            billNotificationsEnabled: billNotificationsEnabled,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> defaultAllowance = const Value.absent(),
            Value<int> goalAmount = const Value.absent(),
            Value<int> currentBalance = const Value.absent(),
            Value<String?> goalStartDate = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String?> lastBillsMonth = const Value.absent(),
            Value<bool> themeIsDark = const Value.absent(),
            Value<bool> privacyMode = const Value.absent(),
            Value<bool> billNotificationsEnabled = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            id: id,
            defaultAllowance: defaultAllowance,
            goalAmount: goalAmount,
            currentBalance: currentBalance,
            goalStartDate: goalStartDate,
            currencyCode: currencyCode,
            currencySymbol: currencySymbol,
            lastBillsMonth: lastBillsMonth,
            themeIsDark: themeIsDark,
            privacyMode: privacyMode,
            billNotificationsEnabled: billNotificationsEnabled,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SettingsTableTable, SettingsTableData>(table),
                    BaseReferences<_$AppDatabase, $SettingsTableTable,
                        SettingsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()>;
typedef $$DailyRecordsTableTableCreateCompanionBuilder
    = DailyRecordsTableCompanion Function({
  required String date,
  Value<String> title,
  Value<int> startingMoney,
  Value<bool> isDeleted,
  Value<int> updatedAt,
  Value<int> rowid,
});
typedef $$DailyRecordsTableTableUpdateCompanionBuilder
    = DailyRecordsTableCompanion Function({
  Value<String> date,
  Value<String> title,
  Value<int> startingMoney,
  Value<bool> isDeleted,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$DailyRecordsTableTableReferences extends BaseReferences<
    _$AppDatabase, $DailyRecordsTableTable, DailyRecordsTableData> {
  $$DailyRecordsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTableTable, List<ExpensesTableData>>
      _expensesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.expensesTable,
              aliasName: 'daily_records_table__date__expenses_table__date');

  $$ExpensesTableTableProcessedTableManager get expensesTableRefs {
    final manager = $$ExpensesTableTableTableManager($_db, $_db.expensesTable)
        .filter((f) => f.date.date.sqlEquals($_itemColumn<String>('date')!));

    final cache = $_typedResult.readTableOrNull(_expensesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DailyRecordsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DailyRecordsTableTable> {
  $$DailyRecordsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startingMoney => $composableBuilder(
      column: $table.startingMoney, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> expensesTableRefs(
      Expression<bool> Function($$ExpensesTableTableFilterComposer f) f) {
    final $$ExpensesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.date,
        referencedTable: $db.expensesTable,
        getReferencedColumn: (t) => t.date,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableTableFilterComposer(
              $db: $db,
              $table: $db.expensesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DailyRecordsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyRecordsTableTable> {
  $$DailyRecordsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startingMoney => $composableBuilder(
      column: $table.startingMoney,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyRecordsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyRecordsTableTable> {
  $$DailyRecordsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get startingMoney => $composableBuilder(
      column: $table.startingMoney, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> expensesTableRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableTableAnnotationComposer a) f) {
    final $$ExpensesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.date,
        referencedTable: $db.expensesTable,
        getReferencedColumn: (t) => t.date,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.expensesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DailyRecordsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyRecordsTableTable,
    DailyRecordsTableData,
    $$DailyRecordsTableTableFilterComposer,
    $$DailyRecordsTableTableOrderingComposer,
    $$DailyRecordsTableTableAnnotationComposer,
    $$DailyRecordsTableTableCreateCompanionBuilder,
    $$DailyRecordsTableTableUpdateCompanionBuilder,
    (DailyRecordsTableData, $$DailyRecordsTableTableReferences),
    DailyRecordsTableData,
    PrefetchHooks Function({bool expensesTableRefs})> {
  $$DailyRecordsTableTableTableManager(
      _$AppDatabase db, $DailyRecordsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyRecordsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyRecordsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyRecordsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> date = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> startingMoney = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyRecordsTableCompanion(
            date: date,
            title: title,
            startingMoney: startingMoney,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String date,
            Value<String> title = const Value.absent(),
            Value<int> startingMoney = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyRecordsTableCompanion.insert(
            date: date,
            title: title,
            startingMoney: startingMoney,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DailyRecordsTableTable, DailyRecordsTableData>(
                        table),
                    $$DailyRecordsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({expensesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expensesTableRefs) db.expensesTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesTableRefs)
                    await $_getPrefetchedDataByColumns<
                            DailyRecordsTableData,
                            $DailyRecordsTableTable,
                            ExpensesTableData,
                            $ExpensesTableTable>(
                        currentTable: table,
                        referencedTable: $$DailyRecordsTableTableReferences
                            ._expensesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DailyRecordsTableTableReferences(db, table, p0)
                                .expensesTableRefs,
                        currentColumn: 'date',
                        referencedColumn: 'date',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DailyRecordsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyRecordsTableTable,
    DailyRecordsTableData,
    $$DailyRecordsTableTableFilterComposer,
    $$DailyRecordsTableTableOrderingComposer,
    $$DailyRecordsTableTableAnnotationComposer,
    $$DailyRecordsTableTableCreateCompanionBuilder,
    $$DailyRecordsTableTableUpdateCompanionBuilder,
    (DailyRecordsTableData, $$DailyRecordsTableTableReferences),
    DailyRecordsTableData,
    PrefetchHooks Function({bool expensesTableRefs})>;
typedef $$ExpensesTableTableCreateCompanionBuilder = ExpensesTableCompanion
    Function({
  required String id,
  required String date,
  required String title,
  required int amount,
  Value<String> category,
  Value<String> deductFrom,
  Value<int> timestamp,
  Value<int> rowid,
});
typedef $$ExpensesTableTableUpdateCompanionBuilder = ExpensesTableCompanion
    Function({
  Value<String> id,
  Value<String> date,
  Value<String> title,
  Value<int> amount,
  Value<String> category,
  Value<String> deductFrom,
  Value<int> timestamp,
  Value<int> rowid,
});

final class $$ExpensesTableTableReferences extends BaseReferences<_$AppDatabase,
    $ExpensesTableTable, ExpensesTableData> {
  $$ExpensesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DailyRecordsTableTable _dateTable(_$AppDatabase db) =>
      db.dailyRecordsTable
          .createAlias('expenses_table__date__daily_records_table__date');

  $$DailyRecordsTableTableProcessedTableManager get date {
    final $_column = $_itemColumn<String>('date')!;

    final manager =
        $$DailyRecordsTableTableTableManager($_db, $_db.dailyRecordsTable)
            .filter((f) => f.date.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpensesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deductFrom => $composableBuilder(
      column: $table.deductFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $$DailyRecordsTableTableFilterComposer get date {
    final $$DailyRecordsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.date,
        referencedTable: $db.dailyRecordsTable,
        getReferencedColumn: (t) => t.date,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyRecordsTableTableFilterComposer(
              $db: $db,
              $table: $db.dailyRecordsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deductFrom => $composableBuilder(
      column: $table.deductFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $$DailyRecordsTableTableOrderingComposer get date {
    final $$DailyRecordsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.date,
        referencedTable: $db.dailyRecordsTable,
        getReferencedColumn: (t) => t.date,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyRecordsTableTableOrderingComposer(
              $db: $db,
              $table: $db.dailyRecordsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get deductFrom => $composableBuilder(
      column: $table.deductFrom, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$DailyRecordsTableTableAnnotationComposer get date {
    final $$DailyRecordsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.date,
            referencedTable: $db.dailyRecordsTable,
            getReferencedColumn: (t) => t.date,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DailyRecordsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.dailyRecordsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$ExpensesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTableTable,
    ExpensesTableData,
    $$ExpensesTableTableFilterComposer,
    $$ExpensesTableTableOrderingComposer,
    $$ExpensesTableTableAnnotationComposer,
    $$ExpensesTableTableCreateCompanionBuilder,
    $$ExpensesTableTableUpdateCompanionBuilder,
    (ExpensesTableData, $$ExpensesTableTableReferences),
    ExpensesTableData,
    PrefetchHooks Function({bool date})> {
  $$ExpensesTableTableTableManager(_$AppDatabase db, $ExpensesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> deductFrom = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesTableCompanion(
            id: id,
            date: date,
            title: title,
            amount: amount,
            category: category,
            deductFrom: deductFrom,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String date,
            required String title,
            required int amount,
            Value<String> category = const Value.absent(),
            Value<String> deductFrom = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesTableCompanion.insert(
            id: id,
            date: date,
            title: title,
            amount: amount,
            category: category,
            deductFrom: deductFrom,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ExpensesTableTable, ExpensesTableData>(table),
                    $$ExpensesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({date = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (date) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.date,
                    referencedTable:
                        $$ExpensesTableTableReferences._dateTable(db),
                    referencedColumn:
                        $$ExpensesTableTableReferences._dateTable(db).date,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpensesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTableTable,
    ExpensesTableData,
    $$ExpensesTableTableFilterComposer,
    $$ExpensesTableTableOrderingComposer,
    $$ExpensesTableTableAnnotationComposer,
    $$ExpensesTableTableCreateCompanionBuilder,
    $$ExpensesTableTableUpdateCompanionBuilder,
    (ExpensesTableData, $$ExpensesTableTableReferences),
    ExpensesTableData,
    PrefetchHooks Function({bool date})>;
typedef $$MonthlyBillsTableTableCreateCompanionBuilder
    = MonthlyBillsTableCompanion Function({
  required String id,
  required String title,
  required int amount,
  required int dueDay,
  Value<bool> isPaid,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$MonthlyBillsTableTableUpdateCompanionBuilder
    = MonthlyBillsTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<int> amount,
  Value<int> dueDay,
  Value<bool> isPaid,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$MonthlyBillsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlyBillsTableTable> {
  $$MonthlyBillsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueDay => $composableBuilder(
      column: $table.dueDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPaid => $composableBuilder(
      column: $table.isPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$MonthlyBillsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlyBillsTableTable> {
  $$MonthlyBillsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueDay => $composableBuilder(
      column: $table.dueDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPaid => $composableBuilder(
      column: $table.isPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$MonthlyBillsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlyBillsTableTable> {
  $$MonthlyBillsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$MonthlyBillsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MonthlyBillsTableTable,
    MonthlyBillsTableData,
    $$MonthlyBillsTableTableFilterComposer,
    $$MonthlyBillsTableTableOrderingComposer,
    $$MonthlyBillsTableTableAnnotationComposer,
    $$MonthlyBillsTableTableCreateCompanionBuilder,
    $$MonthlyBillsTableTableUpdateCompanionBuilder,
    (
      MonthlyBillsTableData,
      BaseReferences<_$AppDatabase, $MonthlyBillsTableTable,
          MonthlyBillsTableData>
    ),
    MonthlyBillsTableData,
    PrefetchHooks Function()> {
  $$MonthlyBillsTableTableTableManager(
      _$AppDatabase db, $MonthlyBillsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyBillsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyBillsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlyBillsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int> dueDay = const Value.absent(),
            Value<bool> isPaid = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonthlyBillsTableCompanion(
            id: id,
            title: title,
            amount: amount,
            dueDay: dueDay,
            isPaid: isPaid,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required int amount,
            required int dueDay,
            Value<bool> isPaid = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonthlyBillsTableCompanion.insert(
            id: id,
            title: title,
            amount: amount,
            dueDay: dueDay,
            isPaid: isPaid,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MonthlyBillsTableTable, MonthlyBillsTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $MonthlyBillsTableTable,
                        MonthlyBillsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MonthlyBillsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MonthlyBillsTableTable,
    MonthlyBillsTableData,
    $$MonthlyBillsTableTableFilterComposer,
    $$MonthlyBillsTableTableOrderingComposer,
    $$MonthlyBillsTableTableAnnotationComposer,
    $$MonthlyBillsTableTableCreateCompanionBuilder,
    $$MonthlyBillsTableTableUpdateCompanionBuilder,
    (
      MonthlyBillsTableData,
      BaseReferences<_$AppDatabase, $MonthlyBillsTableTable,
          MonthlyBillsTableData>
    ),
    MonthlyBillsTableData,
    PrefetchHooks Function()>;
typedef $$CategoriesTableTableCreateCompanionBuilder = CategoriesTableCompanion
    Function({
  required String name,
  required String colorHex,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$CategoriesTableTableUpdateCompanionBuilder = CategoriesTableCompanion
    Function({
  Value<String> name,
  Value<String> colorHex,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTableTable,
    CategoriesTableData,
    $$CategoriesTableTableFilterComposer,
    $$CategoriesTableTableOrderingComposer,
    $$CategoriesTableTableAnnotationComposer,
    $$CategoriesTableTableCreateCompanionBuilder,
    $$CategoriesTableTableUpdateCompanionBuilder,
    (
      CategoriesTableData,
      BaseReferences<_$AppDatabase, $CategoriesTableTable, CategoriesTableData>
    ),
    CategoriesTableData,
    PrefetchHooks Function()> {
  $$CategoriesTableTableTableManager(
      _$AppDatabase db, $CategoriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesTableCompanion(
            name: name,
            colorHex: colorHex,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String name,
            required String colorHex,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesTableCompanion.insert(
            name: name,
            colorHex: colorHex,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CategoriesTableTable, CategoriesTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $CategoriesTableTable,
                        CategoriesTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTableTable,
    CategoriesTableData,
    $$CategoriesTableTableFilterComposer,
    $$CategoriesTableTableOrderingComposer,
    $$CategoriesTableTableAnnotationComposer,
    $$CategoriesTableTableCreateCompanionBuilder,
    $$CategoriesTableTableUpdateCompanionBuilder,
    (
      CategoriesTableData,
      BaseReferences<_$AppDatabase, $CategoriesTableTable, CategoriesTableData>
    ),
    CategoriesTableData,
    PrefetchHooks Function()>;
typedef $$GoalHistoryTableTableCreateCompanionBuilder
    = GoalHistoryTableCompanion Function({
  required String id,
  required int amount,
  required int saved,
  Value<String?> startDate,
  required String endDate,
  Value<int> archivedAt,
  Value<int> rowid,
});
typedef $$GoalHistoryTableTableUpdateCompanionBuilder
    = GoalHistoryTableCompanion Function({
  Value<String> id,
  Value<int> amount,
  Value<int> saved,
  Value<String?> startDate,
  Value<String> endDate,
  Value<int> archivedAt,
  Value<int> rowid,
});

class $$GoalHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $GoalHistoryTableTable> {
  $$GoalHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get saved => $composableBuilder(
      column: $table.saved, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));
}

class $$GoalHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalHistoryTableTable> {
  $$GoalHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get saved => $composableBuilder(
      column: $table.saved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalHistoryTableTable> {
  $$GoalHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get saved =>
      $composableBuilder(column: $table.saved, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);
}

class $$GoalHistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalHistoryTableTable,
    GoalHistoryTableData,
    $$GoalHistoryTableTableFilterComposer,
    $$GoalHistoryTableTableOrderingComposer,
    $$GoalHistoryTableTableAnnotationComposer,
    $$GoalHistoryTableTableCreateCompanionBuilder,
    $$GoalHistoryTableTableUpdateCompanionBuilder,
    (
      GoalHistoryTableData,
      BaseReferences<_$AppDatabase, $GoalHistoryTableTable,
          GoalHistoryTableData>
    ),
    GoalHistoryTableData,
    PrefetchHooks Function()> {
  $$GoalHistoryTableTableTableManager(
      _$AppDatabase db, $GoalHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalHistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int> saved = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String> endDate = const Value.absent(),
            Value<int> archivedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalHistoryTableCompanion(
            id: id,
            amount: amount,
            saved: saved,
            startDate: startDate,
            endDate: endDate,
            archivedAt: archivedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int amount,
            required int saved,
            Value<String?> startDate = const Value.absent(),
            required String endDate,
            Value<int> archivedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalHistoryTableCompanion.insert(
            id: id,
            amount: amount,
            saved: saved,
            startDate: startDate,
            endDate: endDate,
            archivedAt: archivedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GoalHistoryTableTable, GoalHistoryTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $GoalHistoryTableTable,
                        GoalHistoryTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalHistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalHistoryTableTable,
    GoalHistoryTableData,
    $$GoalHistoryTableTableFilterComposer,
    $$GoalHistoryTableTableOrderingComposer,
    $$GoalHistoryTableTableAnnotationComposer,
    $$GoalHistoryTableTableCreateCompanionBuilder,
    $$GoalHistoryTableTableUpdateCompanionBuilder,
    (
      GoalHistoryTableData,
      BaseReferences<_$AppDatabase, $GoalHistoryTableTable,
          GoalHistoryTableData>
    ),
    GoalHistoryTableData,
    PrefetchHooks Function()>;
typedef $$HangoutSessionsTableTableCreateCompanionBuilder
    = HangoutSessionsTableCompanion Function({
  required String id,
  required String title,
  required String date,
  required String peopleJson,
  Value<bool> isDeleted,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});
typedef $$HangoutSessionsTableTableUpdateCompanionBuilder
    = HangoutSessionsTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> date,
  Value<String> peopleJson,
  Value<bool> isDeleted,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$HangoutSessionsTableTableReferences extends BaseReferences<
    _$AppDatabase, $HangoutSessionsTableTable, HangoutSessionsTableData> {
  $$HangoutSessionsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HangoutExpensesTableTable,
      List<HangoutExpensesTableData>> _hangoutExpensesTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.hangoutExpensesTable,
          aliasName:
              'hangout_sessions_table__id__hangout_expenses_table__session_id');

  $$HangoutExpensesTableTableProcessedTableManager
      get hangoutExpensesTableRefs {
    final manager = $$HangoutExpensesTableTableTableManager(
            $_db, $_db.hangoutExpensesTable)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_hangoutExpensesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$HangoutSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HangoutSessionsTableTable> {
  $$HangoutSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get peopleJson => $composableBuilder(
      column: $table.peopleJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> hangoutExpensesTableRefs(
      Expression<bool> Function($$HangoutExpensesTableTableFilterComposer f)
          f) {
    final $$HangoutExpensesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.hangoutExpensesTable,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HangoutExpensesTableTableFilterComposer(
              $db: $db,
              $table: $db.hangoutExpensesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HangoutSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HangoutSessionsTableTable> {
  $$HangoutSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get peopleJson => $composableBuilder(
      column: $table.peopleJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$HangoutSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HangoutSessionsTableTable> {
  $$HangoutSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get peopleJson => $composableBuilder(
      column: $table.peopleJson, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> hangoutExpensesTableRefs<T extends Object>(
      Expression<T> Function($$HangoutExpensesTableTableAnnotationComposer a)
          f) {
    final $$HangoutExpensesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.hangoutExpensesTable,
            getReferencedColumn: (t) => t.sessionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$HangoutExpensesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.hangoutExpensesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$HangoutSessionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HangoutSessionsTableTable,
    HangoutSessionsTableData,
    $$HangoutSessionsTableTableFilterComposer,
    $$HangoutSessionsTableTableOrderingComposer,
    $$HangoutSessionsTableTableAnnotationComposer,
    $$HangoutSessionsTableTableCreateCompanionBuilder,
    $$HangoutSessionsTableTableUpdateCompanionBuilder,
    (HangoutSessionsTableData, $$HangoutSessionsTableTableReferences),
    HangoutSessionsTableData,
    PrefetchHooks Function({bool hangoutExpensesTableRefs})> {
  $$HangoutSessionsTableTableTableManager(
      _$AppDatabase db, $HangoutSessionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HangoutSessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HangoutSessionsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HangoutSessionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> peopleJson = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HangoutSessionsTableCompanion(
            id: id,
            title: title,
            date: date,
            peopleJson: peopleJson,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String date,
            required String peopleJson,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HangoutSessionsTableCompanion.insert(
            id: id,
            title: title,
            date: date,
            peopleJson: peopleJson,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$HangoutSessionsTableTable,
                        HangoutSessionsTableData>(table),
                    $$HangoutSessionsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({hangoutExpensesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (hangoutExpensesTableRefs) db.hangoutExpensesTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (hangoutExpensesTableRefs)
                    await $_getPrefetchedDataByColumns<
                            HangoutSessionsTableData,
                            $HangoutSessionsTableTable,
                            HangoutExpensesTableData,
                            $HangoutExpensesTableTable>(
                        currentTable: table,
                        referencedTable: $$HangoutSessionsTableTableReferences
                            ._hangoutExpensesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HangoutSessionsTableTableReferences(db, table, p0)
                                .hangoutExpensesTableRefs,
                        currentColumn: 'id',
                        referencedColumn: 'session_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$HangoutSessionsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $HangoutSessionsTableTable,
        HangoutSessionsTableData,
        $$HangoutSessionsTableTableFilterComposer,
        $$HangoutSessionsTableTableOrderingComposer,
        $$HangoutSessionsTableTableAnnotationComposer,
        $$HangoutSessionsTableTableCreateCompanionBuilder,
        $$HangoutSessionsTableTableUpdateCompanionBuilder,
        (HangoutSessionsTableData, $$HangoutSessionsTableTableReferences),
        HangoutSessionsTableData,
        PrefetchHooks Function({bool hangoutExpensesTableRefs})>;
typedef $$HangoutExpensesTableTableCreateCompanionBuilder
    = HangoutExpensesTableCompanion Function({
  required String id,
  required String sessionId,
  required String title,
  required int totalAmount,
  required int perPersonAmount,
  Value<String> paidBy,
  Value<String> splitType,
  required String participantsJson,
  Value<int> timestamp,
  Value<int> rowid,
});
typedef $$HangoutExpensesTableTableUpdateCompanionBuilder
    = HangoutExpensesTableCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> title,
  Value<int> totalAmount,
  Value<int> perPersonAmount,
  Value<String> paidBy,
  Value<String> splitType,
  Value<String> participantsJson,
  Value<int> timestamp,
  Value<int> rowid,
});

final class $$HangoutExpensesTableTableReferences extends BaseReferences<
    _$AppDatabase, $HangoutExpensesTableTable, HangoutExpensesTableData> {
  $$HangoutExpensesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $HangoutSessionsTableTable _sessionIdTable(_$AppDatabase db) =>
      db.hangoutSessionsTable.createAlias(
          'hangout_expenses_table__session_id__hangout_sessions_table__id');

  $$HangoutSessionsTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager =
        $$HangoutSessionsTableTableTableManager($_db, $_db.hangoutSessionsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$HangoutExpensesTableTableFilterComposer
    extends Composer<_$AppDatabase, $HangoutExpensesTableTable> {
  $$HangoutExpensesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get perPersonAmount => $composableBuilder(
      column: $table.perPersonAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidBy => $composableBuilder(
      column: $table.paidBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get splitType => $composableBuilder(
      column: $table.splitType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participantsJson => $composableBuilder(
      column: $table.participantsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $$HangoutSessionsTableTableFilterComposer get sessionId {
    final $$HangoutSessionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.hangoutSessionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HangoutSessionsTableTableFilterComposer(
              $db: $db,
              $table: $db.hangoutSessionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HangoutExpensesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HangoutExpensesTableTable> {
  $$HangoutExpensesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get perPersonAmount => $composableBuilder(
      column: $table.perPersonAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidBy => $composableBuilder(
      column: $table.paidBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get splitType => $composableBuilder(
      column: $table.splitType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participantsJson => $composableBuilder(
      column: $table.participantsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $$HangoutSessionsTableTableOrderingComposer get sessionId {
    final $$HangoutSessionsTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.hangoutSessionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$HangoutSessionsTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.hangoutSessionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$HangoutExpensesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HangoutExpensesTableTable> {
  $$HangoutExpensesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<int> get perPersonAmount => $composableBuilder(
      column: $table.perPersonAmount, builder: (column) => column);

  GeneratedColumn<String> get paidBy =>
      $composableBuilder(column: $table.paidBy, builder: (column) => column);

  GeneratedColumn<String> get splitType =>
      $composableBuilder(column: $table.splitType, builder: (column) => column);

  GeneratedColumn<String> get participantsJson => $composableBuilder(
      column: $table.participantsJson, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$HangoutSessionsTableTableAnnotationComposer get sessionId {
    final $$HangoutSessionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.hangoutSessionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$HangoutSessionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.hangoutSessionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$HangoutExpensesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HangoutExpensesTableTable,
    HangoutExpensesTableData,
    $$HangoutExpensesTableTableFilterComposer,
    $$HangoutExpensesTableTableOrderingComposer,
    $$HangoutExpensesTableTableAnnotationComposer,
    $$HangoutExpensesTableTableCreateCompanionBuilder,
    $$HangoutExpensesTableTableUpdateCompanionBuilder,
    (HangoutExpensesTableData, $$HangoutExpensesTableTableReferences),
    HangoutExpensesTableData,
    PrefetchHooks Function({bool sessionId})> {
  $$HangoutExpensesTableTableTableManager(
      _$AppDatabase db, $HangoutExpensesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HangoutExpensesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HangoutExpensesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HangoutExpensesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> totalAmount = const Value.absent(),
            Value<int> perPersonAmount = const Value.absent(),
            Value<String> paidBy = const Value.absent(),
            Value<String> splitType = const Value.absent(),
            Value<String> participantsJson = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HangoutExpensesTableCompanion(
            id: id,
            sessionId: sessionId,
            title: title,
            totalAmount: totalAmount,
            perPersonAmount: perPersonAmount,
            paidBy: paidBy,
            splitType: splitType,
            participantsJson: participantsJson,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String title,
            required int totalAmount,
            required int perPersonAmount,
            Value<String> paidBy = const Value.absent(),
            Value<String> splitType = const Value.absent(),
            required String participantsJson,
            Value<int> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HangoutExpensesTableCompanion.insert(
            id: id,
            sessionId: sessionId,
            title: title,
            totalAmount: totalAmount,
            perPersonAmount: perPersonAmount,
            paidBy: paidBy,
            splitType: splitType,
            participantsJson: participantsJson,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$HangoutExpensesTableTable,
                        HangoutExpensesTableData>(table),
                    $$HangoutExpensesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable: $$HangoutExpensesTableTableReferences
                        ._sessionIdTable(db),
                    referencedColumn: $$HangoutExpensesTableTableReferences
                        ._sessionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$HangoutExpensesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $HangoutExpensesTableTable,
        HangoutExpensesTableData,
        $$HangoutExpensesTableTableFilterComposer,
        $$HangoutExpensesTableTableOrderingComposer,
        $$HangoutExpensesTableTableAnnotationComposer,
        $$HangoutExpensesTableTableCreateCompanionBuilder,
        $$HangoutExpensesTableTableUpdateCompanionBuilder,
        (HangoutExpensesTableData, $$HangoutExpensesTableTableReferences),
        HangoutExpensesTableData,
        PrefetchHooks Function({bool sessionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$DailyRecordsTableTableTableManager get dailyRecordsTable =>
      $$DailyRecordsTableTableTableManager(_db, _db.dailyRecordsTable);
  $$ExpensesTableTableTableManager get expensesTable =>
      $$ExpensesTableTableTableManager(_db, _db.expensesTable);
  $$MonthlyBillsTableTableTableManager get monthlyBillsTable =>
      $$MonthlyBillsTableTableTableManager(_db, _db.monthlyBillsTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
  $$GoalHistoryTableTableTableManager get goalHistoryTable =>
      $$GoalHistoryTableTableTableManager(_db, _db.goalHistoryTable);
  $$HangoutSessionsTableTableTableManager get hangoutSessionsTable =>
      $$HangoutSessionsTableTableTableManager(_db, _db.hangoutSessionsTable);
  $$HangoutExpensesTableTableTableManager get hangoutExpensesTable =>
      $$HangoutExpensesTableTableTableManager(_db, _db.hangoutExpensesTable);
}
