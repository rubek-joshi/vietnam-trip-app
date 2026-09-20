import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/core/storage/hive_boxes.dart';
import 'package:vietnam_handbook/features/settings/domain/entities/app_settings.dart';
import 'package:vietnam_handbook/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._box);

  final Box<dynamic> _box;

  static const _key = 'settings';

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final raw = _box.get(_key);
      if (raw is Map) {
        return Right(AppSettings.fromJson(Map<dynamic, dynamic>.from(raw)));
      }
      return const Right(AppSettings.defaults);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings) async {
    try {
      await _box.put(_key, settings.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

Future<Box<dynamic>> openSettingsBox() =>
    Hive.openBox<dynamic>(HiveBoxes.settings);
