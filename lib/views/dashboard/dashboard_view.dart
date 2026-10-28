import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/records_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'add_expense_sheet.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final records = ref.watch(recordsProvider);
    final derivedWalletBalance = ref.watch(derivedWalletBalanceProvider);
    final recordsNotifier = ref.read(recordsProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayKey = RecordsNotifier.getTodayKey();
    final todayRecord = records[todayKey] ?? recordsNotifier.getOrCreateRecord(todayKey);

    final remainingAllowance = todayRecord.remainingDailyAllowance;
    final startingAllowance = todayRecord.startingMoney;
    final spentToday = todayRecord.dailyExpensesTotal;

    final allowanceRatio = startingAllowance > 0
        ? (remainingAllowance / startingAllowance).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MONANCE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            Text(
              authState.user?.email ?? 'Logged in',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sync with Cloud Database',
            icon: recordsNotifier.isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_sync_outlined),
            onPressed: () async {
              await ref.read(recordsProvider.notifier).forceResyncFromCloud();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cloud data synced successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(recordsProvider.notifier).forceResyncFromCloud();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Date Title
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Daily Allowance Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Allowance',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: remainingAllowance >= 0
                                ? (isDark ? Colors.green[900]?.withValues(alpha: 0.3) : Colors.green[50])
                                : (isDark ? Colors.red[900]?.withValues(alpha: 0.3) : Colors.red[50]),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            remainingAllowance >= 0 ? 'On Track' : 'Over Budget',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: remainingAllowance >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      CurrencyFormatter.formatFromCents(remainingAllowance),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Starting: ${CurrencyFormatter.formatFromCents(startingAllowance)}  •  Spent: ${CurrencyFormatter.formatFromCents(spentToday)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: allowanceRatio,
                      backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                      color: isDark ? Colors.white : Colors.black,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cash in Wallet Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash in Wallet',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatFromCents(derivedWalletBalance),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.account_balance_wallet,
                      size: 32,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Today's Activity Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Expenses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${todayRecord.expenses.length} item${todayRecord.expenses.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Expenses List
            if (todayRecord.expenses.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: isDark ? Colors.grey[700] : Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No expenses logged today',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + Add Expense below to start tracking',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              )
            else
              ...todayRecord.expenses.map((exp) {
                final isDaily = exp.deductionType == 'daily';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                      child: Icon(
                        isDaily ? Icons.today : Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    title: Text(
                      exp.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          exp.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isDaily ? 'Allowance' : 'Wallet',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '-${CurrencyFormatter.formatFromCents(exp.amount)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red[400],
                          onPressed: () {
                            ref.read(recordsProvider.notifier).deleteExpense(todayKey, exp.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 80), // Padding for floating button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => AddExpenseSheet(date: todayKey),
          );
        },
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
