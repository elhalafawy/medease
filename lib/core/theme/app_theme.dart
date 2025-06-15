import 'package:flutter/material.dart';

class AppTheme {
  // Size Constants
  static const double kBorderRadiusSmall = 8.0;
  static const double kBorderRadiusMedium = 12.0;
  static const double kBorderRadiusLarge = 16.0;
  static const double kBorderRadiusXLarge = 20.0;

  static const double kPaddingSmall = 8.0;
  static const double kPaddingMedium = 12.0;
  static const double kPaddingLarge = 16.0;
  static const double kPaddingXLarge = 20.0;
  static const double kPadding3XL = 32.0;

  static const double kElevationSmall = 2.0;
  static const double kElevationMedium = 4.0;
  static const double kElevationLarge = 8.0;

  // Brand Colors (Updated for better contrast)
  static const Color primaryColor = Color(0xFF022E5B); // Original primary color
  static const Color secondaryColor = Color(0xFF00264D); // Original secondary color

  // Background Colors (Updated for better contrast)
  static const Color backgroundColor = Color(0xFFF8F9FA); // Slightly darker for better contrast
  static const Color appBarBackgroundColor = Color(0xFFFFFFFF); // Pure white for better contrast
  static const Color darkBackground = Color(0xFF121212); // Material dark background
  static const Color darkSurface = Color(0xFF1E1E1E); // Slightly lighter than background

  // Text Colors (Updated for better readability)
  static const Color textColor = Color(0xFF1A1A1A); // Darker for better contrast
  static const Color greyColor = Color(0xFF757575); // Material grey
  static const Color darkText = Color(0xFFF5F5F5); // Brighter for better readability
  static const Color darkGrey = Color(0xFF9E9E9E); // Material grey for dark mode

  // Border Colors (Updated for better visibility)
  static const Color borderColor = Color(0xFFE0E0E0); // Material grey 300
  static const Color darkBorder = Color(0xFF424242); // Material grey 800

  // Status Colors (Updated for better visibility in both modes)
  static const Color errorColor = Color(0xFFD32F2F); // Material red 700
  static const Color successColor = Color(0xFF2E7D32); // Material green 800
  static const Color warningColor = Color(0xFFF57C00); // Material orange 700

  // Booking colors
  static const Color bookingDayColor = Color(0xFF73D0ED);
  static const Color bookingTimeColor = Color(0xFFEDAE73);
  // Notification icon and background colors (Light Mode)
  static const Color notifCalendarIcon = Color(0xFF2563EB);
  static const Color notifCalendarBg = Color(0xFFE8F1FB);
  static const Color notifChatIcon = Color(0xFFEA4E6D);
  static const Color notifChatBg = Color(0xFFFDE8ED);
  static const Color notifMedicineIcon = Color(0xFFF5B100);
  static const Color notifMedicineBg = Color(0xFFFFF7E6);
  static const Color notifVaccineIcon = Color(0xFF22D3EE);
  static const Color notifVaccineBg = Color(0xFFE6F9FB);
  static const Color notifUpdateIcon = Color(0xFFB91C1C);
  static const Color notifUpdateBg = Color(0xFFFDE8ED);
  static const Color notifCardBorder = Color(0xFFE5EAF2);
  static const Color notifPageBg = Color(0xFFF9FAFB);
  // Dark mode specific
  static const Color darkCard = Color(0xFF23262F);
  static const Color darkDialog = Color(0xFF23262F);
  static const Color darkInput = Color(0xFF23262F);

