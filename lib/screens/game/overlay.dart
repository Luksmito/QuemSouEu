import 'package:flutter/material.dart';

class MyOverlay extends StatelessWidget {
  const MyOverlay({
    super.key,
    required this.opacityLevel,
  });

  final double opacityLevel;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacityLevel,
      duration:
        const  Duration(milliseconds: 500), // Duração da animação
      curve: Curves.easeInOut, // Curva de animação
            
      child: Container(
        color: Colors.black,
      ),
    );
  }
}
