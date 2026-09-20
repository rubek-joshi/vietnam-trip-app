import 'package:dartz/dartz.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings);
}
