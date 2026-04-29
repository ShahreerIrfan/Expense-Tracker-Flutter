import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/security/secure_storage.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (user?.email != null)
                        Text(user!.email!,
                            style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editProfile(context, ref, user),
                ),
              ],
            ),
          ),

          // Appearance
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: Text(themeMode == ThemeMode.dark
                ? 'Dark'
                : themeMode == ThemeMode.light
                    ? 'Light'
                    : 'System'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(locale.languageCode == 'bn' ? 'বাংলা' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, ref, locale),
          ),

          // Currency
          _SectionHeader(title: 'Finance'),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Currency'),
            subtitle: Text(user?.currency ?? AppConstants.defaultCurrency),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyPicker(context, ref),
          ),

          // Security
          _SectionHeader(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(user?.pin != null && user!.pin!.isNotEmpty
                ? 'Change PIN'
                : 'Set PIN'),
            subtitle: Text(user?.pin != null && user!.pin!.isNotEmpty
                ? 'PIN protected'
                : 'Tap to set up PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changePin(context, ref, hasPin: user?.pin != null && user!.pin!.isNotEmpty),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Lock'),
            subtitle: const Text('Use fingerprint or face to unlock'),
            value: user?.biometricEnabled ?? false,
            onChanged: user == null
                ? null
                : (v) async {
                    if (v) {
                      final available = await AuthService.isBiometricAvailable();
                      if (!available && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Biometrics not available on this device')),
                        );
                        return;
                      }
                      final ok = await AuthService.authenticateWithBiometrics();
                      if (!ok) return;
                    }
                    final updated = user.copyWith(biometricEnabled: v);
                    await ref.read(currentUserProvider.notifier).updateUser(updated);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(v
                              ? 'Biometric lock enabled'
                              : 'Biometric lock disabled'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
          ),

          // Data
          _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.cloud_sync, color: AppColors.primary),
            title: const Text('Cloud Sync'),
            subtitle: const Text('PostgreSQL backup & restore'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/cloud-sync'),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Manage Accounts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/accounts'),
          ),

          // About
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.pop(ctx);
            },
            child: const Row(children: [
              Icon(Icons.light_mode),
              SizedBox(width: 12),
              Text('Light'),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.pop(ctx);
            },
            child: const Row(children: [
              Icon(Icons.dark_mode),
              SizedBox(width: 12),
              Text('Dark'),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
              Navigator.pop(ctx);
            },
            child: const Row(children: [
              Icon(Icons.brightness_auto),
              SizedBox(width: 12),
              Text('System'),
            ]),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(
      BuildContext context, WidgetRef ref, Locale locale) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose Language'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref
                  .read(localeProvider.notifier)
                  .setLocale(const Locale('en'));
              Navigator.pop(ctx);
            },
            child: Text('English',
                style: TextStyle(
                    fontWeight: locale.languageCode == 'en'
                        ? FontWeight.bold
                        : null)),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref
                  .read(localeProvider.notifier)
                  .setLocale(const Locale('bn'));
              Navigator.pop(ctx);
            },
            child: Text('বাংলা',
                style: TextStyle(
                    fontWeight: locale.languageCode == 'bn'
                        ? FontWeight.bold
                        : null)),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose Currency'),
        children: AppConstants.currencySymbols.entries
            .map((e) => SimpleDialogOption(
                  onPressed: () {
                    // Update user currency
                    Navigator.pop(ctx);
                  },
                  child: Text('${e.key} (${e.value})'),
                ))
            .toList(),
      ),
    );
  }

  void _changePin(BuildContext context, WidgetRef ref, {required bool hasPin}) {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hasPin ? 'Change PIN' : 'Set PIN'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasPin)
                TextFormField(
                  controller: oldPinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Current PIN'),
                  validator: (v) =>
                      v == null || v.length < 4 ? '4-digit PIN required' : null,
                ),
              TextFormField(
                controller: newPinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New PIN'),
                validator: (v) =>
                    v == null || v.length < 4 ? '4-digit PIN required' : null,
              ),
              TextFormField(
                controller: confirmPinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Confirm New PIN'),
                validator: (v) {
                  if (v == null || v.length < 4) return '4-digit PIN required';
                  if (v != newPinController.text) return 'PINs do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final user = ref.read(currentUserProvider);
              if (user == null) return;

              if (hasPin) {
                final valid = await SecureStorageService.verifyPin(
                    user.id!, oldPinController.text);
                if (!valid) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect current PIN'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                  return;
                }
              }

              await SecureStorageService.savePin(user.id!, newPinController.text);
              // Persist non-empty marker to user.pin so UI knows PIN exists
              final updated = user.copyWith(pin: 'set');
              await ref.read(currentUserProvider.notifier).updateUser(updated);

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(hasPin ? 'PIN changed successfully' : 'PIN set successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(hasPin ? 'Change' : 'Set PIN'),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, WidgetRef ref, user) {
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name cannot be empty' : null,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final updated = user.copyWith(name: nameCtrl.text.trim());
              await ref.read(currentUserProvider.notifier).updateUser(updated);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
