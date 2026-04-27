import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';

/// Keywords por idioma (cache en memoria durante la sesión).
final keywordsProvider = FutureProvider.family<List<String>, String>((ref, language) async {
  final api = ref.watch(arasaacApiServiceProvider);
  return api.fetchKeywords(language);
});
