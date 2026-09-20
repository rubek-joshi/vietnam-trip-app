import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vietnam_handbook/features/settings/domain/entities/app_settings.dart';
import 'package:vietnam_handbook/features/settings/domain/repositories/settings_repository.dart';

class SettingsState extends Equatable {
  const SettingsState({this.settings = AppSettings.defaults, this.message});

  final AppSettings settings;
  final String? message;

  ThemeMode get themeMode => switch (settings.themeMode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  SettingsState copyWith({
    AppSettings? settings,
    String? message,
    bool clearMessage = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [settings, message];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  Future<void> load() async {
    final result = await _repository.getSettings();
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (settings) => emit(state.copyWith(settings: settings)),
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) {
    return _persist(state.settings.copyWith(themeMode: mode));
  }

  Future<void> setColorScheme(String colorScheme) {
    return _persist(state.settings.copyWith(colorScheme: colorScheme));
  }

  Future<void> reset() {
    return _persist(AppSettings.defaults);
  }

  Future<void> _persist(AppSettings settings) async {
    if (settings == state.settings) return;
    emit(state.copyWith(settings: settings));
    final result = await _repository.saveSettings(settings);
    result.fold((f) => emit(state.copyWith(message: f.message)), (_) {});
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));
}
