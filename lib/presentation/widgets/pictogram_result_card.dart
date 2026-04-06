import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../data/settings_store.dart';
import '../../domain/models/pictogram_result.dart';

class PictogramResultCard extends StatelessWidget {
  const PictogramResultCard({
    super.key,
    required this.result,
    required this.displayWord,
    required this.settings,
    required this.onListen,
    required this.speaking,
    required this.reduceMotion,
  });

  final PictogramResult result;
  final String displayWord;
  final AppSettings settings;
  final VoidCallback onListen;
  final bool speaking;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = ArasaacConstants.pictogramImageUrl(result.id);
    final titleSize = settings.effectiveBodySize + 8;

    return Semantics(
      container: true,
      label: 'Pictograma para la palabra $displayWord',
      child: Card(
        elevation: reduceMotion ? 0 : 1,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                  fadeInDuration:
                      reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
                  fadeOutDuration:
                      reduceMotion ? Duration.zero : const Duration(milliseconds: 150),
                  placeholder: (_, __) => SizedBox(
                    width: 280,
                    height: 280,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: reduceMotion ? 2 : 3,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => SizedBox(
                    width: 280,
                    height: 280,
                    child: Center(
                      child: Text(
                        'No se pudo cargar la imagen',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                displayWord,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: titleSize),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: onListen,
                  icon: Icon(
                    speaking ? Icons.volume_up : Icons.hearing,
                    size: 28,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      speaking ? 'Reproduciendo…' : '🔊 Escuchar',
                      style: TextStyle(fontSize: settings.effectiveBodySize),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
