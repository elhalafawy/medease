import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medease/core/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('Light Theme Colors', () {
      final theme = AppTheme.lightTheme;
      
      // Test primary colors
      expect(theme.primaryColor, equals(const Color(0xFF022E5B)));
      expect(theme.colorScheme.primary, equals(const Color(0xFF022E5B)));
      expect(theme.colorScheme.secondary, equals(const Color(0xFF00264D)));
      
      // Test background colors
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFFFDFDFD)));
      expect(theme.colorScheme.surface, equals(const Color(0xFFFDFDFD)));
    });

    test('Button Themes', () {
      final theme = AppTheme.lightTheme;
      
      // Test ElevatedButton
      final elevatedButtonStyle = theme.elevatedButtonTheme.style;
      expect(elevatedButtonStyle?.minimumSize?.resolve({}), equals(const Size(100, 40)));
      expect(elevatedButtonStyle?.padding?.resolve({}), equals(const EdgeInsets.symmetric(vertical: 12, horizontal: 16)));
      
      // Test OutlinedButton
      final outlinedButtonStyle = theme.outlinedButtonTheme.style;
      expect(outlinedButtonStyle?.minimumSize?.resolve({}), equals(const Size(100, 40)));
      expect(outlinedButtonStyle?.padding?.resolve({}), equals(const EdgeInsets.symmetric(vertical: 12, horizontal: 16)));
      
      // Test TextButton
      final textButtonStyle = theme.textButtonTheme.style;
      expect(textButtonStyle?.minimumSize?.resolve({}), equals(const Size(80, 36)));
      expect(textButtonStyle?.padding?.resolve({}), equals(const EdgeInsets.symmetric(vertical: 8, horizontal: 12)));
    });

    test('Text Themes', () {
      final theme = AppTheme.lightTheme;
      
      // Test headline styles
      expect(theme.textTheme.headlineLarge?.fontSize, equals(30));
      expect(theme.textTheme.headlineMedium?.fontSize, equals(24));
      expect(theme.textTheme.titleLarge?.fontSize, equals(18));
      expect(theme.textTheme.bodyLarge?.fontSize, equals(16));
      expect(theme.textTheme.bodyMedium?.fontSize, equals(14));
    });

    test('Dark Theme Colors', () {
      final theme = AppTheme.nightTheme;
      
      // Test dark theme colors
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFF121212)));
      expect(theme.colorScheme.surface, equals(const Color(0xFF121212)));
      expect(theme.colorScheme.onSurface, equals(Colors.white));
    });
  });
} 