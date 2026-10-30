import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeNotifier(this._ref, bool initialIsDark)
      : super(initialIsDark ? ThemeMode.dark : ThemeMode.light);

  void updateTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    await _ref.read(settingsProvider.notifier).toggleTheme();
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _ref.read(settingsProvider.notifier).toggleTheme(mode == ThemeMode.dark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final isDark = ref.watch(settingsProvider.select((s) => s.themeIsDark));
  final notifier = ThemeNotifier(ref, isDark);
  ref.listen<bool>(settingsProvider.select((s) => s.themeIsDark), (_, next) {
    notifier.updateTheme(next);
  });
  return notifier;
});
