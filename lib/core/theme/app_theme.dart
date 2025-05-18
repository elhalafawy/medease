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
  
  static const double kElevationSmall = 2.0;
  static const double kElevationMedium = 4.0;
  static const double kElevationLarge = 8.0;

  // Brand Colors
  static const Color primaryColor = Color(0xFF022E5B);
  static const Color secondaryColor = Color(0xFF00264D);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF3F4F6);
  static const Color appBarBackgroundColor = Color(0xFFF8F9FB);
  static const Color darkBackground = Color(0xFF181A20);
  static const Color darkSurface = Color(0xFF23262F);
  
  // Text Colors
  static const Color textColor = Color(0xFF3C4A59);
  static const Color greyColor = Color(0xFFADADAD);
  static const Color darkText = Color(0xFFE5E7EB);
  static const Color darkGrey = Color(0xFF7B7F87);
  
  // Border Colors
  static const Color borderColor = Color(0xFFE8F3F1);
  static const Color darkBorder = Color(0xFF35383F);
  
  // Status Colors
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA000);
  
  // Booking colors
  static const Color bookingDayColor = Color(0xFF73D0ED); // Day selection
  static const Color bookingTimeColor = Color(0xFFEDAE73); // Time selection
  // Notification icon and background colors
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



  // Night mode colors
  static const Color nightBackground = Color.fromARGB(255, 10, 10, 10); // Pure black for OLED screens
  static const Color nightSurface = Color(0xFF121212);
  static const Color nightCard = Color(0xFF1A1A1A);
  static const Color nightDialog = Color(0xFF1A1A1A);
  static const Color nightInput = Color(0xFF1A1A1A);
  static const Color nightBorder = Color(0xFF2A2A2A);
  static const Color nightText = Color(0xFFE0E0E0);
  static const Color nightGrey = Color(0xFF9E9E9E);
  static const Color nightPrimary = Color.fromARGB(255, 2, 50, 104); // lighter blue
  static const Color nightSecondary = Color.fromARGB(255, 0, 47, 93); // lighter blue
  static const Color nightError = Color(0xFFB71C1C);
  static const Color nightSuccess = Color(0xFF1B5E20);
  static const Color nightWarning = Color(0xFFE65100);

  // Night mode notification colors
  static const Color nightNotifCalendarIcon = Color(0xFF3B82F6);
  static const Color nightNotifCalendarBg = Color(0xFF1E3A8A);
  static const Color nightNotifChatIcon = Color(0xFFEC4899);
  static const Color nightNotifChatBg = Color(0xFF831843);
  static const Color nightNotifMedicineIcon = Color(0xFFF59E0B);
  static const Color nightNotifMedicineBg = Color(0xFF78350F);
  static const Color nightNotifVaccineIcon = Color(0xFF06B6D4);
  static const Color nightNotifVaccineBg = Color(0xFF164E63);
  static const Color nightNotifUpdateIcon = Color(0xFFDC2626);
  static const Color nightNotifUpdateBg = Color(0xFF7F1D1D);
  static const Color nightNotifCardBorder = Color(0xFF374151);
  static const Color nightNotifPageBg = Color(0xFF111827);

  // Text Styles Constants
  static const double kFontSizeXS = 12.0;
  static const double kFontSizeSM = 14.0;
  static const double kFontSizeMD = 16.0;
  static const double kFontSizeLG = 18.0;
  static const double kFontSizeXL = 20.0;
  static const double kFontSize2XL = 24.0;
  static const double kFontSize3XL = 32.0;
  static const double kFontSize4XL = 40.0;

  // Text Styles
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

  // Night mode text styles
  static TextStyle get nightDisplayLarge => displayLarge.copyWith(color: nightText);
  static TextStyle get nightDisplayMedium => displayMedium.copyWith(color: nightText);
  static TextStyle get nightDisplaySmall => displaySmall.copyWith(color: nightText);
  static TextStyle get nightHeadlineLarge => headlineLarge.copyWith(color: nightText);
  static TextStyle get nightHeadlineMedium => headlineMedium.copyWith(color: nightText);
  static TextStyle get nightHeadlineSmall => headlineSmall.copyWith(color: nightText);
  static TextStyle get nightTitleLarge => titleLarge.copyWith(color: nightText);
  static TextStyle get nightTitleMedium => titleMedium.copyWith(color: nightText);
  static TextStyle get nightTitleSmall => titleSmall.copyWith(color: nightText);
  static TextStyle get nightBodyLarge => bodyLarge.copyWith(color: nightText);
  static TextStyle get nightBodyMedium => bodyMedium.copyWith(color: nightText);
  static TextStyle get nightBodySmall => bodySmall.copyWith(color: nightGrey);
  static TextStyle get nightLabelLarge => labelLarge.copyWith(color: nightText);
  static TextStyle get nightLabelMedium => labelMedium.copyWith(color: nightText);
  static TextStyle get nightLabelSmall => labelSmall.copyWith(color: nightGrey);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF022E5B),
        secondary: Color(0xFF00264D),
        error: errorColor,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF022E5B),
        onError: Colors.white,
        background: Color(0xFFF8F8F8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F8F8),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF022E5B)),
        titleTextStyle: TextStyle(
          color: Color(0xFF022E5B),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          minimumSize: const Size(120, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(120, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(100, 40),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF022E5B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.2),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF022E5B),
        ),
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: greyColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: headlineMedium,
        contentTextStyle: bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: primaryColor,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        selectedColor: primaryColor,
        labelStyle: const TextStyle(color: textColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: borderColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        onError: Colors.white,
        background: darkBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkText),
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: kPaddingLarge,
            horizontal: kPaddingXLarge,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
          ),
          elevation: 0,
          minimumSize: const Size(120, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            vertical: kPaddingLarge,
            horizontal: kPaddingXLarge,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
          ),
          minimumSize: const Size(120, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            vertical: kPaddingMedium,
            horizontal: kPaddingLarge,
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
          ),
          minimumSize: const Size(100, 40),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          borderSide: const BorderSide(color: errorColor, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kPaddingLarge,
          vertical: kPaddingLarge,
        ),
        errorStyle: const TextStyle(color: errorColor, fontWeight: FontWeight.w600),
        labelStyle: const TextStyle(color: darkText, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: darkGrey, fontWeight: FontWeight.normal),
      ),
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: darkDialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: headlineMedium.copyWith(color: darkText),
        contentTextStyle: bodyLarge.copyWith(color: darkText),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: primaryColor,
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: primaryColor,
        labelStyle: const TextStyle(color: darkText),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: darkBorder,
      ),
    );
  }

  static ThemeData get nightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: nightPrimary,
      scaffoldBackgroundColor: nightBackground,
      colorScheme: const ColorScheme.dark(
        primary: nightPrimary,
        secondary: nightSecondary,
        error: nightError,
        surface: nightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: nightText,
        onError: Colors.black,
        background: nightBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: nightSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: kPaddingLarge,
            horizontal: kPaddingXLarge,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
          ),
          elevation: 0,
          minimumSize: const Size(120, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: nightPrimary,
          side: const BorderSide(color: nightPrimary),
          padding: const EdgeInsets.symmetric(
            vertical: kPaddingLarge,
            horizontal: kPaddingXLarge,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
          ),
          minimumSize: const Size(120, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: nightPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: kPaddingMedium,
            horizontal: kPaddingLarge,
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
          ),
          minimumSize: const Size(100, 40),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: nightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: nightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: nightError, width: 1.2),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: nightText,
        ),
        hintStyle: const TextStyle(
          fontSize: 16,
          color: nightGrey,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: nightDisplayLarge,
        displayMedium: nightDisplayMedium,
        displaySmall: nightDisplaySmall,
        headlineLarge: nightHeadlineLarge,
        headlineMedium: nightHeadlineMedium,
        headlineSmall: nightHeadlineSmall,
        titleLarge: nightTitleLarge,
        titleMedium: nightTitleMedium,
        titleSmall: nightTitleSmall,
        bodyLarge: nightBodyLarge,
        bodyMedium: nightBodyMedium,
        bodySmall: nightBodySmall,
        labelLarge: nightLabelLarge,
        labelMedium: nightLabelMedium,
        labelSmall: nightLabelSmall,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: nightSurface,
        selectedItemColor: nightPrimary,
        unselectedItemColor: nightGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: nightText),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: nightGrey),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: nightDialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
        titleTextStyle: headlineMedium.copyWith(color: nightText),
        contentTextStyle: bodyLarge.copyWith(color: nightText),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: nightPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: nightBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: nightSurface,
        selectedColor: nightPrimary,
        labelStyle: const TextStyle(color: nightText),
        padding: const EdgeInsets.symmetric(
          horizontal: kPaddingMedium,
          vertical: kPaddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: nightPrimary,
        linearTrackColor: nightBorder,
      ),
    );
  }
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({super.key, required this.currentIndex, required this.onTap});

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
            color: Colors.black.withValues(alpha: 13),
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
          _buildNavItem(context, "assets/icons/ic_appointment.png", "Appointment", 2),
          _buildNavItem(context, "assets/icons/ic_profile.png", "Profile", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String iconPath, String label, int index) {
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
            color: isSelected ? theme.primaryColor : theme.bottomNavigationBarTheme.unselectedItemColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.primaryColor : theme.bottomNavigationBarTheme.unselectedItemColor,
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