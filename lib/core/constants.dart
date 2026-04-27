/// URLs y constantes de ARASAAC (API pública v1 + CDN estático).
abstract final class ArasaacConstants {
  static const String apiBaseUrl = 'https://api.arasaac.org/v1';
  static const String staticCdnBase = 'https://static.arasaac.org/pictograms';
  static const String searchLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'es', 'fr'];
  static const Map<String, String> languageLabels = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
  };

  /// Cabeceras para el CDN: en Android el User-Agent por defecto de Dart a veces
  /// provoca respuestas raras o descargas que no terminan; imitamos un cliente móvil.
  static const Map<String, String> pictogramImageHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 PictoTranslate/1.0',
    'Accept': 'image/png,image/webp,image/*;q=0.8,*/*;q=0.5',
  };

  /// Imagen 500px por defecto. Variantes (nocolor, plural, etc.) se pueden
  /// añadir como sufijos de ruta en versiones futuras.
  static String pictogramImageUrl(int id, {int size = 500}) =>
      '$staticCdnBase/$id/${id}_$size.png';
}
