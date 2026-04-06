import 'package:flutter_tts/flutter_tts.dart';

import '../../data/settings_store.dart';

/// Text-to-Speech en inglés; solo se invoca desde el botón (sin autoplay).
class TtsService {
  TtsService() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  Future<void> ensureInitialized() async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  Future<void> applySettings(AppSettings settings) async {
    await ensureInitialized();
    await _tts.setSpeechRate(settings.ttsSlow ? 0.32 : 0.48);
    if (settings.ttsVoiceId != null && settings.ttsVoiceId!.isNotEmpty) {
      await _tts.setVoice({'name': settings.ttsVoiceId!, 'locale': 'en-US'});
    } else {
      await _tts.setLanguage('en-US');
    }
  }

  Future<void> speak(String text) async {
    await ensureInitialized();
    if (text.trim().isEmpty) return;
    await _tts.speak(text.trim());
  }

  Future<void> stop() => _tts.stop();

  Future<List<Map<String, String>>> getEnglishVoices() async {
    await ensureInitialized();
    final voices = await _tts.getVoices;
    if (voices is! List) return [];
    final out = <Map<String, String>>[];
    for (final v in voices) {
      if (v is! Map) continue;
      final locale = (v['locale'] ?? '').toString().toLowerCase();
      if (!locale.startsWith('en')) continue;
      final name = (v['name'] ?? '').toString();
      if (name.isEmpty) continue;
      out.add({'name': name, 'locale': locale});
    }
    return out;
  }
}
