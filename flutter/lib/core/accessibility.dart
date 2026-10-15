import 'package:flutter/material.dart';

/// Choose the higher-contrast foreground for an opaque sRGB background.
Color readableForeground(Color background) {
  final luminance = background.computeLuminance();
  return (luminance + .05) / .05 >= 1.05 / (luminance + .05)
      ? Colors.black
      : Colors.white;
}

/// Settle cancellation so the global play lock can always be released.
Future<bool> finishPlayAnimation(
    AnimationController controller, BuildContext context) async {
  if (MediaQuery.disableAnimationsOf(context)) {
    controller.value = 1;
    return true;
  }
  try {
    await controller.forward(from: 0).orCancel;
    return true;
  } on TickerCanceled {
    return false;
  }
}
