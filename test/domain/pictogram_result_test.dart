import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pictotranslate/domain/models/pictogram_result.dart';

void main() {
  group('PictogramResult', () {
    test('fromJson parses _id and keyword from bestsearch shape', () {
      final map = jsonDecode('''
{
  "_id": 2462,
  "tags": ["fruit"],
  "keywords": [{"keyword": "apple", "type": 2}]
}
''') as Map<String, dynamic>;

      final r = PictogramResult.fromJson(map);
      expect(r.id, 2462);
      expect(r.keyword, 'apple');
      expect(r.tags, ['fruit']);
    });

    test('listFromJson parses array', () {
      final raw = jsonDecode(
        '[{"_id":1,"keywords":[]},{"_id":2,"keywords":[{"keyword":"dog"}]}]',
      );
      final list = PictogramResult.listFromJson(raw);
      expect(list.length, 2);
      expect(list[0].id, 1);
      expect(list[1].keyword, 'dog');
    });

    test('listFromJson throws on non-list', () {
      expect(
        () => PictogramResult.listFromJson(<String, dynamic>{}),
        throwsFormatException,
      );
    });
  });
}
