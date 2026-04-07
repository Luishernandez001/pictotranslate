import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';

/// Descarga el PNG del CDN con Dio (timeouts + User-Agent) y lo pinta con

/// [Image.memory]. Evita en Android el fallo habitual de [CachedNetworkImage]

/// (caché en disco / sqflite que deja la carga colgada indefinidamente).

class PictogramImage extends StatefulWidget {
  const PictogramImage({
    super.key,
    required this.pictogramId,
    required this.width,
    required this.height,
    required this.reduceMotion,
    required this.theme,
  });

  final int pictogramId;
  final double width;
  final double height;
  final bool reduceMotion;
  final ThemeData theme;

  @override
  State<PictogramImage> createState() => _PictogramImageState();
}

class _PictogramImageState extends State<PictogramImage> {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: true,
      validateStatus: (code) => code != null && code < 500,
    ),
  );

  Uint8List? _bytes;
  Object? _error;
  bool _loading = true;
  final CancelToken _cancel = CancelToken();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cancel.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final url = ArasaacConstants.pictogramImageUrl(widget.pictogramId);
    try {
      final res = await _dio.get<List<int>>(
        url,
        cancelToken: _cancel,
        options: Options(
          responseType: ResponseType.bytes,
          headers: ArasaacConstants.pictogramImageHeaders,
        ),
      );
      if (res.statusCode != 200 || res.data == null || res.data!.isEmpty) {
        throw DioException(
          requestOptions: res.requestOptions,
          message: 'Respuesta HTTP ${res.statusCode}',
        );
      }
      if (!mounted) return;
      setState(() {
        _bytes = Uint8List.fromList(res.data!);
        _loading = false;
      });
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) return;
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: widget.reduceMotion ? 2 : 3,
          ),
        ),
      );
    }
    if (_error != null || _bytes == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Text(
            'No se pudo cargar la imagen',
            textAlign: TextAlign.center,
            style: widget.theme.textTheme.bodyLarge,
          ),
        ),
      );
    }
    return Image.memory(
      _bytes!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Text(
            'No se pudo mostrar la imagen',
            textAlign: TextAlign.center,
            style: widget.theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
