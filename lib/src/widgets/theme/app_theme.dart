import 'package:flutter/material.dart';

abstract class AppTheme {
  AppTheme._();
  static const primaryColor = Color(0xFF1C2334);
  static const Color backgroundColor = Colors.transparent;
  static const twitterBlue = Color(0xFF1DA1F2);

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      scaffoldBackgroundColor: backgroundColor,
    );
  }
}
