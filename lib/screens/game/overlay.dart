import 'package:flutter/material.dart';

class MyOverlay extends StatelessWidget {
  const MyOverlay({
    super.key,
    required this.opacityLevel,
    required this.child
  });

  final double opacityLevel;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacityLevel,
      duration: const Duration(milliseconds: 500), // Duração da animação
      curve: Curves.easeInOut, // Curva de animação

      child: child 
    );
  }
}
