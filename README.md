# PictoTranslate

App Flutter (Android) que traduce palabras en **inglés** a **pictogramas** usando la [API pública de ARASAAC](https://github.com/Arasaac/public-api). Pensada con criterios de **accesibilidad y UX favorables a estudiantes con TEA**: interfaz calmada, controles grandes, audio solo bajo demanda y opciones de reducción de estímulos.

## Estructura del proyecto

```
lib/
  main.dart                          # Punto de entrada + ProviderScope
  app.dart                           # MaterialApp, temas según ajustes
  core/
    constants.dart                   # URLs API y CDN ARASAAC
    theme/app_theme.dart             # Tema suave / alto contraste, transiciones
  data/
    arasaac_api_service.dart         # Dio: keywords + bestsearch
    settings_store.dart              # Modelo y persistencia de ajustes
    search_history_repository.dart # Historial (SharedPreferences)
  domain/
    models/pictogram_result.dart     # Parseo de respuesta bestsearch
  presentation/
    providers/                       # Riverpod
    screens/                         # Home, Ajustes, Créditos
    widgets/                         # Tarjeta de resultado + imagen en caché
    services/tts_service.dart       # flutter_tts (en-US)
test/
  domain/pictogram_result_test.dart
  data/arasaac_api_service_test.dart
  widget_test.dart
```

## Instalación y ejecución

1. Instala [Flutter](https://docs.flutter.dev/get-started/install) (canal estable) y configura Android SDK / dispositivo o emulador.
2. En la carpeta del proyecto:

```bash
flutter pub get
flutter run
```

3. Para compilar APK de depuración:

```bash
flutter build apk --debug
```

**Requisitos:** conexión a Internet la primera vez que se cargan keywords y pictogramas. Las imágenes se cachean con `cached_network_image`.

## API ARASAAC (usada en el MVP)

- Keywords (inglés): `GET https://api.arasaac.org/v1/keywords/en`
- Mejor pictograma: `GET https://api.arasaac.org/v1/pictograms/en/bestsearch/{texto}`
- Imagen 500px: `https://static.arasaac.org/pictograms/{id}/{id}_500.png`

## Licencia y atribución

Los pictogramas y datos de ARASAAC se distribuyen bajo **Creative Commons BY-NC-SA**. En la app: **Ajustes → Créditos y licencia ARASAAC**. Uso no comercial y citar origen/autor según [ARASAAC](https://arasaac.org/).

## Checklist de accesibilidad TEA (aplicado en este MVP)

- Interfaz **predecible**: barra superior fija, botón Ajustes siempre en el mismo sitio; sin diálogos intrusivos para errores (mensaje en pantalla con `liveRegion`).
- **Sin audio automático**: el TTS solo al pulsar **Escuchar**.
- **Tipografía grande** (18–26 pt + opción “letra extra grande”) y **espaciado amplio** entre controles.
- **Colores suaves** por defecto; **modo alto contraste** opcional.
- **Reducir estímulos**: sin splash en botones, transiciones de página desactivadas, `themeAnimationDuration` a cero, fades de imagen mínimos.
- **Autocompletado con debounce** (~320 ms) para no saturar mientras se escribe.
- **Semántica** en la tarjeta de resultado (`Semantics` con etiqueta descriptiva).
- **Feedback suave** en el botón de escucha (texto “Reproduciendo…”); sin vibración obligatoria.

## Ideas para versión 2.0 (opcional)

- Categorías temáticas y listas guiadas (comida, colegio, emociones).
- Favoritos y colecciones del alumno.
- Frases cortas (varias palabras → secuencia de pictogramas).
- Paquete offline (cache de keywords + pictogramas frecuentes).
- Variantes de pictograma (plural, pasado, sin color) vía sufijos de URL cuando ARASAAC lo exponga de forma estable en tu flujo.

## Pruebas

```bash
flutter test
flutter analyze
```
