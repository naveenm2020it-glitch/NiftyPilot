import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/apple_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _setPinDialog(BuildContext context, AppStateProvider state) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set 4-Digit PIN'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: '••••'),
        ),
        actions: [
          if (state.settings.hasPin)
            TextButton(
              onPressed: () async {
                await state.updateSettings(
                  state.settings.copyWith(clearPin: true, biometricEnabled: false),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Remove PIN'),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().length == 4) {
                await state.updateSettings(state.settings.copyWith(appPin: ctrl.text.trim()));
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = AppLocalizations.of(context);
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          AppleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tr('profile_name'), style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: settings.userName,
                  decoration: const InputDecoration(hintText: 'Your name'),
                  onChanged: (v) => state.updateSettings(settings.copyWith(userName: v.trim())),
                ),
                const SizedBox(height: 14),
                Text('${l10n.tr('water_target')}: ${settings.dailyWaterTargetMl} ml',
                    style: Theme.of(context).textTheme.labelMedium),
                Slider(
                  value: settings.dailyWaterTargetMl.toDouble().clamp(1000, 5000),
                  min: 1000,
                  max: 5000,
                  divisions: 16,
                  activeColor: AppColors.emeraldPrimary,
                  onChanged: (v) =>
                      state.updateSettings(settings.copyWith(dailyWaterTargetMl: v.round())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tr('appearance'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(value: ThemeMode.light, label: Text(l10n.tr('theme_light'))),
                    ButtonSegment(value: ThemeMode.dark, label: Text(l10n.tr('theme_dark'))),
                    ButtonSegment(value: ThemeMode.system, label: Text(l10n.tr('theme_system'))),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) =>
                      state.updateSettings(settings.copyWith(themeMode: s.first)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tr('language'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('English')),
                    ButtonSegment(value: 'ta', label: Text('தமிழ் (Tamil)')),
                  ],
                  selected: {settings.languageCode},
                  onSelectionChanged: (s) =>
                      state.updateSettings(settings.copyWith(languageCode: s.first)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppleCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tr('enable_notifications')),
                  value: settings.notificationsEnabled,
                  activeColor: AppColors.emeraldPrimary,
                  onChanged: (v) =>
                      state.updateSettings(settings.copyWith(notificationsEnabled: v)),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tr('app_pin')),
                  subtitle: Text(settings.hasPin ? 'Enabled (••••)' : 'Off'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _setPinDialog(context, state),
                ),
                if (settings.hasPin) ...[
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.tr('biometric_lock')),
                    value: settings.biometricEnabled,
                    activeColor: AppColors.emeraldPrimary,
                    onChanged: (v) =>
                        state.updateSettings(settings.copyWith(biometricEnabled: v)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppleCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.upload_file_rounded, color: AppColors.emeraldPrimary),
                  title: Text(l10n.tr('export_backup')),
                  onTap: () async {
                    final path = await state.backupService.exportBackupAndShare();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Backup saved: $path')),
                      );
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_rounded, color: AppColors.terracotta),
                  title: Text(l10n.tr('import_backup')),
                  onTap: () async {
                    final ok = await state.backupService.importBackupFromFile();
                    if (ok) {
                      await state.reloadAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup restored successfully')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppleCard(
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: AppColors.emeraldPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${AppConstants.appName} v${AppConstants.appVersion}',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(AppConstants.packageId, style: Theme.of(context).textTheme.bodySmall),
                    ],
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