  // Night mode colors (Updated for better contrast and visibility)
  static const Color nightBackground = Color(0xFF121212); // Material dark background
  static const Color nightSurface = Color(0xFF1E1E1E); // Slightly lighter than background
  static const Color nightCard = Color(0xFF2C2C2C); // Slightly lighter than surface
  static const Color nightDialog = Color(0xFF2C2C2C); // Same as card for consistency
  static const Color nightInput = Color(0xFF2C2C2C); // Same as card for consistency
  static const Color nightBorder = Color(0xFF424242); // Material grey 800
  static const Color nightText = Color(0xFFF5F5F5); // Material grey 100
  static const Color nightGrey = Color(0xFF9E9E9E); // Material grey 500
  static const Color nightPrimary = Color(0xFF2196F3); // Material blue 500
  static const Color nightSecondary = Color(0xFF1976D2); // Material blue 700
  static const Color nightError = Color(0xFFEF5350); // Material red 400
  static const Color nightSuccess = Color(0xFF66BB6A); // Material green 400
  static const Color nightWarning = Color(0xFFFFB74D); // Material orange 300

  // Night mode notification colors
  static const Color nightNotifCalendarIcon =
      Color(0xFF60A5FA); // Adjusted for contrast
  static const Color nightNotifCalendarBg = Color(0xFF1E3A8A);
  static const Color nightNotifChatIcon =
      Color(0xFFF472B6); // Adjusted for contrast
  static const Color nightNotifChatBg = Color(0xFF831843);
  static const Color nightNotifMedicineIcon =
      Color(0xFFFACC15); // Adjusted for contrast
  static const Color nightNotifMedicineBg = Color(0xFF78350F);
  static const Color nightNotifVaccineIcon =
      Color(0xFF22D3EE); // Adjusted for contrast
  static const Color nightNotifVaccineBg = Color(0xFF164E63);
  static const Color nightNotifUpdateIcon =
      Color(0xFFF87171); // Adjusted for contrast
  static const Color nightNotifUpdateBg = Color(0xFF7F1D1D);
  static const Color nightNotifCardBorder =
      Color(0xFF4B5563); // Adjusted for contrast
  static const Color nightNotifPageBg =
      Color(0xFF1F2937); // Adjusted for contrast

  // Text Styles Constants
  static const double kFontSizeXS = 12.0;
  static const double kFontSizeSM = 14.0;
  static const double kFontSizeMD = 16.0;
  static const double kFontSizeLG = 18.0;
  static const double kFontSizeXL = 20.0;
  static const double kFontSize2XL = 24.0;
  static const double kFontSize3XL = 32.0;
  static const double kFontSize4XL = 40.0;

