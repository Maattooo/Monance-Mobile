import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'core/theme/app_theme.dart';
import 'providers/bills_provider.dart';
import 'providers/security_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'services/local_notification_service.dart';
import 'views/main_shell_view.dart';
import 'views/security/pin_lock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  final notifService = LocalNotificationService();
  try {
    await notifService.init();
  } catch (_) {
    // Non-fatal if local notification init fails
  }

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) {
          final isDark = ref.watch(settingsProvider.select((s) => s.themeIsDark));
          return ThemeNotifier(ref, isDark);
        }),
      ],
      child: const MonanceApp(),
    ),
  );
}

class MonanceApp extends ConsumerStatefulWidget {
  const MonanceApp({super.key});

  @override
  ConsumerState<MonanceApp> createState() => _MonanceAppState();
}

class _MonanceAppState extends ConsumerState<MonanceApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billsProvider.notifier).checkAndRolloverBills(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final securityState = ref.watch(securityProvider);

    final Widget home;
    if (!securityState.isInitialized) {
      // Neutral loading screen with NO financial data
      home = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (securityState.isLocked) {
      // PinLockScreen instead of MainShellView (not in Stack/Offstage)
      home = const PinLockScreen();
    } else {
      home = const MainShellView();
    }

    return MaterialApp(
      title: 'Monance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: home,
    );
  }
}
