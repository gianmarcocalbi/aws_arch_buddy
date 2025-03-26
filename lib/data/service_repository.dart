import 'dart:convert';
import 'dart:math';

import 'package:a2f_sdk/a2f_sdk.dart';
import 'package:flext_core/flext_core.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import '../model/model.dart';

part 'service_repository_state.dart';

final _rnd = Random();

/// Repository for AWS [AwsServiceQnaHelper].
///
/// The key is the name of the service.
/// The entity is [AwsServiceQnaHelper].
class ServiceRepository
    extends Repository<String, AwsServiceQnaHelper, ServiceRepositoryState> {
  late final Box<String> _box;

  ServiceRepository();

  /// Returns the instance of the repository.
  static ServiceRepository get I => GetIt.I.get<ServiceRepository>();

  /// Gets all enabled items.
  List<AwsServiceQnaHelper> get enabledItems =>
      cache.values.where((el) => el.isEnabled).toList();

  /// Gets all disabled items.
  List<AwsServiceQnaHelper> get disabledItems =>
      cache.values.where((el) => !el.isEnabled).toList();

  /// Gets an helper by [AwsService].
  AwsServiceQnaHelper getByService(AwsService service) =>
      getOrThrow(service.name);

  /// Returns a random helper from the repository.
  AwsServiceQnaHelper getRandom() {
    final index = _rnd.nextInt(cache.entries.length);
    return cache.values.elementAt(index);
  }

  Future<void> _save(AwsServiceQnaHelper helper) async {
    cache.save(helper.service.name, helper);
    await _box.put(helper.service.name, jsonEncode(helper.toJson()));
  }

  Future<void> _saveAllToBox() async {
    await _box.putAll(
      cache.entries
          .map((e) => MapEntry(e.key, jsonEncode(e.value.toJson())))
          .let(Map.fromEntries),
    );
  }

  /// Resets the statistics for all helpers.
  Future<void> resetStats() async {
    for (final helper in cache.values) {
      await _save(
        helper.copyWith(
          stats: const AwsServiceAnswerStats.zero(),
          reverseStats: const AwsServiceAnswerStats.zero(),
        ),
      );
    }
    // Emit like the whole collection has been re-fetched.
    emit(ServiceRepositoryCollectionFetched(cache.values));
  }

  /// Forces to clear the box (persistent storage).
  Future<void> forceClearBox() async {
    await _box.clear();
    await _saveAllToBox();
    logger.i('Box cleared.');
  }

  /// Loads the state of the repository from the storage.
  Future<void> load() async {
    _box = await Hive.openBox('services');
    var servicesYaml =
        loadYaml(await rootBundle.loadString('assets/services.yaml'))
            as YamlMap;

    try {
      final remoteServices = await http
          .get(
            Uri.parse(
              'https://raw.githubusercontent.com/gianmarcocalbi/aws_arch_buddy/refs/heads/main/assets/services.yaml',
            ),
          )
          .orNullOnError()
          .then(
            (value) => value == null ? null : loadYaml(value.body) as YamlMap,
          );
      if (remoteServices != null &&
          (servicesYaml['version'] as int) <
              (remoteServices['version'] as int)) {
        servicesYaml = remoteServices;
      }
    } catch (e, s) {
      logger.e('Error loading services from remote storage.', e, s);
    }
    final servicesFromYaml = (servicesYaml['services'] as YamlMap)
        .entries
        .toList()
        .map(
          (el) => AwsService(
            name: el.key as String,
            description: el.value as String,
          ),
        )
        .toList();
    var savedServices = <AwsServiceQnaHelper>[];
    try {
      final tmp = _box.values
          .cast<String>()
          .map((e) => AwsServiceQnaHelper.fromJson(jsonDecode(e) as Json));
      savedServices = tmp.toList();
      // Catch errors and exceptions
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      logger.e(
        'Error loading services from Hive storage.',
        e,
        s,
      );
    }
    cache.saveAll({
      for (final serviceFromYaml in servicesFromYaml)
        serviceFromYaml.name: savedServices.firstWhere(
          (el) => el.service.name == serviceFromYaml.name,
          orElse: () => AwsServiceQnaHelper(
            service: serviceFromYaml,
            isEnabled: true,
            isFlagged: false,
            stats: const AwsServiceAnswerStats.zero(),
            reverseStats: const AwsServiceAnswerStats.zero(),
          ),
        ),
    });
    await _saveAllToBox();
    emit(ServiceRepositoryCollectionFetched(cache.values));
  }

  /// Answers the question for the [service] and saves the change to the
  /// storage.
  Future<void> answer({
    required AwsService service,
    required bool isReversed,
    required bool isCorrect,
  }) async {
    final helper = getOrThrow(service.name);
    final newHelper = helper.copyWith(
      reverseStats: isReversed
          ? helper.reverseStats.copyWith(
              questionCount: helper.reverseStats.questionCount + 1,
              correctCount:
                  helper.reverseStats.correctCount + (isCorrect ? 1 : 0),
            )
          : helper.reverseStats,
      stats: !isReversed
          ? helper.stats.copyWith(
              questionCount: helper.stats.questionCount + 1,
              correctCount: helper.stats.correctCount + (isCorrect ? 1 : 0),
            )
          : helper.stats,
    );
    await _save(newHelper);
    emit(ServiceRepositoryItemUpdated(helper, newHelper));
  }

  /// Toggles the service and saves the change to the storage.
  Future<void> toggle(AwsService service, {required bool isEnabled}) async {
    final helper = getOrThrow(service.name);
    final newHelper = helper.copyWith(isEnabled: isEnabled);
    await _save(newHelper);
    emit(ServiceRepositoryItemUpdated(helper, newHelper));
  }

  /// Disables the [service] and saves the change to the storage.
  Future<void> disable(AwsService service) => toggle(service, isEnabled: false);

  /// Enables the [service] and saves the change to the storage.
  Future<void> enable(AwsService service) => toggle(service, isEnabled: true);

  /// Flags the [service] and saves the change to the storage.
  Future<void> flag(AwsService service, {required bool isFlagged}) async {
    final helper = getOrThrow(service.name);
    final newHelper = helper.copyWith(isFlagged: isFlagged);
    await _save(newHelper);
    emit(ServiceRepositoryItemUpdated(helper, newHelper));
  }
}
