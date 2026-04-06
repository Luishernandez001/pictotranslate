/// Resultado de búsqueda de pictograma (bestsearch).
class PictogramResult {
  const PictogramResult({
    required this.id,
    this.keyword,
    this.tags = const [],
  });

  final int id;
  final String? keyword;
  final List<String> tags;

  /// Parsea un elemento del array JSON de bestsearch.
  factory PictogramResult.fromJson(Map<String, dynamic> json) {
    final id = json['_id'];
    if (id is! int) {
      throw FormatException('Pictogram JSON missing int _id: $json');
    }
    String? kw;
    final keywords = json['keywords'];
    if (keywords is List && keywords.isNotEmpty) {
      final first = keywords.first;
      if (first is Map && first['keyword'] != null) {
        kw = first['keyword'].toString();
      }
    }
    final tagsRaw = json['tags'];
    final tags = <String>[];
    if (tagsRaw is List) {
      for (final t in tagsRaw) {
        tags.add(t.toString());
      }
    }
    return PictogramResult(id: id, keyword: kw, tags: tags);
  }

  static List<PictogramResult> listFromJson(dynamic data) {
    if (data is! List) {
      throw FormatException('Expected JSON array, got ${data.runtimeType}');
    }
    return data
        .whereType<Map>()
        .map((e) => PictogramResult.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
