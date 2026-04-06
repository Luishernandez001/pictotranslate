import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/arasaac_api_service.dart';
import '../../data/search_history_repository.dart';
import '../../data/settings_store.dart';
import '../services/tts_service.dart';

/// Inyectado desde [main] con SharedPreferences real.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((ref) {
  return SearchHistoryRepository(ref.watch(sharedPreferencesProvider));
});

final arasaacDioProvider = Provider<Dio>((ref) => createArasaacDio());

final arasaacApiServiceProvider = Provider<ArasaacApiService>((ref) {
  return ArasaacApiService(ref.watch(arasaacDioProvider));
});

final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());
