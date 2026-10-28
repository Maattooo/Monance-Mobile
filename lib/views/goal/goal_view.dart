import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/records_provider.dart';
import '../../core/utils/currency_formatter.dart';

class GoalView extends ConsumerWidget {
  const GoalView({super.key});

  void _showEditGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final controller = TextEditingController(
      text: CurrencyFormatter.centsToPesos(currentGoal).toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Savings Goal'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '₱ ',
            labelText: 'Target Goal Amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pesos = double.tryParse(controller.text.trim()) ?? 0.0;
              final cents = CurrencyFormatter.pesosToCents(pesos);
              ref.read(settingsProvider.notifier).updateGoalAmount(cents);
              Navigator.pop(ctx);
            },
            child: const Text('Save Goal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final records = ref.watch(recordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate total accumulated savings:
    // Sum of remaining allowances across active daily records
    int accumulatedSavings = 0;
    int activeDays = 0;

    records.forEach((key, record) {
      if (!record.isDeleted) {
        accumulatedSavings += record.remainingDailyAllowance;
        activeDays++;
      }
    });

    final targetGoal = settings.goalAmount;
    final progressRatio = targetGoal > 0
        ? (accumulatedSavings / targetGoal).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progressRatio * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Savings Goal Tracker',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Goal',
            onPressed: () => _showEditGoalDialog(context, ref, targetGoal),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Hero Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Accumulated Savings',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.formatFromCents(accumulatedSavings),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Target Goal: ${CurrencyFormatter.formatFromCents(targetGoal)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress Bar
                  LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 12,
                    backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$percent% Achieved',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text(
                        targetGoal > accumulatedSavings
                            ? '${CurrencyFormatter.formatFromCents(targetGoal - accumulatedSavings)} to go'
                            : 'Goal Reached! 🎉',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Days Tracked',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$activeDays',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avg Saved / Day',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeDays > 0
                              ? CurrencyFormatter.formatCompactFromCents(accumulatedSavings ~/ activeDays)
                              : '₱0',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Information Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your savings automatically compute from unspent daily allowances across all tracked days. Staying under your daily budget pushes you closer to your goal.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
