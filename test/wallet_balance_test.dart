import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/models/expense_model.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';

void main() {
  group('test/wallet_balance_test.dart (AUDIT-001 & AUDIT-002 Verification)', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      // Wait for initial async loads
      await container.read(settingsProvider.notifier).loadSettings();
      await container.read(recordsProvider.notifier).loadRecords();
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('Invariant base balance on allowance day (AUDIT-001)', () async {
      final settingsNotifier = container.read(settingsProvider.notifier);
      final recordsNotifier = container.read(recordsProvider.notifier);

      // Initialize currentBalance = 10000 (cents), startingMoney = 5000 on '2026-09-06'
      await settingsNotifier.updateCurrentBalance(10000);
      await recordsNotifier.updateStartingMoney('2026-09-06', 5000);

      expect(container.read(settingsProvider).currentBalance, equals(10000));
      expect(container.read(derivedWalletBalanceProvider), equals(10000));

      // Add 'allowance' expense of 2000
      await recordsNotifier.addExpense(
        date: '2026-09-06',
        amount: 2000,
        title: 'Lunch',
        category: 'Food',
        deductFrom: 'allowance',
      );

      // Verify: derivedWalletBalance == 10000, currentBalance == 10000, remainingAllowance == 3000
      expect(container.read(derivedWalletBalanceProvider), equals(10000));
      expect(container.read(settingsProvider).currentBalance, equals(10000));
      final recordAfterFirstExp = container.read(recordsProvider)['2026-09-06']!;
      expect(recordAfterFirstExp.remainingAllowance, equals(3000));

      // Add 'balance' expense of 2500
      await recordsNotifier.addExpense(
        date: '2026-09-06',
        amount: 2500,
        title: 'Books',
        category: 'Study',
        deductFrom: 'balance',
      );

      // Verify: derivedWalletBalance == 7500, currentBalance == 10000, remainingAllowance == 3000
      expect(container.read(derivedWalletBalanceProvider), equals(7500));
      expect(container.read(settingsProvider).currentBalance, equals(10000));
      final recordAfterSecondExp = container.read(recordsProvider)['2026-09-06']!;
      expect(recordAfterSecondExp.remainingAllowance, equals(3000));

      // Delete 'balance' expense
      final balanceExp = recordAfterSecondExp.expenses.firstWhere((e) => e.deductFrom == 'balance');
      await recordsNotifier.deleteExpense('2026-09-06', balanceExp.id);

      // Verify: derivedWalletBalance == 10000, currentBalance == 10000
      expect(container.read(derivedWalletBalanceProvider), equals(10000));
      expect(container.read(settingsProvider).currentBalance, equals(10000));
    });

    test('Non-allowance / rest day deduction', () async {
      final settingsNotifier = container.read(settingsProvider.notifier);
      final recordsNotifier = container.read(recordsProvider.notifier);

      // Initialize base balance = 10000
      await settingsNotifier.updateCurrentBalance(10000);

      // Initialize '2026-09-08' with startingMoney = 0 (rest day)
      await recordsNotifier.updateStartingMoney('2026-09-08', 0);

      // Add 'allowance' expense of 1500 and 'balance' expense of 1000
      await recordsNotifier.addExpense(
        date: '2026-09-08',
        amount: 1500,
        title: 'Sunday Coffee',
        category: 'Food',
        deductFrom: 'allowance',
      );
      await recordsNotifier.addExpense(
        date: '2026-09-08',
        amount: 1000,
        title: 'Snack',
        category: 'Food',
        deductFrom: 'balance',
      );

      // On a rest day (startingMoney <= 0), ALL expenses deduct from wallet balance
      // derivedWalletBalance == 10000 - 1500 - 1000 = 7500
      expect(container.read(derivedWalletBalanceProvider), equals(7500));
      expect(container.read(settingsProvider).currentBalance, equals(10000));

      // Clear / delete day (isDeleted = true)
      await recordsNotifier.clearDay('2026-09-08');

      // Verify: derivedWalletBalance == 10000, currentBalance == 10000
      expect(container.read(derivedWalletBalanceProvider), equals(10000));
      expect(container.read(settingsProvider).currentBalance, equals(10000));
    });

    test('AUDIT-002 backward-compatible deserialization of legacy deduction types', () {
      final expDaily = ExpenseModel.fromJson({
        'id': 'exp-1',
        'title': 'Bus fare',
        'amount': 2500,
        'deductionType': 'daily',
      });
      expect(expDaily.deductFrom, equals('allowance'));
      expect(expDaily.deductionType, equals('daily'));

      final expWallet = ExpenseModel.fromJson({
        'id': 'exp-2',
        'title': 'Jeans',
        'amount': 8000,
        'deductionType': 'wallet',
      });
      expect(expWallet.deductFrom, equals('balance'));
      expect(expWallet.deductionType, equals('wallet'));

      final expDeductDaily = ExpenseModel.fromJson({
        'id': 'exp-3',
        'title': 'Coffee',
        'amount': 1500,
        'deductFrom': 'daily',
      });
      expect(expDeductDaily.deductFrom, equals('allowance'));

      final expDeductWallet = ExpenseModel.fromJson({
        'id': 'exp-4',
        'title': 'Dinner',
        'amount': 3500,
        'deductFrom': 'wallet',
      });
      expect(expDeductWallet.deductFrom, equals('balance'));
    });

    test('Adversarial: Editing expense deduction type updates derivedWalletBalance dynamically', () async {
      final settingsNotifier = container.read(settingsProvider.notifier);
      final recordsNotifier = container.read(recordsProvider.notifier);

      await settingsNotifier.updateCurrentBalance(10000);
      await recordsNotifier.updateStartingMoney('2026-09-10', 5000);

      await recordsNotifier.addExpense(
        date: '2026-09-10',
        amount: 2000,
        title: 'Taxi',
        category: 'Transport',
        deductFrom: 'allowance',
      );

      // Allowance expense does not deduct from wallet on allowance day
      expect(container.read(derivedWalletBalanceProvider), equals(10000));

      final exp = container.read(recordsProvider)['2026-09-10']!.expenses.first;

      // Edit expense to be deducted from balance instead
      await recordsNotifier.updateExpense(
        date: '2026-09-10',
        expense: exp.copyWith(deductFrom: 'balance'),
      );

      // Now it deducts 2000 from wallet
      expect(container.read(derivedWalletBalanceProvider), equals(8000));
      expect(container.read(settingsProvider).currentBalance, equals(10000));
    });

    test('Adversarial: Negative derived wallet balance when deductions exceed currentBalance', () async {
      final settingsNotifier = container.read(settingsProvider.notifier);
      final recordsNotifier = container.read(recordsProvider.notifier);

      await settingsNotifier.updateCurrentBalance(2000);
      await recordsNotifier.updateStartingMoney('2026-09-11', 0); // rest day

      await recordsNotifier.addExpense(
        date: '2026-09-11',
        amount: 3500,
        title: 'Emergency Medical',
        category: 'Other',
        deductFrom: 'allowance',
      );

      // Total balance deductions = 3500, base balance = 2000 -> -1500
      expect(container.read(derivedWalletBalanceProvider), equals(-1500));
      expect(container.read(settingsProvider).currentBalance, equals(2000));
    });
  });
}
