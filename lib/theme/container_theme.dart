import 'package:flutter/material.dart';

BoxDecoration containerTheme(context) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
        Theme.of(context).colorScheme.tertiary,
      ],
    ),
  );
}

BoxDecoration buttonContainerTheme(context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    gradient:  LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
        Theme.of(context).colorScheme.tertiary,
      ],
    ),
  );
}
