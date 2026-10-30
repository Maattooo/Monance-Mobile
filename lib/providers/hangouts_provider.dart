import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../core/utils/currency_formatter.dart';
import '../models/expense_model.dart';
import '../models/hangout_expense_model.dart';
import '../models/hangout_session_model.dart';
import 'database_provider.dart';
import 'records_provider.dart';

class _Debtor {
  final String name;
  int debt; // cents
  _Debtor(this.name, this.debt);
}

class _Creditor {
  final String name;
  int credit; // cents
  _Creditor(this.name, this.credit);
}

class HangoutsNotifier extends StateNotifier<List<HangoutSessionModel>> {
  final AppDatabase _db;
  final Ref _ref;
  static const _uuid = Uuid();

  HangoutsNotifier(this._db, this._ref) : super([]) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    final sessionRows = await (_db.select(_db.hangoutSessionsTable)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)]))
        .get();

    final expenseRows = await _db.select(_db.hangoutExpensesTable).get();
    final Map<String, List<HangoutExpenseModel>> expensesBySession = {};
    for (final expRow in expenseRows) {
      final model = HangoutExpenseModel.fromDrift(expRow);
      expensesBySession.putIfAbsent(model.sessionId, () => []).add(model);
    }

    final sessions = sessionRows.map((s) {
      final expenses = expensesBySession[s.id] ?? [];
      return HangoutSessionModel.fromDrift(s, expenses);
    }).toList();

    state = sessions;
  }

  /// specification.md §6.6.1: Zero-Sum Remainder-Safe Expense Split
  /// Calculates exact participant shares for an expense in integer cents.
  static Map<String, int> splitExpense({
    required int totalAmount,
    required List<String> participants,
    String paidBy = 'You',
  }) {
    if (participants.isEmpty) return {};

    final n = participants.length;
    final baseShare = totalAmount ~/ n;
    final remainder = totalAmount % n;

    // Remainder recipient: if participants.contains(paidBy), recipient is paidBy; otherwise participants.first
    final String remainderRecipient =
        participants.contains(paidBy) ? paidBy : participants.first;

    final Map<String, int> shares = {};
    for (final p in participants) {
      if (p == remainderRecipient) {
        shares[p] = baseShare + remainder;
      } else {
        shares[p] = baseShare;
      }
    }

    return shares;
  }

  /// Calculates exact share for a single person in an expense
  static int exactShareForPerson(String person, HangoutExpenseModel expense) {
    if (!expense.participants.contains(person)) return 0;
    final shares = splitExpense(
      totalAmount: expense.totalAmount,
      participants: expense.participants,
      paidBy: expense.paidBy,
    );
    return shares[person] ?? 0;
  }

  /// specification.md §6.6.2: "Who Owes Whom" Pairwise Debt Settlement Algorithm
  static List<String> calculateWhoOwesWhom(HangoutSessionModel session, [String currencySymbol = '₱']) {
    // 1. Calculate Paid, Owed, and Net for each person in session.people
    final Map<String, int> paid = {};
    final Map<String, int> owed = {};

    for (final person in session.people) {
      paid[person] = 0;
      owed[person] = 0;
    }

    for (final exp in session.expenses) {
      // Add to payer
      paid[exp.paidBy] = (paid[exp.paidBy] ?? 0) + exp.totalAmount;

      // Add to each participant's owed share
      final shares = splitExpense(
        totalAmount: exp.totalAmount,
        participants: exp.participants,
        paidBy: exp.paidBy,
      );
      for (final entry in shares.entries) {
        owed[entry.key] = (owed[entry.key] ?? 0) + entry.value;
      }
    }

    final List<_Debtor> debtors = [];
    final List<_Creditor> creditors = [];

    for (final person in session.people) {
      final net = (paid[person] ?? 0) - (owed[person] ?? 0);
      if (net < 0) {
        debtors.add(_Debtor(person, -net));
      } else if (net > 0) {
        creditors.add(_Creditor(person, net));
      }
    }

    final List<String> settlementLines = [];

    // Greedily match largest Debtor with largest Creditor
    while (debtors.isNotEmpty && creditors.isNotEmpty) {
      // Deterministic sort: largest amount first, secondary sort alphabetically by name
      debtors.sort((a, b) => b.debt != a.debt ? b.debt.compareTo(a.debt) : a.name.compareTo(b.name));
      creditors.sort((a, b) => b.credit != a.credit ? b.credit.compareTo(a.credit) : a.name.compareTo(b.name));

      final debtor = debtors.first;
      final creditor = creditors.first;

      final settleAmount = min(debtor.debt, creditor.credit);
      final formattedAmount = formatCurrency(settleAmount / 100.0, currencySymbol);

      settlementLines.add('${debtor.name} owes ${creditor.name} $formattedAmount');

      debtor.debt -= settleAmount;
      creditor.credit -= settleAmount;

      if (debtor.debt == 0) {
        debtors.removeAt(0);
      }
      if (creditor.credit == 0) {
        creditors.removeAt(0);
      }
    }

    return settlementLines;
  }

  /// specification.md §6.6.3: Idempotent Merge & Overwrite to Calendar
  Future<void> logHangoutToCalendar({
    required HangoutSessionModel session,
    required String mode, // 'merge' | 'overwrite'
    required String modalDeductFrom, // 'allowance' | 'balance'
    required bool modalIsAllowance,
    int allowanceCents = 0,
  }) async {
    final normalizedDeduct =
        (modalDeductFrom == 'wallet' || modalDeductFrom == 'balance') ? 'balance' : 'allowance';

    // Filter session expenses where exp.participants.contains('You')
    final yourHangoutExpenses = <ExpenseModel>[];
    for (final exp in session.expenses) {
      if (exp.participants.contains('You')) {
        final share = exactShareForPerson('You', exp);
        yourHangoutExpenses.add(ExpenseModel(
          id: 'hangout-${session.id}-${exp.id}',
          date: session.date,
          title: '${session.title}: ${exp.title}',
          amount: share,
          category: 'Hangout',
          deductFrom: normalizedDeduct,
          timestamp: exp.timestamp,
        ));
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final prefix = 'hangout-${session.id}-';

    await _db.transaction(() async {
      final existingRecord = await (_db.select(_db.dailyRecordsTable)
            ..where((t) => t.date.equals(session.date)))
          .getSingleOrNull();

      if (mode == 'merge' && existingRecord != null && !existingRecord.isDeleted) {
        // Mode == 'merge' and date is already occupied
        // 1. Delete old hangout expenses for this session on this date
        await (_db.delete(_db.expensesTable)
              ..where((t) => t.date.equals(session.date) & t.id.like('$prefix%')))
            .go();

        // 2. Insert new hangout expenses
        for (final exp in yourHangoutExpenses) {
          await _db.into(_db.expensesTable).insert(
                exp.toCompanion(),
                mode: drift.InsertMode.insertOrReplace,
              );
        }

        // 3. Update startingMoney if modalIsAllowance is true
        if (modalIsAllowance) {
          await (_db.update(_db.dailyRecordsTable)..where((t) => t.date.equals(session.date))).write(
            DailyRecordsTableCompanion(
              startingMoney: drift.Value(allowanceCents),
              updatedAt: drift.Value(now),
            ),
          );
        }
      } else {
        // Mode == 'overwrite' or date is unoccupied
        final newStartingMoney = modalIsAllowance ? allowanceCents : 0;
        final newTitle = session.title.isNotEmpty ? session.title : 'school';

        // Replace or create DailyRecord
        await _db.into(_db.dailyRecordsTable).insert(
              DailyRecordsTableCompanion(
                date: drift.Value(session.date),
                title: drift.Value(newTitle),
                startingMoney: drift.Value(newStartingMoney),
                isDeleted: const drift.Value(false),
                updatedAt: drift.Value(now),
              ),
              mode: drift.InsertMode.insertOrReplace,
            );

        // Delete ALL existing expenses on this date
        await (_db.delete(_db.expensesTable)..where((t) => t.date.equals(session.date))).go();

        // Insert your hangout expenses
        for (final exp in yourHangoutExpenses) {
          await _db.into(_db.expensesTable).insert(
                exp.toCompanion(),
                mode: drift.InsertMode.insertOrReplace,
              );
        }
      }
    });

    // Refresh records provider
    await _ref.read(recordsProvider.notifier).loadRecords();
  }

  Future<HangoutSessionModel> createSession({
    required String title,
    required String date,
    required List<String> people,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final effectivePeople = List<String>.from(people);
    if (!effectivePeople.contains('You')) {
      effectivePeople.insert(0, 'You');
    }

    final session = HangoutSessionModel(
      id: id,
      title: title.trim(),
      date: date,
      people: effectivePeople,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
      expenses: const [],
    );

    await _db.into(_db.hangoutSessionsTable).insert(session.toCompanion());
    await loadSessions();
    return session;
  }

  Future<void> updateSession(HangoutSessionModel session) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = session.copyWith(updatedAt: now);
    await (_db.update(_db.hangoutSessionsTable)..where((t) => t.id.equals(session.id))).write(
      updated.toCompanion(),
    );
    await loadSessions();
  }

  Future<void> deleteSession(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.hangoutSessionsTable)..where((t) => t.id.equals(id))).write(
      HangoutSessionsTableCompanion(
        isDeleted: const drift.Value(true),
        updatedAt: drift.Value(now),
      ),
    );
    await loadSessions();
  }

  Future<HangoutExpenseModel> addExpenseToSession({
    required String sessionId,
    required String title,
    required int totalAmount,
    required String paidBy,
    required List<String> participants,
    String splitType = 'equal',
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final n = participants.isNotEmpty ? participants.length : 1;
    final perPerson = totalAmount ~/ n;

    final exp = HangoutExpenseModel(
      id: id,
      sessionId: sessionId,
      title: title.trim(),
      totalAmount: totalAmount,
      perPersonAmount: perPerson,
      paidBy: paidBy,
      splitType: splitType,
      participants: participants,
      timestamp: now,
    );

    await _db.into(_db.hangoutExpensesTable).insert(exp.toCompanion());
    await loadSessions();
    return exp;
  }

  Future<void> deleteExpenseFromSession(String expenseId) async {
    await (_db.delete(_db.hangoutExpensesTable)..where((t) => t.id.equals(expenseId))).go();
    await loadSessions();
  }
}

final hangoutsProvider = StateNotifierProvider<HangoutsNotifier, List<HangoutSessionModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return HangoutsNotifier(db, ref);
});
