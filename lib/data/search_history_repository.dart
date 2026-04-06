import 'package:shared_preferences/shared_preferences.dart';

/// Historial local de últimas búsquedas (orden: más reciente primero).
class SearchHistoryRepository {
  SearchHistoryRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'search_history';
  static const int maxItems = 20;

  List<String> load() {
    final list = _prefs.getStringList(_key);
    if (list == null) return [];
    return List.unmodifiable(list);
  }

  Future<void> add(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    final current = List<String>.from(_prefs.getStringList(_key) ?? []);
    current.removeWhere((e) => e.toLowerCase() == t.toLowerCase());
    current.insert(0, t);
    if (current.length > maxItems) {
      current.removeRange(maxItems, current.length);
    }
    await _prefs.setStringList(_key, current);
  }
}
