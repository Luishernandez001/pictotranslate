import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/navigation/tea_routes.dart';
import '../../data/settings_store.dart';
import '../providers/app_providers.dart';
import '../providers/home_search_notifier.dart';
import '../providers/keywords_provider.dart';
import '../providers/search_history_provider.dart';
import '../providers/settings_notifier.dart';
import '../widgets/pictogram_result_card.dart';
import '../widgets/voice_search_button.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<String> _localSuggestions = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _hintFor(String language) {
    switch (language) {
      case 'es':
        return 'Ejemplo: manzana';
      case 'fr':
        return 'Exemple : pomme';
      default:
        return 'Example: apple';
    }
  }

  String _promptFor(String language) {
    switch (language) {
      case 'es':
        return 'Escribe una palabra en español y pulsa Buscar.';
      case 'fr':
        return 'Écris un mot en français puis appuie sur Rechercher.';
      default:
        return 'Type an English word and press Search.';
    }
  }

  void _onSearchTextChanged(String value, AppSettings settings, String language) {
    _debounce?.cancel();
    ref.read(homeSearchProvider.notifier).setQuery(value);
    _debounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      final keywordsAsync = ref.read(keywordsProvider(language));
      final list = keywordsAsync.valueOrNull;
      if (list == null) {
        setState(() => _localSuggestions = []);
        return;
      }
      final sug = ref.read(homeSearchProvider.notifier).suggestFor(value, list);
      setState(() => _localSuggestions = sug);
    });
  }

  /// Rellena el campo de texto con el resultado parcial de voz (tiempo real).
  void _onVoicePartial(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    ref.read(homeSearchProvider.notifier).setQuery(text);
  }

  /// Texto final reconocido: actualiza el campo y lanza la búsqueda.
  void _onVoiceFinal(String text, String language) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    setState(() => _localSuggestions = []);
    ref.read(homeSearchProvider.notifier).search(text, language: language);
  }

  void _onVoicePermissionDenied() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Permiso de micrófono denegado. Actívalo en Ajustes del sistema.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _onListen(String word, AppSettings settings) async {
    final tts = ref.read(ttsServiceProvider);
    final notifier = ref.read(homeSearchProvider.notifier);
    await tts.applySettings(settings);
    notifier.setSpeaking(true);
    try {
      await tts.speak(word);
    } finally {
      if (mounted) notifier.setSpeaking(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final state = ref.watch(homeSearchProvider);
    final language = state.language;
    final reduce = settings.reduceStimuli;

    ref.listen(keywordsProvider(language), (_, next) {
      if (_controller.text.trim().isEmpty) return;
      if (!next.hasValue) return;
      _onSearchTextChanged(_controller.text, settings, language);
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 92,
        centerTitle: true,
        title: Semantics(
          label: 'Logo Pictopedia',
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Image.asset(
              'assets/pictopedia.png',
              height: 95,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          IconButton(
            iconSize: 32,
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
            onPressed: () {
              Navigator.of(context).push<void>(
                teaAwareRoute<void>(
                  child: const SettingsScreen(),
                  reduceStimuli: reduce,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              _promptFor(language),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: language,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Idioma de búsqueda',
              ),
              items: ArasaacConstants.supportedLanguages
                  .map(
                    (code) => DropdownMenuItem<String>(
                      value: code,
                      child: Text(ArasaacConstants.languageLabels[code] ?? code),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                ref.read(homeSearchProvider.notifier).setLanguage(value);
                _controller.clear();
                setState(() => _localSuggestions = []);
              },
            ),
            _RecentSearches(
              settings: settings,
              onPick: (w) {
                _controller.text = w;
                ref.read(homeSearchProvider.notifier).applySuggestion(w);
                ref.read(homeSearchProvider.notifier).search(w, language: language);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: settings.effectiveBodySize),
              decoration: InputDecoration(
                hintText: _hintFor(language),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                suffixIcon: state.loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onChanged: (v) => _onSearchTextChanged(v, settings, language),
              onSubmitted: (_) => ref
                  .read(homeSearchProvider.notifier)
                  .search(_controller.text, language: language),
            ),
            const SizedBox(height: 12),
            VoiceSearchButton(
              language: language,
              fontSize: settings.effectiveBodySize,
              reduceMotion: reduce,
              onPartialResult: _onVoicePartial,
              onFinalResult: (text) => _onVoiceFinal(text, language),
              onPermissionDenied: _onVoicePermissionDenied,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton(
                onPressed: state.loading
                    ? null
                    : () => ref
                        .read(homeSearchProvider.notifier)
                        .search(_controller.text, language: language),
                child: Text(
                  'Buscar',
                  style: TextStyle(fontSize: settings.effectiveBodySize),
                ),
              ),
            ),
            if (_localSuggestions.isNotEmpty && _controller.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Sugerencias',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _localSuggestions.take(8).map((w) {
                  return ActionChip(
                    label: Text(w),
                    onPressed: () {
                      _controller.text = w;
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: w.length),
                      );
                      ref.read(homeSearchProvider.notifier).applySuggestion(w);
                      setState(() => _localSuggestions = []);
                      ref.read(homeSearchProvider.notifier).search(w, language: language);
                    },
                  );
                }).toList(),
              ),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 24),
              Semantics(
                liveRegion: true,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
              ),
              if (state.suggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Palabras parecidas en el diccionario:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.suggestions.map((w) {
                    return ActionChip(
                      label: Text(w),
                      onPressed: () {
                        _controller.text = w;
                        ref.read(homeSearchProvider.notifier).search(w, language: language);
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
            if (state.result != null) ...[
              PictogramResultCard(
                result: state.result!,
                displayWord: state.query,
                settings: settings,
                speaking: state.speaking,
                reduceMotion: reduce,
                onListen: () => _onListen(state.query, settings),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches({
    required this.settings,
    required this.onPick,
  });

  final AppSettings settings;
  final void Function(String word) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);
    return history.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Búsquedas recientes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.take(10).map((w) {
                return ActionChip(
                  label: Text(w, style: TextStyle(fontSize: settings.effectiveBodySize - 2)),
                  onPressed: () => onPick(w),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
