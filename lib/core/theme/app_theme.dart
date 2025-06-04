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

  // Brand Colors (Consistent for both modes where applicable, or defined per mode)
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

  // Night mode colors (Standardized)
  static const Color nightBackground = Color(0xFF18191A);
  static const Color nightSurface =
      Color(0xFF242526); // Used for cards, dialogs, inputs
  static const Color nightCard = nightSurface; // Standardized
  static const Color nightDialog = nightSurface; // Standardized
  static const Color nightInput = nightSurface; // Standardized
  static const Color nightBorder = Color(0xFF3A3B3C);
  static const Color nightText = Color(0xFFE4E6EB);
  static const Color nightGrey = Color(0xFFB0B3B8);
  static const Color nightPrimary = Color.fromARGB(255, 2, 50, 104);
  static const Color nightSecondary = Color.fromARGB(255, 0, 47, 93);
  static const Color nightError =
      Color(0xFFEF9A9A); // Adjusted for dark mode visibility
  static const Color nightSuccess =
      Color(0xFFA5D6A7); // Adjusted for dark mode visibility
  static const Color nightWarning =
      Color(0xFFFFCC80); // Adjusted for dark mode visibility

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

  // Text Styles (Night Mode)
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
    // Define the color scheme for light mode
    const ColorScheme lightColorScheme = ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white, // Text/icons on primary color
      primaryContainer: secondaryColor, // A shade lighter than primary
      onPrimaryContainer: Colors.white, // Text/icons on primary container
      secondary: secondaryColor,
      onSecondary: Colors.white, // Text/icons on secondary color
      secondaryContainer:
          Color(0xFFE0E0E0), // Example secondary container color
      onSecondaryContainer: textColor, // Text/icons on secondary container
      tertiary: bookingTimeColor, // Example tertiary color
      onTertiary: Colors.white, // Text/icons on tertiary color
      tertiaryContainer: Color(0xFFFFECB3), // Example tertiary container color
      onTertiaryContainer: textColor, // Text/icons on tertiary container
      error: errorColor,
      onError: Colors.white, // Text/icons on error color
      errorContainer: Color(0xFFFFCDD2), // Example error container color
      onErrorContainer: textColor, // Text/icons on error container
      background: backgroundColor, // Main background color
      onBackground: textColor, // Text/icons on background
      surface: Colors.white, // Card, dialog, sheet backgrounds
      onSurface: textColor, // Text/icons on surface
      surfaceVariant: Color(0xFFE0E0E0), // Less prominent surface
      onSurfaceVariant: greyColor, // Text/icons on surface variant
      outline: borderColor, // Borders and dividers
      outlineVariant: greyColor, // Less prominent borders
      shadow: Colors.black54, // Shadows
      scrim: Colors.black54, // Scrim for modals
      inverseSurface:
          darkBackground, // For elements on dark background in light theme
      onInverseSurface: darkText, // Text/icons on inverse surface
      inversePrimary: nightPrimary, // Primary color for inverse theme
      surfaceTint: primaryColor, // Surface tint color
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme, // Use the defined light color scheme
      primaryColor: primaryColor, // Keep primaryColor for older widgets
      scaffoldBackgroundColor: lightColorScheme.background,

      // Define Text Themes using the defined text styles
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

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        foregroundColor: textColor, // Color of icons and text in AppBar
        elevation: kElevationSmall,
        titleTextStyle: titleLarge.copyWith(color: textColor),
        iconTheme: const IconThemeData(color: textColor),
        actionsIconTheme: const IconThemeData(color: textColor),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: lightColorScheme.onPrimary,
          backgroundColor: lightColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingLarge, vertical: kPaddingMedium),
          textStyle: labelLarge.copyWith(color: lightColorScheme.onPrimary),
          elevation: kElevationMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingMedium, vertical: kPaddingSmall),
          textStyle: labelLarge.copyWith(color: lightColorScheme.primary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          side: BorderSide(color: lightColorScheme.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingLarge, vertical: kPaddingMedium),
          textStyle: labelLarge.copyWith(color: lightColorScheme.primary),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textColor,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.secondary,
        foregroundColor: lightColorScheme.onSecondary,
        elevation: kElevationLarge,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: lightColorScheme.surface,
        elevation: kElevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          side: BorderSide(color: lightColorScheme.outlineVariant, width: 0.5),
        ),
        margin:
            EdgeInsets.zero, // Cards usually have margin from parent padding
      ),

      // Input Decoration Theme (for TextFields, TextFormFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surface,
        hintStyle: bodyMedium.copyWith(color: greyColor),
        labelStyle: bodyMedium.copyWith(color: textColor),
        prefixIconColor: greyColor,
        suffixIconColor: greyColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: lightColorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: lightColorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: lightColorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: lightColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: kPaddingMedium, vertical: kPaddingMedium),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: lightColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
        titleTextStyle: titleLarge.copyWith(color: textColor),
        contentTextStyle: bodyMedium.copyWith(color: textColor),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightColorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Add more widget themes as needed (e.g., TabBarTheme, SliderTheme, etc.)
      // You can continue adding more specific widget themes here following the same pattern.

      // Example: ToggleButtonsThemeData
      // toggleButtonsTheme: ToggleButtonsThemeData(
      //   selectedColor: lightColorScheme.onPrimary,
      //   color: lightColorScheme.primary,
      //   fillColor: lightColorScheme.primary,
      //   // ... other properties
      // ),

      // Example: SliderThemeData
      // sliderTheme: SliderThemeData(
      //   activeTrackColor: lightColorScheme.primary,
      //   inactiveTrackColor: lightColorScheme.primary.withOpacity(0.24),
      //   thumbColor: lightColorScheme.primary,
      //   // ... other properties
      // ),
    );
  }

  // Night Theme
  static ThemeData get nightTheme {
    // Define the color scheme for dark mode
    const ColorScheme darkColorScheme = ColorScheme.dark(
      primary: nightPrimary,
      onPrimary: Colors.white,
      primaryContainer: nightSecondary,
      onPrimaryContainer: Colors.white,
      secondary: nightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF3A3B3C), // Example dark secondary container
      onSecondaryContainer: nightText,
      tertiary: bookingDayColor, // Example tertiary color for dark mode
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF5C403F), // Example dark tertiary container
      onTertiaryContainer: nightText,
      error: nightError, // Using adjusted dark error color
      onError: Colors.black, // Text/icons on error color in dark mode
      errorContainer: Color(0xFF451919), // Example dark error container
      onErrorContainer: nightText,
      background: nightBackground, // Main dark background color
      onBackground: nightText, // Text/icons on dark background
      surface: nightSurface, // Card, dialog, sheet backgrounds in dark mode
      onSurface: nightText, // Text/icons on dark surface
      surfaceVariant: Color(0xFF3A3B3C), // Less prominent dark surface
      onSurfaceVariant: nightGrey, // Text/icons on dark surface variant
      outline: nightBorder, // Dark borders and dividers
      outlineVariant: nightGrey, // Less prominent dark borders
      shadow: Colors.black87, // Darker shadows
      scrim: Colors.black87, // Scrim for modals in dark mode
      inverseSurface:
          backgroundColor, // For elements on light background in dark theme
      onInverseSurface: textColor, // Text/icons on inverse surface
      inversePrimary: primaryColor, // Primary color for inverse theme
      surfaceTint: nightPrimary, // Surface tint color in dark mode
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Indicate this is a dark theme
      colorScheme: darkColorScheme, // Use the defined dark color scheme
      primaryColor: nightPrimary, // Keep primaryColor for older widgets
      scaffoldBackgroundColor: darkColorScheme.background,

      // Define Text Themes using the defined night text styles
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

      // AppBar Theme (Dark Mode)
      appBarTheme: AppBarTheme(
        backgroundColor:
            darkColorScheme.surface, // Use surface color for consistency
        foregroundColor: nightText, // Color of icons and text in AppBar
        elevation: kElevationSmall,
        titleTextStyle: nightTitleLarge.copyWith(color: nightText),
        iconTheme: const IconThemeData(color: nightText),
        actionsIconTheme: const IconThemeData(color: nightText),
      ),

      // Button Themes (Dark Mode)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkColorScheme.onPrimary,
          backgroundColor: darkColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingLarge, vertical: kPaddingMedium),
          textStyle: nightLabelLarge.copyWith(color: darkColorScheme.onPrimary),
          elevation: kElevationMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingMedium, vertical: kPaddingSmall),
          textStyle: nightLabelLarge.copyWith(color: darkColorScheme.primary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
          side: BorderSide(color: darkColorScheme.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingLarge, vertical: kPaddingMedium),
          textStyle: nightLabelLarge.copyWith(color: darkColorScheme.primary),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: nightText,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.secondary,
        foregroundColor: darkColorScheme.onSecondary,
        elevation: kElevationLarge,
      ),

      // Card Theme (Dark Mode)
      cardTheme: CardThemeData(
        color: darkColorScheme.surface,
        elevation: kElevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          side: BorderSide(color: darkColorScheme.outlineVariant, width: 0.5),
        ),
        margin:
            EdgeInsets.zero, // Cards usually have margin from parent padding
      ),

      // Input Decoration Theme (Dark Mode)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surface, // Use color from color scheme
        hintStyle: nightBodyMedium.copyWith(color: nightGrey),
        labelStyle: nightBodyMedium.copyWith(color: nightText),
        prefixIconColor: nightGrey,
        suffixIconColor: nightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.outline,
              width: 1), // Use color from color scheme
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.outline,
              width: 1), // Use color from color scheme
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.primary,
              width: 2), // Use color from color scheme
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.error,
              width: 1), // Use color from color scheme
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
              color: darkColorScheme.error,
              width: 2), // Use color from color scheme
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: kPaddingMedium, vertical: kPaddingMedium),
      ),

      // Dialog Theme (Dark Mode)
      dialogTheme: DialogThemeData(
        backgroundColor: darkColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
        titleTextStyle: nightTitleLarge.copyWith(color: nightText),
        contentTextStyle: nightBodyMedium.copyWith(color: nightText),
      ),

      // Bottom Sheet Theme (Dark Mode)
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkColorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
        ),
      ),

      // Divider Theme (Dark Mode)
      dividerTheme: DividerThemeData(
        color: darkColorScheme.outlineVariant, // Use color from color scheme
        thickness: 1,
        space: 1,
      ),

      // Add more widget themes as needed
      // Example: ToggleButtonsThemeData
      // toggleButtonsTheme: ToggleButtonsThemeData(
      //   selectedColor: darkColorScheme.onPrimary,
      //   color: darkColorScheme.primary,
      //   fillColor: darkColorScheme.primary,
      //   // ... other properties
      // ),

      // Example: SliderThemeData
      // sliderTheme: SliderThemeData(
      //   activeTrackColor: darkColorScheme.primary,
      //   inactiveTrackColor: darkColorScheme.primary.withOpacity(0.24),
      //   thumbColor: darkColorScheme.primary,
      //   // ... other properties
      // ),
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
