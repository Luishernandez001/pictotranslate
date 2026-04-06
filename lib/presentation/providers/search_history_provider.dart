import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';

/// Últimas búsquedas guardadas localmente.
final searchHistoryProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(searchHistoryRepositoryProvider).load();
});
