/// URLs y constantes de ARASAAC (API pública v1 + CDN estático).
abstract final class ArasaacConstants {
  static const String apiBaseUrl = 'https://api.arasaac.org/v1';
  static const String staticCdnBase = 'https://static.arasaac.org/pictograms';
  static const String searchLanguage = 'en';

  /// Imagen 500px por defecto. Variantes (nocolor, plural, etc.) se pueden
  /// añadir como sufijos de ruta en versiones futuras.
  static String pictogramImageUrl(int id, {int size = 500}) =>
      '$staticCdnBase/$id/${id}_$size.png';
}
