import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'keywords_provider.dart';
import 'search_history_provider.dart';
import 'search_state.dart';

final homeSearchProvider =
    StateNotifierProvider<HomeSearchNotifier, HomeSearchState>((ref) {
  return HomeSearchNotifier(ref);
});

class HomeSearchNotifier extends StateNotifier<HomeSearchState> {
  HomeSearchNotifier(this._ref) : super(const HomeSearchState());

  final Ref _ref;

  void setQuery(String q) {
    state = state.copyWith(query: q, clearError: true);
  }

  void setLanguage(String language) {
    state = state.copyWith(
      language: language,
      clearError: true,
      suggestions: const [],
      clearResult: true,
    );
  }

  /// Sugerencias locales a partir de la lista de keywords (sin red).
  List<String> suggestFor(String partial, List<String> allKeywords) {
    final p = partial.trim().toLowerCase();
    if (p.isEmpty || allKeywords.isEmpty) return [];
    final out = <String>[];
    for (final w in allKeywords) {
      if (w.toLowerCase().contains(p)) {
        out.add(w);
        if (out.length >= 12) break;
      }
    }
    if (out.isNotEmpty) return out;
    // Prefijo primera letra como fallback suave
    if (p.isNotEmpty) {
      for (final w in allKeywords) {
        if (w.toLowerCase().startsWith(p[0])) {
          out.add(w);
          if (out.length >= 8) break;
        }
      }
    }
    return out;
  }

  Future<void> search(String rawQuery, {String? language}) async {
    final q = rawQuery.trim();
    final lang = language ?? state.language;
    if (q.isEmpty) {
      state = state.copyWith(
        language: lang,
        clearResult: true,
        errorMessage: 'Escribe una palabra para buscar.',
        suggestions: const [],
      );
      return;
    }

    state = state.copyWith(
      query: q,
      language: lang,
      loading: true,
      clearError: true,
      clearResult: true,
      suggestions: const [],
    );

    try {
      final api = _ref.read(arasaacApiServiceProvider);
      final list = await api.bestSearch(lang, q);
      if (list.isEmpty) {
        final keywordsAsync = _ref.read(keywordsProvider(lang));
        final keywords = keywordsAsync.valueOrNull ?? const <String>[];
        final sug = suggestFor(q, keywords);
        state = state.copyWith(
          loading: false,
          errorMessage:
              'No encontré un pictograma. Intenta otra palabra.',
          suggestions: sug,
        );
        return;
      }

      await _ref.read(searchHistoryRepositoryProvider).add(q);
      _ref.invalidate(searchHistoryProvider);

      state = state.copyWith(
        loading: false,
        result: list.first,
        suggestions: const [],
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'No pude conectar. Revisa tu internet e inténtalo de nuevo.',
        suggestions: const [],
      );
    }
  }

  void applySuggestion(String word) {
    state = state.copyWith(query: word, clearError: true);
  }

  void setSpeaking(bool v) {
    state = state.copyWith(speaking: v);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
