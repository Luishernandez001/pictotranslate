import 'package:flutter/material.dart';

/// Rutas con transición mínima cuando el usuario activa "Reducir estímulos".
Route<T> teaAwareRoute<T extends Object?>({
  required Widget child,
  required bool reduceStimuli,
  bool fullscreenDialog = false,
}) {
  if (reduceStimuli) {
    return PageRouteBuilder<T>(
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
  return MaterialPageRoute<T>(
    fullscreenDialog: fullscreenDialog,
    builder: (_) => child,
  );
}
