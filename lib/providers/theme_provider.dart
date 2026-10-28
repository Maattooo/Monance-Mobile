import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storageService;

  ThemeNotifier(this._storageService)
      : super(_storageService.getThemeMode() == 'light' ? ThemeMode.light : ThemeMode.dark);

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      _storageService.setThemeMode('light');
    } else {
      state = ThemeMode.dark;
      _storageService.setThemeMode('dark');
    }
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _storageService.setThemeMode(mode == ThemeMode.light ? 'light' : 'dark');
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeNotifier(storage);
});
