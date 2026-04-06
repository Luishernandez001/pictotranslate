import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import 'app_providers.dart';

/// Keywords en inglés (cache en memoria durante la sesión).
final keywordsProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(arasaacApiServiceProvider);
  return api.fetchKeywords(ArasaacConstants.searchLanguage);
});
