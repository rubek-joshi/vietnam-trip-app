import 'package:equatable/equatable.dart';

enum AppThemeMode { light, dark, system }

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.colorScheme = defaultColorScheme,
  });

  final AppThemeMode themeMode;
  final String colorScheme;

  static const defaultColorScheme = 'zinc';

  static const colorSchemes = [
    'blue',
    'gray',
    'green',
    'neutral',
    'orange',
    'red',
    'rose',
    'slate',
    'stone',
    'violet',
    'yellow',
    'zinc',
  ];

  static const defaults = AppSettings();

  AppSettings copyWith({AppThemeMode? themeMode, String? colorScheme}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'colorScheme': colorScheme,
  };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) {
    final modeName = json['themeMode'] as String?;
    final scheme = json['colorScheme'] as String?;
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (m) => m.name == modeName,
        orElse: () => AppThemeMode.system,
      ),
      colorScheme: (scheme != null && colorSchemes.contains(scheme))
          ? scheme
          : defaultColorScheme,
    );
  }

  @override
  List<Object?> get props => [themeMode, colorScheme];
}
