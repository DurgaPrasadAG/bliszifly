import 'package:flutter/material.dart';

class MaterialTheme {

  static ThemeData materialLightTheme = ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(),
    );

  static ThemeData materialDarkTheme = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(),
    );
}