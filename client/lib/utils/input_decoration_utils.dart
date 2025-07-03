import 'package:flutter/material.dart';

InputDecoration buildInputDecoration(String label, IconData icon, {String? hintText, String? errorText}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    errorText: errorText,
    prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}
