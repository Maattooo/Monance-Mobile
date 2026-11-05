import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils_ext.dart';
import '../providers/bills_provider.dart';
import '../providers/settings_provider.dart';
import 'analytics/analytics_view.dart';
import 'bills/bills_view.dart';
import 'calendar/calendar_view.dart';
import 'calendar/daily_modal.dart';
import 'dashboard/dashboard_view.dart';
import 'hangouts/hangouts_view.dart';
import 'settings/settings_panel_view.dart';

final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

class MainShellView extends ConsumerWidget {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final selectedIndex = ref.watch(selectedTabIndexProvider);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: colors.bgCard,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Monance',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            Text(
              'Personal Finance Companion',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Toggle Icon Button
          IconButton(
            key: const Key('theme_toggle_button'),
            tooltip: 'Toggle Theme',
            icon: Icon(
              settings.themeIsDark ? Icons.dark_mode : Icons.light_mode,
              color: colors.textPrimary,
            ),
            onPressed: () {
              ref.read(settingsProvider.notifier).toggleTheme();
            },
          ),
          // Privacy Mode Toggle Icon Button
          IconButton(
            key: const Key('privacy_toggle_button'),
            tooltip: 'Toggle Privacy Mode',
            icon: Icon(
              settings.privacyMode ? Icons.visibility_off : Icons.visibility,
              color: colors.textPrimary,
            ),
            onPressed: () {
              ref.read(settingsProvider.notifier).togglePrivacyMode();
            },
          ),
          // Hamburger / Settings Drawer Icon Button
          IconButton(
            key: const Key('menu_button'),
            tooltip: 'Settings',
            icon: Icon(Icons.menu, color: colors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsPanelView(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        key: const Key('main_shell_indexed_stack'),
        index: selectedIndex,
        children: const [
          DashboardView(),
          CalendarView(),
          AnalyticsView(),
          BillsView(),
          HangoutsView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('daily_modal_fab'),
        onPressed: () {
          final todayIso = DateUtilsExt.formatIsoDate(DateTime.now());
          DailyModal.show(context, todayIso);
        },
        backgroundColor: colors.textPrimary,
        foregroundColor: colors.bgPrimary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.borderColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.bgCard,
          elevation: 0,
          currentIndex: selectedIndex,
          selectedItemColor: colors.textPrimary,
          unselectedItemColor: colors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          onTap: (index) {
            ref.read(selectedTabIndexProvider.notifier).state = index;
            if (index == 3) {
              ref.read(billsProvider.notifier).checkAndRolloverBills(DateTime.now());
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Bills',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Hangouts',
            ),
          ],
        ),
      ),
    );
  }
}
