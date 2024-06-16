import 'package:flutter/material.dart';

InputDecoration textFieldDecoration({
  required String hintText,
  IconData? icon,
  bool square = false
}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.grey[200],
    prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(square ? Radius.zero : const Radius.circular(15.0)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(square ? Radius.zero : const Radius.circular(15.0)),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(square ? Radius.zero : const Radius.circular(15.0)),
      borderSide: BorderSide(color: Colors.blue.shade300, width: 2.0),
    ),
  );
}