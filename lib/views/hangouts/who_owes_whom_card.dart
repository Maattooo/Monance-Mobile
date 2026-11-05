import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hangout_session_model.dart';
import '../../providers/hangouts_provider.dart';
import '../../providers/settings_provider.dart';

class WhoOwesWhomCard extends ConsumerWidget {
  final HangoutSessionModel session;

  const WhoOwesWhomCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final settlementLines =
        HangoutsNotifier.calculateWhoOwesWhom(session, settings.currencySymbol);

    return Container(
      key: const Key('who_owes_whom_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border.all(color: colors.borderColor, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz, size: 18, color: colors.colorInfo),
              const SizedBox(width: 8),
              Text(
                'Who Owes Whom',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (settlementLines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'All settled!',
                key: const Key('all_settled_text'),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.colorSuccess,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: settlementLines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final line = settlementLines[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.bgSecondary,
                    border: Border.all(color: colors.borderColor, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    line,
                    key: Key('settlement_line_$index'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

