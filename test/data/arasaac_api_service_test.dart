import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:pictotranslate/data/arasaac_api_service.dart';
import 'package:pictotranslate/domain/models/pictogram_result.dart';

void main() {
  group('ArasaacApiService', () {
    late Dio dio;
    late ArasaacApiService service;

    setUp(() {
      dio = Dio(
        BaseOptions(baseUrl: 'https://api.arasaac.org/v1'),
      );
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;
      service = ArasaacApiService(dio);
    });

    test('bestSearch returns pictograms from mocked response', () async {
      (dio.httpClientAdapter as DioAdapter).onGet(
        '/pictograms/en/bestsearch/apple',
        (server) => server.reply(
          200,
          jsonDecode(
            '[{"_id":2462,"keywords":[{"keyword":"apple"}],"tags":["fruit"]}]',
          ),
        ),
      );

      final results = await service.bestSearch('en', 'apple');
      expect(results, isA<List<PictogramResult>>());
      expect(results.single.id, 2462);
      expect(results.single.keyword, 'apple');
    });

    test('fetchKeywords parses words array', () async {
      (dio.httpClientAdapter as DioAdapter).onGet(
        '/keywords/en',
        (server) => server.reply(
          200,
          jsonDecode('{"words":["apple","dog"]}'),
        ),
      );

      final words = await service.fetchKeywords('en');
      expect(words, ['apple', 'dog']);
    });
  });
}
