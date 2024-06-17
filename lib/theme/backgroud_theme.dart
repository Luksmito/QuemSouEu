import 'package:flutter/material.dart';

BoxDecoration backgroundTheme(context) {
  return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
        
        Theme.of(context).colorScheme.primary.withAlpha(150),
        Theme.of(context).colorScheme.onPrimary.withAlpha(150),
        Theme.of(context).colorScheme.secondary.withAlpha(150),
        Theme.of(context).colorScheme.primary.withAlpha(150),
      ]));
}
