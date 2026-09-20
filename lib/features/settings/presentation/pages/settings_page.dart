import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/widgets/confirm_remove_dialog.dart';
import 'package:vietnam_handbook/features/settings/domain/entities/app_settings.dart';
import 'package:vietnam_handbook/features/settings/presentation/cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
            context.read<SettingsCubit>().clearMessage();
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Appearance', style: theme.textTheme.h4),
              const SizedBox(height: 8),
              ShadCard(
                columnCrossAxisAlignment: CrossAxisAlignment.stretch,
                title: const Text('Theme'),
                description: Text(
                  'Choose light, dark, or follow this device.',
                  style: theme.textTheme.muted,
                ),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: AppThemeMode.values.map((mode) {
                      final meta = _themeMeta(mode);
                      final selected = state.settings.themeMode == mode;
                      return InkWell(
                        onTap: () =>
                            context.read<SettingsCubit>().setThemeMode(mode),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                selected
                                    ? LucideIcons.circleDot
                                    : LucideIcons.circle,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(meta.label),
                                    Text(
                                      meta.sublabel,
                                      style: theme.textTheme.muted,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ShadCard(
                columnCrossAxisAlignment: CrossAxisAlignment.stretch,
                title: const Text('Color scheme'),
                description: Text(
                  'Accent colors used across the app.',
                  style: theme.textTheme.muted,
                ),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ShadSelect<String>(
                    maxHeight: 280,
                    initialValue: state.settings.colorScheme,
                    options: AppSettings.colorSchemes.map(
                      (name) => ShadOption(
                        value: name,
                        child: Text(_capitalize(name)),
                      ),
                    ),
                    selectedOptionBuilder: (context, value) =>
                        Text(_capitalize(value)),
                    onChanged: (value) {
                      if (value == null) return;
                      context.read<SettingsCubit>().setColorScheme(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Data', style: theme.textTheme.h4),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => context.push('/others/rates'),
                borderRadius: BorderRadius.circular(12),
                child: ShadCard(
                  leading: const Icon(LucideIcons.badgeDollarSign),
                  title: const Text('FX rates'),
                  description: Text(
                    'Edit offline USD → NPR / VND conversion rates',
                    style: theme.textTheme.muted,
                  ),
                  trailing: const Icon(LucideIcons.chevronRight),
                ),
              ),
              const SizedBox(height: 24),
              ShadButton.outline(
                width: double.infinity,
                onPressed: () async {
                  final confirmed = await confirmRemove(
                    context,
                    title: 'Reset appearance?',
                    description:
                        'Theme mode and color scheme will return to system and orange.',
                    confirmLabel: 'Reset',
                  );
                  if (confirmed && context.mounted) {
                    await context.read<SettingsCubit>().reset();
                  }
                },
                child: const Text('Reset appearance to defaults'),
              ),
            ],
          );
        },
      ),
    );
  }
}

({String label, String sublabel}) _themeMeta(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.light => (
      label: 'Light',
      sublabel: 'Always use a light appearance',
    ),
    AppThemeMode.dark => (
      label: 'Dark',
      sublabel: 'Always use a dark appearance',
    ),
    AppThemeMode.system => (
      label: 'System',
      sublabel: 'Match this device (default)',
    ),
  };
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
