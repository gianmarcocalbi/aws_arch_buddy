import 'dart:convert';

import 'package:a2f_sdk/a2f_sdk.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';

import '../../model/app_settings.gen.dart';

part 'settings_repository_state.dart';

const _settingsKey = '@';

/// Singleton repository for [AppSettings].
class SettingsRepository
    extends SingletonRepository<AppSettings, SettingsRepositoryState> {
  late final Box<String> _box;

  SettingsRepository();

  /// Returns the instance of the repository.
  static SettingsRepository get I => GetIt.I.get<SettingsRepository>();

  Future<void> _save(AppSettings settings) async {
    cache.save(settings);
    await _box.put(_settingsKey, jsonEncode(settings.toJson()));
  }

  /// Loads the state of the repository from the storage.
  Future<void> load() async {
    logger.i('Loading SettingsRepository...');
    _box = await Hive.openBox('settings');
    final strSettings = _box.get(_settingsKey);

    if (strSettings != null) {
      try {
        logger.v('Loading settings from Hive storage...');
        final settings = AppSettings.fromJson(
          jsonDecode(strSettings) as Map<String, dynamic>,
        );
        await _save(settings);
        emit(SettingsRepositoryLoaded(settings));
        return;
      } catch (e, s) {
        logger.e('Error loading services from remote storage.', e, s);
      }
    }

    logger.i(
      'Settings could not be loaded or not found. Using default settings.',
    );
    await _save(const AppSettings.initial());
    emit(SettingsRepositoryLoaded(getOrThrow()));
  }

  /// Updates the settings in the repository.
  Future<AppSettings> update({
    int? serviceVersion,
  }) async {
    final previous = cache.getOrThrow();
    final updated = previous.copyWith(
      serviceVersion: serviceVersion,
    );
    await _save(updated);
    emit(SettingsRepositoryUpdated(previous, updated));
    return updated;
  }
}
