import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Botón de búsqueda por voz.
///
/// Flujo:
///   1) Usuario toca → se pide permiso de micrófono si es la primera vez.
///   2) Empieza a escuchar en el [locale] del idioma de búsqueda.
///   3) Los resultados parciales se entregan en tiempo real a [onPartialResult].
///   4) Al detectar silencio o al tocar de nuevo, se entrega el texto final
///      a [onFinalResult] y la app lanza la búsqueda automáticamente.
///   5) Si el permiso fue denegado se llama a [onPermissionDenied].
class VoiceSearchButton extends StatefulWidget {
  const VoiceSearchButton({
    super.key,
    required this.language,
    required this.onPartialResult,
    required this.onFinalResult,
    required this.onPermissionDenied,
    required this.fontSize,
    this.reduceMotion = false,
  });

  /// Código de idioma ARASAAC ('en', 'es', 'fr') usado para elegir el locale
  /// del reconocedor nativo.
  final String language;

  /// Texto transcrito mientras el usuario habla (resultado parcial).
  final ValueChanged<String> onPartialResult;

  /// Texto final confirmado cuando el usuario deja de hablar.
  final ValueChanged<String> onFinalResult;

  /// Llamado cuando el permiso de micrófono está denegado permanentemente.
  final VoidCallback onPermissionDenied;

  final double fontSize;

  /// Cuando es true se omite la animación pulsante (modo TEA).
  final bool reduceMotion;

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _stt = SpeechToText();
  bool _isListening = false;
  bool _available = false;
  bool _initialized = false;
  String _statusMessage = '';

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Mapa de código ARASAAC → locale BCP-47 para el reconocedor nativo.
  static const Map<String, String> _localeMap = {
    'en': 'en-US',
    'es': 'es-ES',
    'fr': 'fr-FR',
  };

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _stt.stop();
    super.dispose();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _available = await _stt.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    _initialized = true;
  }

  void _onStatus(String status) {
    // 'done' o 'notListening' significa que el motor terminó.
    if (status == 'done' || status == 'notListening') {
      if (mounted && _isListening) _stopListening();
    }
  }

  void _onError(dynamic error) {
    if (mounted) {
      setState(() {
        _isListening = false;
        _statusMessage = '';
      });
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    await _ensureInitialized();

    if (!_available) {
      // El motor de reconocimiento no está disponible (primer arranque o
      // dispositivo sin servicio Google).
      if (mounted) {
        setState(() {
          _statusMessage = 'El reconocimiento de voz no está disponible en este dispositivo.';
        });
      }
      return;
    }

    // Verifica permiso; speech_to_text lo solicita en initialize() pero
    // comprobamos el estado explícitamente.
    final hasPermission = await _stt.hasPermission;
    if (!hasPermission) {
      widget.onPermissionDenied();
      return;
    }

    final locale = _localeMap[widget.language] ?? 'en-US';

    if (mounted) {
      setState(() {
        _isListening = true;
        _statusMessage = '';
      });
    }

    if (!widget.reduceMotion) {
      _pulseCtrl.repeat(reverse: true);
    }

    await _stt.listen(
      localeId: locale,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.search,
      ),
      onResult: (SpeechRecognitionResult result) {
        if (!mounted) return;
        if (result.finalResult) {
          final text = result.recognizedWords.trim();
          _stopListening();
          if (text.isNotEmpty) widget.onFinalResult(text);
        } else {
          widget.onPartialResult(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _stt.stop();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    if (mounted) {
      setState(() {
        _isListening = false;
        _statusMessage = '';
      });
    }
  }

  String _labelFor(String language) {
    switch (language) {
      case 'es':
        return _isListening ? 'Escuchando…' : 'Buscar por voz';
      case 'fr':
        return _isListening ? 'Écoute en cours…' : 'Recherche vocale';
      default:
        return _isListening ? 'Listening…' : 'Search by voice';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _isListening
        ? theme.colorScheme.error
        : theme.colorScheme.secondaryContainer;
    final onColor = _isListening
        ? theme.colorScheme.onError
        : theme.colorScheme.onSecondaryContainer;

    final buttonContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón principal
        ScaleTransition(
          scale: (!widget.reduceMotion && _isListening)
              ? _pulseAnim
              : const AlwaysStoppedAnimation(1.0),
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _toggleListening,
              child: Semantics(
                button: true,
                label: _labelFor(widget.language),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isListening ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
                        size: 30,
                        color: onColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _labelFor(widget.language),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: widget.fontSize,
                          color: onColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Mensaje de error o estado (solo si hay texto)
        if (_statusMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );

    return SizedBox(width: double.infinity, child: buttonContent);
  }
}
