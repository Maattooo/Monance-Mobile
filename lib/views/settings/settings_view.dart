import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/storage_provider.dart';
import '../../core/utils/currency_formatter.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  void _showEditAllowanceDialog(BuildContext context, WidgetRef ref, int current) {
    final controller = TextEditingController(
      text: CurrencyFormatter.centsToPesos(current).toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Default Daily Allowance'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '₱ ',
            labelText: 'Allowance per day',
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
              ref.read(settingsProvider.notifier).updateAllowance(cents);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showServerUrlDialog(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    final controller = TextEditingController(text: storage.getServerUrl());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Connection URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '• Android Emulator: http://10.0.2.2:3000\n• Physical Phone: http://<YOUR_COMPUTER_IP>:3000\n• Hosted: https://your-domain.com',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                await storage.setServerUrl(newUrl);
                ref.read(apiClientProvider).updateBaseUrl(newUrl);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedColor = '#3b82f6';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                ref.read(settingsProvider.notifier).addCategory(name, selectedColor);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeProvider);
    final storage = ref.watch(storageServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Account Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    radius: 24,
                    child: Icon(
                      Icons.person_outline,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.email ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'MongoDB Cloud Connected',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preferences Section
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(themeMode == ThemeMode.dark ? 'Monochrome Dark' : 'Monochrome Light'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.attach_money_outlined),
                  title: const Text('Default Daily Allowance'),
                  subtitle: Text(CurrencyFormatter.formatFromCents(settings.defaultAllowance)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditAllowanceDialog(context, ref, settings.defaultAllowance),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: const Text('Backend Server URL'),
                  subtitle: Text(storage.getServerUrl()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showServerUrlDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Categories Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Expense Categories',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                onPressed: () => _showAddCategoryDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: settings.categories.map((cat) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: cat.color,
                      radius: 5,
                    ),
                    label: Text(cat.name),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      ref.read(settingsProvider.notifier).deleteCategory(cat.name);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              foregroundColor: isDark ? Colors.white : Colors.black,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