  // Text Styles (Light Mode)
  static const TextStyle displayLarge = TextStyle(
    fontSize: kFontSize4XL,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: kFontSize3XL,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: kFontSize2XL,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0,
    height: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: kFontSize2XL,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: kFontSizeXL,
    fontWeight: FontWeight.w700,
    color: textColor,
    letterSpacing: 0.1,
    height: 1.2,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: kFontSizeLG,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.05,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: kFontSizeLG,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.05,
    height: 1.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: kFontSizeMD,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.05,
    height: 1.2,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: kFontSizeSM,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.05,
    height: 1.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: kFontSizeMD,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: kFontSizeSM,
    fontWeight: FontWeight.normal,
    color: textColor,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: kFontSizeXS,
    fontWeight: FontWeight.normal,
    color: greyColor,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: kFontSizeSM,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: kFontSizeXS,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: kFontSizeXS,
    fontWeight: FontWeight.w500,
    color: greyColor,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Text Styles (Light Mode)
  // Using get accessors for potential future dynamic adjustments, but primarily copying with color changes.
  static TextStyle get nightDisplayLarge =>
      displayLarge.copyWith(color: nightText);
  static TextStyle get nightDisplayMedium =>
      displayMedium.copyWith(color: nightText);
  static TextStyle get nightDisplaySmall =>
      displaySmall.copyWith(color: nightText);
  static TextStyle get nightHeadlineLarge =>
      headlineLarge.copyWith(color: nightText);
  static TextStyle get nightHeadlineMedium =>
      headlineMedium.copyWith(color: nightText);
  static TextStyle get nightHeadlineSmall =>
      headlineSmall.copyWith(color: nightText);
  static TextStyle get nightTitleLarge => titleLarge.copyWith(color: nightText);
  static TextStyle get nightTitleMedium =>
      titleMedium.copyWith(color: nightText);
  static TextStyle get nightTitleSmall => titleSmall.copyWith(color: nightText);
  static TextStyle get nightBodyLarge => bodyLarge.copyWith(color: nightText);
  static TextStyle get nightBodyMedium => bodyMedium.copyWith(color: nightText);
  // Using nightGrey for less prominent text in dark mode
  static TextStyle get nightBodySmall => bodySmall.copyWith(color: nightGrey);
  static TextStyle get nightLabelLarge => labelLarge.copyWith(color: nightText);
  static TextStyle get nightLabelMedium =>
      labelMedium.copyWith(color: nightText);
  static TextStyle get nightLabelSmall => labelSmall.copyWith(color: nightGrey);

  // --- Theme Data Definitions ---

  // Light Theme
  static ThemeData get lightTheme {
    const ColorScheme lightColorScheme = ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE3F2FD), // Light blue 50
      onPrimaryContainer: Color(0xFF022E5B), // Original primary color
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE8EAF6), // Indigo 50
      onSecondaryContainer: Color(0xFF00264D), // Original secondary color
      tertiary: Color(0xFF00BCD4), // Cyan 500
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE0F7FA), // Cyan 50
      onTertiaryContainer: Color(0xFF006064), // Cyan 900
      error: errorColor,
      onError: Colors.white,
      errorContainer: Color(0xFFFFEBEE), // Red 50
      onErrorContainer: Color(0xFFB71C1C), // Red 900
      background: backgroundColor,
      onBackground: textColor,
      surface: Colors.white,
      onSurface: textColor,
      surfaceVariant: Color(0xFFF5F5F5), // Grey 100
      onSurfaceVariant: Color(0xFF616161), // Grey 700
      outline: borderColor,
      outlineVariant: Color(0xFFE0E0E0), // Grey 300
      shadow: Color(0x1A000000), // 10% black
      scrim: Color(0x52000000), // 32% black
      inverseSurface: darkBackground,
      onInverseSurface: darkText,
      inversePrimary: nightPrimary,
      surfaceTint: primaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightColorScheme.background,

      // Updated text theme with better contrast
      textTheme: TextTheme(
        displayLarge: displayLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: displayMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        displaySmall: displaySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineLarge: headlineLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: headlineMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineSmall: headlineSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleLarge: titleLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: titleMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleSmall: titleSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        bodyLarge: bodyLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
        bodyMedium: bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: bodySmall.copyWith(
          color: greyColor,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: labelLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: labelMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelSmall: labelSmall.copyWith(
          color: greyColor,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // Updated AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: textColor,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: textColor,
          size: 24,
        ),
      ),

      // Updated Button themes with consistent styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: lightColorScheme.onPrimary,
          backgroundColor: lightColorScheme.primary,
          elevation: kElevationSmall,
          shadowColor: lightColorScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingLarge,
            vertical: kPaddingMedium,
        ),
          textStyle: labelLarge.copyWith(
            color: lightColorScheme.onPrimary,
            fontWeight: FontWeight.w600,
      ),
          minimumSize: const Size(88, 48),
        ),
      ),

      // Updated TextButton theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingMedium,
            vertical: kPaddingSmall,
        ),
          textStyle: labelLarge.copyWith(
            color: lightColorScheme.primary,
            fontWeight: FontWeight.w600,
      ),
          minimumSize: const Size(88, 48),
        ),
      ),

      // Updated OutlinedButton theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          side: BorderSide(
            color: lightColorScheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingLarge,
            vertical: kPaddingMedium,
        ),
          textStyle: labelLarge.copyWith(
            color: lightColorScheme.primary,
            fontWeight: FontWeight.w600,
      ),
          minimumSize: const Size(88, 48),
        ),
      ),

      // Updated IconButton theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(kPaddingSmall),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
      ),
      ),

      // Updated FloatingActionButton theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        elevation: kElevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
      ),

      // Updated Card theme
      cardTheme: CardTheme(
        color: lightColorScheme.surface,
        elevation: kElevationSmall,
        shadowColor: lightColorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          side: BorderSide(
            color: lightColorScheme.outlineVariant,
            width: 0.5,
        ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Updated Input Decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surface,
        hintStyle: bodyMedium.copyWith(
          color: greyColor,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: greyColor,
        suffixIconColor: greyColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
            color: lightColorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
            color: lightColorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
            color: lightColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
            color: lightColorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
            color: lightColorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kPaddingMedium,
          vertical: kPaddingMedium,
        ),
        errorStyle: bodySmall.copyWith(
          color: lightColorScheme.error,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Updated Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: lightColorScheme.surface,
        elevation: kElevationLarge,
        shadowColor: lightColorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
        titleTextStyle: titleLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Updated BottomSheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightColorScheme.surface,
        elevation: kElevationLarge,
        shadowColor: lightColorScheme.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadiusLarge),
          ),
        ),
      ),

      // Updated Divider theme
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Add SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightColorScheme.surface,
        contentTextStyle: bodyMedium.copyWith(
          color: lightColorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Add Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: lightColorScheme.surfaceVariant,
        labelStyle: labelMedium.copyWith(
          color: lightColorScheme.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: kPaddingSmall,
          vertical: kPaddingSmall / 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
      ),
    );
  }

  // Night Theme (Updated with better contrast and visibility)
  static ThemeData get nightTheme {
    const ColorScheme darkColorScheme = ColorScheme.dark(
      primary: nightPrimary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1565C0), // Blue 800
      onPrimaryContainer: Color(0xFFE3F2FD), // Blue 50
      secondary: nightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF1A237E), // Indigo 900
      onSecondaryContainer: Color(0xFFE8EAF6), // Indigo 50
      tertiary: Color(0xFF00BCD4), // Cyan 500
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF006064), // Cyan 900
      onTertiaryContainer: Color(0xFFE0F7FA), // Cyan 50
      error: nightError,
      onError: Colors.white,
      errorContainer: Color(0xFFB71C1C), // Red 900
      onErrorContainer: Color(0xFFFFEBEE), // Red 50
      background: nightBackground,
      onBackground: nightText,
      surface: nightSurface,
      onSurface: nightText,
      surfaceVariant: Color(0xFF2C2C2C),
      onSurfaceVariant: Color(0xFFBDBDBD), // Grey 400
      outline: nightBorder,
      outlineVariant: Color(0xFF616161), // Grey 700
      shadow: Color(0x40000000), // 25% black
      scrim: Color(0x80000000), // 50% black
      inverseSurface: backgroundColor,
      onInverseSurface: textColor,
      inversePrimary: primaryColor,
      surfaceTint: nightPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      primaryColor: nightPrimary,
      scaffoldBackgroundColor: darkColorScheme.background,

      // Updated text theme for dark mode
      textTheme: TextTheme(
        displayLarge: nightDisplayLarge.copyWith(
          color: nightText,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: nightDisplayMedium.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        displaySmall: nightDisplaySmall.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineLarge: nightHeadlineLarge.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: nightHeadlineMedium.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineSmall: nightHeadlineSmall.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleLarge: nightTitleLarge.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: nightTitleMedium.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleSmall: nightTitleSmall.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        bodyLarge: nightBodyLarge.copyWith(
          color: nightText,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
        bodyMedium: nightBodyMedium.copyWith(
          color: nightText,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: nightBodySmall.copyWith(
          color: nightGrey,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: nightLabelLarge.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: nightLabelMedium.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelSmall: nightLabelSmall.copyWith(
          color: nightGrey,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // Updated AppBar theme for dark mode
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: nightText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: nightTitleLarge.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: nightText,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: nightText,
          size: 24,
        ),
      ),

      // Updated Button themes for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkColorScheme.onPrimary,
          backgroundColor: darkColorScheme.primary,
          elevation: kElevationSmall,
          shadowColor: darkColorScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingLarge,
            vertical: kPaddingMedium,
        ),
          textStyle: nightLabelLarge.copyWith(
            color: darkColorScheme.onPrimary,
            fontWeight: FontWeight.w600,
      ),
          minimumSize: const Size(88, 48),
        ),
      ),

      // Updated TextButton theme for dark mode
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingMedium,
            vertical: kPaddingSmall,
        ),
          textStyle: nightLabelLarge.copyWith(
            color: darkColorScheme.primary,
            fontWeight: FontWeight.w600,
      ),
          minimumSize: const Size(88, 48),
        ),
      ),

      // Updated OutlinedButton theme for dark mode
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
          side: BorderSide(
            color: darkColorScheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingLarge,
            vertical: kPaddingMedium,
        ),
          textStyle: nightLabelLarge.copyWith(
            color: darkColorScheme.primary,
            fontWeight: FontWeight.w600,
      ),
          minimumSize: const Size(88, 48),
        ),
      ),

      // Updated IconButton theme for dark mode
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: nightText,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(kPaddingSmall),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
      ),
      ),

      // Updated FloatingActionButton theme for dark mode
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
        elevation: kElevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
      ),

      // Updated Card theme for dark mode
      cardTheme: CardTheme(
        color: darkColorScheme.surface,
        elevation: kElevationSmall,
        shadowColor: darkColorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          side: BorderSide(
            color: darkColorScheme.outlineVariant,
            width: 0.5,
        ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Updated Input Decoration theme for dark mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surface,
        hintStyle: nightBodyMedium.copyWith(
          color: nightGrey,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: nightBodyMedium.copyWith(
          color: nightText,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: nightGrey,
        suffixIconColor: nightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kPaddingMedium,
          vertical: kPaddingMedium,
        ),
        errorStyle: nightBodySmall.copyWith(
          color: darkColorScheme.error,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Updated Dialog theme for dark mode
      dialogTheme: DialogTheme(
        backgroundColor: darkColorScheme.surface,
        elevation: kElevationLarge,
        shadowColor: darkColorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
        titleTextStyle: nightTitleLarge.copyWith(
          color: nightText,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: nightBodyMedium.copyWith(
          color: nightText,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Updated BottomSheet theme for dark mode
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkColorScheme.surface,
        elevation: kElevationLarge,
        shadowColor: darkColorScheme.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadiusLarge),
          ),
        ),
      ),

      // Updated Divider theme for dark mode
      dividerTheme: DividerThemeData(
        color: darkColorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Add SnackBar theme for dark mode
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkColorScheme.surface,
        contentTextStyle: nightBodyMedium.copyWith(
          color: darkColorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Add Chip theme for dark mode
      chipTheme: ChipThemeData(
        backgroundColor: darkColorScheme.surfaceVariant,
        labelStyle: nightLabelMedium.copyWith(
          color: darkColorScheme.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: kPaddingSmall,
          vertical: kPaddingSmall / 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
      ),
    );
  }

  // Home screen tile colors (pastel for light, muted for night)
  static const Color tilePinkLight = Color(0xFFFFE4E0); // Pastel pink
  static const Color tileBlueLight = Color(0xFFE7F0FF); // Pastel blue
  static const Color tileYellowLight = Color(0xFFFFF4DC); // Pastel yellow

  static const Color tilePinkNight = Color(0xFF3A2B2B); // Muted dark pink
  static const Color tileBlueNight = Color(0xFF232B3A); // Muted dark blue
  static const Color tileYellowNight = Color(0xFF39362B); // Muted dark yellow
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 68,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((13 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, "assets/icons/ic_home.png", "Home", 0),
          _buildNavItem(context, "assets/icons/ic_upload.png", "Upload", 1),
          _buildNavItem(
              context, "assets/icons/ic_appointment.png", "Appointment", 2),
          _buildNavItem(context, "assets/icons/ic_profile.png", "Profile", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String iconPath, String label, int index) {
    final theme = Theme.of(context);
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 24,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface
                    .withOpacity(0.6), // Use color scheme
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface
                      .withOpacity(0.6), // Use color scheme
            ),
          ),
        ],
      ),
    );
  }
}

class AppDecorations {
  static BoxDecoration inputShadow = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}
