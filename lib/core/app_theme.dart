import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        colorSchemeSeed: const Color(0xFF0A60FF),
        useMaterial3: true,
        brightness: Brightness.light,
      );

  static ThemeData get dark => ThemeData(
        colorSchemeSeed: const Color(0xFF0A60FF),
        useMaterial3: true,
        brightness: Brightness.dark,
      );
}
