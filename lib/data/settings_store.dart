import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias persistentes (accesibilidad y TTS).
class AppSettings {
  const AppSettings({
    this.reduceStimuli = false,
    this.highContrast = false,
    this.fontSize = 20,
    this.extraLargeText = false,
    this.ttsSlow = false,
    this.ttsVoiceId,
  });

  final bool reduceStimuli;
  final bool highContrast;
  /// Tamaño base de texto del cuerpo (pt lógicos aproximados).
  final double fontSize;
  final bool extraLargeText;
  final bool ttsSlow;
  final String? ttsVoiceId;

  double get effectiveBodySize => extraLargeText ? fontSize + 4 : fontSize;

  AppSettings copyWith({
    bool? reduceStimuli,
    bool? highContrast,
    double? fontSize,
    bool? extraLargeText,
    bool? ttsSlow,
    String? ttsVoiceId,
    bool clearVoiceId = false,
  }) {
    return AppSettings(
      reduceStimuli: reduceStimuli ?? this.reduceStimuli,
      highContrast: highContrast ?? this.highContrast,
      fontSize: fontSize ?? this.fontSize,
      extraLargeText: extraLargeText ?? this.extraLargeText,
      ttsSlow: ttsSlow ?? this.ttsSlow,
      ttsVoiceId: clearVoiceId ? null : (ttsVoiceId ?? this.ttsVoiceId),
    );
  }
}

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kReduce = 'reduce_stimuli';
  static const _kContrast = 'high_contrast';
  static const _kFont = 'font_size';
  static const _kExtraLarge = 'extra_large_text';
  static const _kTtsSlow = 'tts_slow';
  static const _kTtsVoice = 'tts_voice_id';

  AppSettings load() {
    return AppSettings(
      reduceStimuli: _prefs.getBool(_kReduce) ?? false,
      highContrast: _prefs.getBool(_kContrast) ?? false,
      fontSize: _prefs.getDouble(_kFont) ?? 20,
      extraLargeText: _prefs.getBool(_kExtraLarge) ?? false,
      ttsSlow: _prefs.getBool(_kTtsSlow) ?? false,
      ttsVoiceId: _prefs.getString(_kTtsVoice),
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setBool(_kReduce, s.reduceStimuli);
    await _prefs.setBool(_kContrast, s.highContrast);
    await _prefs.setDouble(_kFont, s.fontSize);
    await _prefs.setBool(_kExtraLarge, s.extraLargeText);
    await _prefs.setBool(_kTtsSlow, s.ttsSlow);
    if (s.ttsVoiceId == null || s.ttsVoiceId!.isEmpty) {
      await _prefs.remove(_kTtsVoice);
    } else {
      await _prefs.setString(_kTtsVoice, s.ttsVoiceId!);
    }
  }
}
