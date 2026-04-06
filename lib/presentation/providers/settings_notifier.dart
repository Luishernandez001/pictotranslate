import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings_store.dart';
import 'app_providers.dart';

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(ref.watch(settingsRepositoryProvider));
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._repo) : super(_repo.load());

  final SettingsRepository _repo;

  Future<void> update(AppSettings next) async {
    state = next;
    await _repo.save(next);
  }

  Future<void> setReduceStimuli(bool v) => update(state.copyWith(reduceStimuli: v));
  Future<void> setHighContrast(bool v) => update(state.copyWith(highContrast: v));
  Future<void> setFontSize(double v) => update(state.copyWith(fontSize: v.clamp(18, 26)));
  Future<void> setExtraLargeText(bool v) => update(state.copyWith(extraLargeText: v));
  Future<void> setTtsSlow(bool v) => update(state.copyWith(ttsSlow: v));
  Future<void> setTtsVoice(String? id) => update(
        state.copyWith(ttsVoiceId: id, clearVoiceId: id == null || id.isEmpty),
      );
}
