import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../domain/models/pictogram_result.dart';

/// Cliente HTTP para la API pública ARASAAC.
class ArasaacApiService {
  ArasaacApiService(this._dio);

  final Dio _dio;

  /// GET /keywords/{language} → lista de palabras para autocompletado.
  Future<List<String>> fetchKeywords(String language) async {
    final response = await _dio.get<Map<String, dynamic>>('/keywords/$language');
    final words = response.data?['words'];
    if (words is! List) return [];
    return words
        .map((e) => e.toString().trim())
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// GET /pictograms/{language}/bestsearch/{searchText}
  Future<List<PictogramResult>> bestSearch(String language, String searchText) async {
    final q = searchText.trim();
    if (q.isEmpty) return [];
    final encoded = Uri.encodeComponent(q);
    final response = await _dio.get<dynamic>('/pictograms/$language/bestsearch/$encoded');
    final data = response.data;
    if (data == null) return [];
    return PictogramResult.listFromJson(data);
  }
}

/// Dio configurado para ARASAAC (inyectable en tests).
Dio createArasaacDio() {
  return Dio(
    BaseOptions(
      baseUrl: ArasaacConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
}
