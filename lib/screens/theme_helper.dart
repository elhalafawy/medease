// theme_helper.dart
import 'package:flutter/material.dart';
import 'custom_button_style.dart';
import 'custom_text_style.dart';

class ThemeHelper {
  static ThemeData get lightTheme => ThemeData(
        primaryColor: const Color(0xFF022E5B),
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        fontFamily: 'Roboto',
        textTheme: CustomTextStyle.textTheme,
        elevatedButtonTheme: CustomButtonStyle.elevatedButtonTheme,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: CustomTextStyle.subtitle1,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF022E5B), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF022E5B)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF022E5B)),
          ),
        ),
      );
}