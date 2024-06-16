import 'package:flutter/material.dart';

ButtonStyle squareButtonTheme() {
  return ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        elevation: MaterialStateProperty.all<double>(10.0),
        shadowColor: MaterialStateProperty.all<Color>(Colors.black.withOpacity(0.3)),
      );
}