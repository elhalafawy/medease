import 'package:flutter/material.dart';

class CustomTextStyle {
  static const TextStyle headline1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle headline2 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const TextStyle headline3 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle headline4 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle headline5 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle headline6 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  static const TextStyle subtitle1 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle subtitle2 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);

  static const TextStyle bodyText1 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const TextStyle bodyText2 = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const TextStyle overline = TextStyle(fontSize: 10, fontWeight: FontWeight.w400);

  static const TextTheme textTheme = TextTheme(
    displayLarge: headline1,
    displayMedium: headline2,
    displaySmall: headline3,
    headlineMedium: headline4,
    headlineSmall: headline5,
    titleLarge: headline6,
    titleMedium: subtitle1,
    titleSmall: subtitle2,
    bodyLarge: bodyText1,
    bodyMedium: bodyText2,
    labelLarge: button,
    bodySmall: caption,
    labelSmall: overline,
  );
}