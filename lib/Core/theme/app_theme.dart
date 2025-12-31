import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  /// Light Theme (Golden/Warm Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primeryColor,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primeryColor, // Golden
        secondary: AppColors.lightGoldenAccent, // Brighter gold
        surface: AppColors.lightSurface, // Warm cream
        background: AppColors.lightBackground, // Warm ivory
        error: AppColors.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary, // Dark brown
        onBackground: AppColors.lightTextPrimary, // Dark brown
        onError: Colors.white,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightTextFieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightTextFieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightTextFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primeryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.lightTextTertiary),
        hintStyle: const TextStyle(color: AppColors.lightTextTertiary),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.lightCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primeryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primeryColor,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
      ),
      
      // Text Theme with Google Fonts Poppins (Golden/Warm Theme)
      textTheme: TextTheme(
        // Display styles
        displayLarge: GoogleFonts.poppins(color: AppColors.lightTextPrimary),
        displayMedium: GoogleFonts.poppins(color: AppColors.lightTextPrimary),
        displaySmall: GoogleFonts.poppins(color: AppColors.lightTextPrimary),
        
        // Headline styles
        headlineLarge: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        
        // Title styles
        titleLarge: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        
        // Body styles
        bodyLarge: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.poppins(
          color: AppColors.lightTextTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        
        // Label styles
        labelLarge: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.poppins(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.poppins(
          color: AppColors.lightTextTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Custom Text Styles Extension (accessible via Theme.of(context).extension<AppTextStyles>())
      extensions: <ThemeExtension<dynamic>>[
        AppTextStyles.light,
      ],
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.textFieldBoderColor,
        thickness: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomBarColor,
        selectedItemColor: AppColors.primeryColor,
        unselectedItemColor: AppColors.bottomBarIconColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Dark Theme (Default for this app)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primeryColor,
      scaffoldBackgroundColor: AppColors.blackColor,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primeryColor,
        secondary: AppColors.lightPurple,
        surface: AppColors.containerColor,
        background: AppColors.blackColor,
        error: AppColors.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blackColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.textFieldBoderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.textFieldIconColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primeryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textFieldSubTitleColor),
        hintStyle: const TextStyle(color: AppColors.textFieldSubTitleColor),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.containerColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primeryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primeryColor,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      
      // Text Theme with Google Fonts Poppins
      textTheme: TextTheme(
        // Display styles
        displayLarge: GoogleFonts.poppins(color: Colors.white),
        displayMedium: GoogleFonts.poppins(color: Colors.white),
        displaySmall: GoogleFonts.poppins(color: Colors.white),
        
        // Headline styles
        headlineLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        
        // Title styles
        titleLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        
        // Body styles
        bodyLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.poppins(
          color: AppColors.subTitleColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        
        // Label styles
        labelLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.poppins(
          color: AppColors.subTitleColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Custom Text Styles Extension (accessible via Theme.of(context).extension<AppTextStyles>())
      extensions: <ThemeExtension<dynamic>>[
        AppTextStyles.dark,
      ],
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.textFieldBoderColor,
        thickness: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomBarColor,
        selectedItemColor: AppColors.primeryColor,
        unselectedItemColor: AppColors.bottomBarIconColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

/// Custom Text Styles Extension for Auth screens and app-wide usage
/// All styles use Google Fonts Poppins
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle authTitlePrimary;      // 20px, w600, primary color (Sign Up, Sign In, etc.)
  final TextStyle authTitleWhite;       // 20px, w600, white
  final TextStyle authSubtitlePrimary;  // 14px, w500, primary color
  final TextStyle authSubtitleWhite;   // 14px, w500, white
  final TextStyle authBodyRegular;      // 14px, w400, white with opacity
  final TextStyle authBodyMedium;      // 14px, w500, white
  final TextStyle authBodyGray;        // 14px, w500, gray
  final TextStyle authBodyPrimary;      // 14px, w600, primary color
  final TextStyle authHintText;        // 12px, w500, textFieldSubTitleColor
  final TextStyle authOTPText;         // 14px, w500, white
  final TextStyle authOTPLarge;        // 20px, w600, gray
  final TextStyle authTimerText;       // 16px, w500, white
  final TextStyle authResendText;      // 16px, w600, primary color
  final TextStyle authPasswordTitle;   // 16px, w500, white
  final TextStyle authGoogleButton;    // 14px, w500, gray/white
  final TextStyle bottomNavLabelSelected; // 10px, w600, primary color (Manrope)
  final TextStyle bottomNavLabelUnselected; // 10px, w600, bottomBarIconColor (Manrope)
  final TextStyle homeGreetingTitle;   // 20px, w500, white/black (greeting title)
  final TextStyle homeGreetingSubtitle; // 14px, w500, textFieldIconColor (greeting subtitle)
  final TextStyle homeCardTitle;       // 20px, w600, white/black (card title)
  final TextStyle homeCardDescription; // 14px, w500, white/black (card description)
  final TextStyle imageCreatedTitle;  // 16px, w500, white/black (screen title)
  final TextStyle imageCreatedError;  // 12px, w500, white/black (error message)
  final TextStyle imageCreatedPollingTitle; // 14px, w500, white/black (polling title)
  final TextStyle imageCreatedPollingTime; // 12px, w400, textFieldIconColor (elapsed time)
  final TextStyle imageCreatedPollingSubtitle; // 10px, w400, textFieldIconColor (polling subtitle)
  final TextStyle imageCreatedPromptText; // 14px, w500, white/black (prompt text)
  final TextStyle imageCreatedPromptHint; // 14px, w500, textFieldIconColor (prompt hint)
  final TextStyle imageGenerateSectionTitle; // 16px, w500, white/black (section titles)
  final TextStyle imageGeneratePromptText; // 12px, w500, white/black (prompt text field)
  final TextStyle imageGeneratePromptHint; // 12px, w500, textFieldIconColor (prompt hint)
  final TextStyle imageGenerateAISuggestion; // 12px, w500, white/black (AI suggestion button)
  final TextStyle imageGenerateLoadingPercent; // 48px, w600, white/black (loading percentage)
  final TextStyle imageGenerateLoadingTitle; // 20px, w600, white/black (loading main title)
  final TextStyle imageGenerateLoadingStage; // 16px, w500, primary/white (loading stage)
  final TextStyle imageGenerateLoadingTime; // 12px, w400, white with opacity (elapsed time)
  final TextStyle imageGenerateStageLabel; // 10px, w400/w600, primary/white with opacity (stage labels)
  final TextStyle onboardingTitle; // 22px, w600, white/black (onboarding title)
  final TextStyle onboardingSubtitle; // 16px, w400, white70/black54 (onboarding subtitle)
  final TextStyle onboardingButton; // 16px, w500, white/black (onboarding button)
  final TextStyle profileName; // 16px, w500, primary/black (profile name)
  final TextStyle profileEmail; // 12px, w500, white/black (profile email)
  final TextStyle profileListItemTitle; // 14px, w500, white/black (list item title)
  final TextStyle profileListItemSubtitle; // 13px, w400, subTitleColor/black54 (list item subtitle)
  final TextStyle profileScreenTitle; // 20px, w600, white/black (screen title)
  final TextStyle profileScreenSubtitle; // 14px, w500, textFieldSubTitleColor (screen subtitle)
  final TextStyle profileSectionTitle; // 16px, w600, white/black (section title)
  final TextStyle profileHelperText; // 12px, w500, white/black (helper text)
  final TextStyle profileContactInfo; // 12px, w500, white/black (contact info)
  final TextStyle profileCardTitle; // 11px, w700, white/black (card title)
  final TextStyle profileBodyText; // 12px, w500, white/black (body text)
  final TextStyle profileDateText; // 10px, w400, errorColor/black54 (date text)
  // Custom Widget Text Styles
  final TextStyle customTextFieldLabel; // 14px, w500, white/black (text field label)
  final TextStyle customTextFieldInput; // 14px, w500, white/black (text field input)
  final TextStyle customButtonText; // 16px, w500, white (button text)
  final TextStyle normalTextTitle; // 16px, w500, white/black (normal text title)
  final TextStyle normalTextSubtitle; // 14px, w400, white/black (normal text subtitle)
  final TextStyle promptContainerText; // 10px, w400, white/black (prompt container text)
  final TextStyle sizeContainerText; // 11px, w500, white/black (size container text)
  final TextStyle customTextRichText1; // 14px, w500, textFieldSubTitleColor/black54 (text rich part 1)
  final TextStyle customTextRichText2; // 14px, w500, primary/primary (text rich part 2)
  final TextStyle passwordTextStyle; // 10px, w400, white/black (password requirement text)
  final TextStyle homeAlignText; // 16px, w500, white/black (home align text)
  final TextStyle alignTextStyle; // variable, variable, white/black (aligned text)

  const AppTextStyles({
    required this.authTitlePrimary,
    required this.authTitleWhite,
    required this.authSubtitlePrimary,
    required this.authSubtitleWhite,
    required this.authBodyRegular,
    required this.authBodyMedium,
    required this.authBodyGray,
    required this.authBodyPrimary,
    required this.authHintText,
    required this.authOTPText,
    required this.authOTPLarge,
    required this.authTimerText,
    required this.authResendText,
    required this.authPasswordTitle,
    required this.authGoogleButton,
    required this.bottomNavLabelSelected,
    required this.bottomNavLabelUnselected,
    required this.homeGreetingTitle,
    required this.homeGreetingSubtitle,
    required this.homeCardTitle,
    required this.homeCardDescription,
    required this.imageCreatedTitle,
    required this.imageCreatedError,
    required this.imageCreatedPollingTitle,
    required this.imageCreatedPollingTime,
    required this.imageCreatedPollingSubtitle,
    required this.imageCreatedPromptText,
    required this.imageCreatedPromptHint,
    required this.imageGenerateSectionTitle,
    required this.imageGeneratePromptText,
    required this.imageGeneratePromptHint,
    required this.imageGenerateAISuggestion,
    required this.imageGenerateLoadingPercent,
    required this.imageGenerateLoadingTitle,
    required this.imageGenerateLoadingStage,
    required this.imageGenerateLoadingTime,
    required this.imageGenerateStageLabel,
    required this.onboardingTitle,
    required this.onboardingSubtitle,
    required this.onboardingButton,
    required this.profileName,
    required this.profileEmail,
    required this.profileListItemTitle,
    required this.profileListItemSubtitle,
    required this.profileScreenTitle,
    required this.profileScreenSubtitle,
    required this.profileSectionTitle,
    required this.profileHelperText,
    required this.profileContactInfo,
    required this.profileCardTitle,
    required this.profileBodyText,
    required this.profileDateText,
    required this.customTextFieldLabel,
    required this.customTextFieldInput,
    required this.customButtonText,
    required this.normalTextTitle,
    required this.normalTextSubtitle,
    required this.promptContainerText,
    required this.sizeContainerText,
    required this.customTextRichText1,
    required this.customTextRichText2,
    required this.passwordTextStyle,
    required this.homeAlignText,
    required this.alignTextStyle,
  });

  // Light Theme Text Styles
  static AppTextStyles get light {
    return AppTextStyles(
      authTitlePrimary: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primeryColor,
      ),
      authTitleWhite: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      authSubtitlePrimary: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primeryColor,
      ),
      authSubtitleWhite: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextSecondary,
      ),
      authBodyRegular: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextTertiary,
      ),
      authBodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextSecondary,
      ),
      authBodyGray: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextTertiary,
      ),
      authBodyPrimary: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primeryColor,
      ),
      authHintText: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextTertiary,
      ),
      authOTPText: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextPrimary,
      ),
      authOTPLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextSecondary,
      ),
      authTimerText: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextPrimary,
      ),
      authResendText: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primeryColor,
      ),
      authPasswordTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextPrimary,
      ),
      authGoogleButton: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextSecondary,
      ),
      bottomNavLabelSelected: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.primeryColor,
      ),
      bottomNavLabelUnselected: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.bottomBarIconColor,
      ),
      homeGreetingTitle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      homeGreetingSubtitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldIconColor,
      ),
      homeCardTitle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      homeCardDescription: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      imageCreatedTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      imageCreatedError: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      imageCreatedPollingTitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      imageCreatedPollingTime: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textFieldIconColor,
      ),
      imageCreatedPollingSubtitle: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.textFieldIconColor,
      ),
      imageCreatedPromptText: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      imageCreatedPromptHint: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldIconColor,
      ),
      imageGenerateSectionTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageGeneratePromptText: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageGeneratePromptHint: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldIconColor,
      ),
      imageGenerateAISuggestion: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageGenerateLoadingPercent: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      imageGenerateLoadingTitle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      imageGenerateLoadingStage: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primeryColor,
      ),
      imageGenerateLoadingTime: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.7),
      ),
      imageGenerateStageLabel: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.5),
      ),
      onboardingTitle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      onboardingSubtitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
      onboardingButton: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileName: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primeryColor,
      ),
      profileEmail: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileListItemTitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileListItemSubtitle: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.subTitleColor,
      ),
      profileScreenTitle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      profileScreenSubtitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldSubTitleColor,
      ),
      profileSectionTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      profileHelperText: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileContactInfo: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileCardTitle: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      profileBodyText: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileDateText: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.errorColor,
      ),
      // Custom Widget Text Styles
      customTextFieldLabel: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      customTextFieldInput: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      customButtonText: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      normalTextTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      normalTextSubtitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      promptContainerText: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      sizeContainerText: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      customTextRichText1: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldSubTitleColor,
      ),
      customTextRichText2: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primeryColor,
      ),
      passwordTextStyle: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      homeAlignText: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      alignTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  // Dark Theme Text Styles
  static AppTextStyles get dark {
    return AppTextStyles(
      authTitlePrimary: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primeryColor,
      ),
      authTitleWhite: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      authSubtitlePrimary: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primeryColor,
      ),
      authSubtitleWhite: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      authBodyRegular: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
      authBodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      authBodyGray: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.grayColor,
      ),
      authBodyPrimary: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primeryColor,
      ),
      authHintText: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldSubTitleColor,
      ),
      authOTPText: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      authOTPLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.grayColor,
      ),
      authTimerText: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      authResendText: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primeryColor,
      ),
      authPasswordTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      authGoogleButton: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bottomNavLabelSelected: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.primeryColor,
      ),
      bottomNavLabelUnselected: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.bottomBarIconColor,
      ),
      homeGreetingTitle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      homeGreetingSubtitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldIconColor,
      ),
      homeCardTitle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      homeCardDescription: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageCreatedTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageCreatedError: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageCreatedPollingTitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageCreatedPollingTime: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textFieldIconColor,
      ),
      imageCreatedPollingSubtitle: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.textFieldIconColor,
      ),
      imageCreatedPromptText: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageCreatedPromptHint: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldIconColor,
      ),
      imageGenerateSectionTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageGeneratePromptText: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageGeneratePromptHint: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldIconColor,
      ),
      imageGenerateAISuggestion: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      imageGenerateLoadingPercent: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      imageGenerateLoadingTitle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      imageGenerateLoadingStage: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primeryColor,
      ),
      imageGenerateLoadingTime: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.7),
      ),
      imageGenerateStageLabel: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.5),
      ),
      onboardingTitle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      onboardingSubtitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
      onboardingButton: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileName: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primeryColor,
      ),
      profileEmail: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileListItemTitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileListItemSubtitle: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.subTitleColor,
      ),
      profileScreenTitle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      profileScreenSubtitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldSubTitleColor,
      ),
      profileSectionTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      profileHelperText: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileContactInfo: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileCardTitle: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      profileBodyText: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      profileDateText: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.errorColor,
      ),
      // Custom Widget Text Styles
      customTextFieldLabel: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      customTextFieldInput: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      customButtonText: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      normalTextTitle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      normalTextSubtitle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      promptContainerText: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      sizeContainerText: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      customTextRichText1: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textFieldSubTitleColor,
      ),
      customTextRichText2: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primeryColor,
      ),
      passwordTextStyle: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      homeAlignText: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      alignTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  @override
  ThemeExtension<AppTextStyles> copyWith({
    TextStyle? authTitlePrimary,
    TextStyle? authTitleWhite,
    TextStyle? authSubtitlePrimary,
    TextStyle? authSubtitleWhite,
    TextStyle? authBodyRegular,
    TextStyle? authBodyMedium,
    TextStyle? authBodyGray,
    TextStyle? authBodyPrimary,
    TextStyle? authHintText,
    TextStyle? authOTPText,
    TextStyle? authOTPLarge,
    TextStyle? authTimerText,
    TextStyle? authResendText,
    TextStyle? authPasswordTitle,
    TextStyle? authGoogleButton,
    TextStyle? bottomNavLabelSelected,
    TextStyle? bottomNavLabelUnselected,
    TextStyle? homeGreetingTitle,
    TextStyle? homeGreetingSubtitle,
    TextStyle? homeCardTitle,
    TextStyle? homeCardDescription,
    TextStyle? imageCreatedTitle,
    TextStyle? imageCreatedError,
    TextStyle? imageCreatedPollingTitle,
    TextStyle? imageCreatedPollingTime,
    TextStyle? imageCreatedPollingSubtitle,
    TextStyle? imageCreatedPromptText,
    TextStyle? imageCreatedPromptHint,
    TextStyle? imageGenerateSectionTitle,
    TextStyle? imageGeneratePromptText,
    TextStyle? imageGeneratePromptHint,
    TextStyle? imageGenerateAISuggestion,
    TextStyle? imageGenerateLoadingPercent,
    TextStyle? imageGenerateLoadingTitle,
    TextStyle? imageGenerateLoadingStage,
    TextStyle? imageGenerateLoadingTime,
    TextStyle? imageGenerateStageLabel,
    TextStyle? onboardingTitle,
    TextStyle? onboardingSubtitle,
    TextStyle? onboardingButton,
  }) {
    return AppTextStyles(
      authTitlePrimary: authTitlePrimary ?? this.authTitlePrimary,
      authTitleWhite: authTitleWhite ?? this.authTitleWhite,
      authSubtitlePrimary: authSubtitlePrimary ?? this.authSubtitlePrimary,
      authSubtitleWhite: authSubtitleWhite ?? this.authSubtitleWhite,
      authBodyRegular: authBodyRegular ?? this.authBodyRegular,
      authBodyMedium: authBodyMedium ?? this.authBodyMedium,
      authBodyGray: authBodyGray ?? this.authBodyGray,
      authBodyPrimary: authBodyPrimary ?? this.authBodyPrimary,
      authHintText: authHintText ?? this.authHintText,
      authOTPText: authOTPText ?? this.authOTPText,
      authOTPLarge: authOTPLarge ?? this.authOTPLarge,
      authTimerText: authTimerText ?? this.authTimerText,
      authResendText: authResendText ?? this.authResendText,
      authPasswordTitle: authPasswordTitle ?? this.authPasswordTitle,
      authGoogleButton: authGoogleButton ?? this.authGoogleButton,
      bottomNavLabelSelected: bottomNavLabelSelected ?? this.bottomNavLabelSelected,
      bottomNavLabelUnselected: bottomNavLabelUnselected ?? this.bottomNavLabelUnselected,
      homeGreetingTitle: homeGreetingTitle ?? this.homeGreetingTitle,
      homeGreetingSubtitle: homeGreetingSubtitle ?? this.homeGreetingSubtitle,
      homeCardTitle: homeCardTitle ?? this.homeCardTitle,
      homeCardDescription: homeCardDescription ?? this.homeCardDescription,
      imageCreatedTitle: imageCreatedTitle ?? this.imageCreatedTitle,
      imageCreatedError: imageCreatedError ?? this.imageCreatedError,
      imageCreatedPollingTitle: imageCreatedPollingTitle ?? this.imageCreatedPollingTitle,
      imageCreatedPollingTime: imageCreatedPollingTime ?? this.imageCreatedPollingTime,
      imageCreatedPollingSubtitle: imageCreatedPollingSubtitle ?? this.imageCreatedPollingSubtitle,
      imageCreatedPromptText: imageCreatedPromptText ?? this.imageCreatedPromptText,
      imageCreatedPromptHint: imageCreatedPromptHint ?? this.imageCreatedPromptHint,
      imageGenerateSectionTitle: imageGenerateSectionTitle ?? this.imageGenerateSectionTitle,
      imageGeneratePromptText: imageGeneratePromptText ?? this.imageGeneratePromptText,
      imageGeneratePromptHint: imageGeneratePromptHint ?? this.imageGeneratePromptHint,
      imageGenerateAISuggestion: imageGenerateAISuggestion ?? this.imageGenerateAISuggestion,
      imageGenerateLoadingPercent: imageGenerateLoadingPercent ?? this.imageGenerateLoadingPercent,
      imageGenerateLoadingTitle: imageGenerateLoadingTitle ?? this.imageGenerateLoadingTitle,
      imageGenerateLoadingStage: imageGenerateLoadingStage ?? this.imageGenerateLoadingStage,
      imageGenerateLoadingTime: imageGenerateLoadingTime ?? this.imageGenerateLoadingTime,
      imageGenerateStageLabel: imageGenerateStageLabel ?? this.imageGenerateStageLabel,
      onboardingTitle: onboardingTitle ?? this.onboardingTitle,
      onboardingSubtitle: onboardingSubtitle ?? this.onboardingSubtitle,
      onboardingButton: onboardingButton ?? this.onboardingButton,
      profileName: profileName ?? this.profileName,
      profileEmail: profileEmail ?? this.profileEmail,
      profileListItemTitle: profileListItemTitle ?? this.profileListItemTitle,
      profileListItemSubtitle: profileListItemSubtitle ?? this.profileListItemSubtitle,
      profileScreenTitle: profileScreenTitle ?? this.profileScreenTitle,
      profileScreenSubtitle: profileScreenSubtitle ?? this.profileScreenSubtitle,
      profileSectionTitle: profileSectionTitle ?? this.profileSectionTitle,
      profileHelperText: profileHelperText ?? this.profileHelperText,
      profileContactInfo: profileContactInfo ?? this.profileContactInfo,
      profileCardTitle: profileCardTitle ?? this.profileCardTitle,
      profileBodyText: profileBodyText ?? this.profileBodyText,
      profileDateText: profileDateText ?? this.profileDateText,
      customTextFieldLabel: customTextFieldLabel ?? this.customTextFieldLabel,
      customTextFieldInput: customTextFieldInput ?? this.customTextFieldInput,
      customButtonText: customButtonText ?? this.customButtonText,
      normalTextTitle: normalTextTitle ?? this.normalTextTitle,
      normalTextSubtitle: normalTextSubtitle ?? this.normalTextSubtitle,
      promptContainerText: promptContainerText ?? this.promptContainerText,
      sizeContainerText: sizeContainerText ?? this.sizeContainerText,
      customTextRichText1: customTextRichText1 ?? this.customTextRichText1,
      customTextRichText2: customTextRichText2 ?? this.customTextRichText2,
      passwordTextStyle: passwordTextStyle ?? this.passwordTextStyle,
      homeAlignText: homeAlignText ?? this.homeAlignText,
      alignTextStyle: alignTextStyle ?? this.alignTextStyle,
    );
  }

  @override
  ThemeExtension<AppTextStyles> lerp(
    ThemeExtension<AppTextStyles>? other,
    double t,
  ) {
    if (other is! AppTextStyles) {
      return this;
    }

    return AppTextStyles(
      authTitlePrimary: TextStyle.lerp(authTitlePrimary, other.authTitlePrimary, t)!,
      authTitleWhite: TextStyle.lerp(authTitleWhite, other.authTitleWhite, t)!,
      authSubtitlePrimary: TextStyle.lerp(authSubtitlePrimary, other.authSubtitlePrimary, t)!,
      authSubtitleWhite: TextStyle.lerp(authSubtitleWhite, other.authSubtitleWhite, t)!,
      authBodyRegular: TextStyle.lerp(authBodyRegular, other.authBodyRegular, t)!,
      authBodyMedium: TextStyle.lerp(authBodyMedium, other.authBodyMedium, t)!,
      authBodyGray: TextStyle.lerp(authBodyGray, other.authBodyGray, t)!,
      authBodyPrimary: TextStyle.lerp(authBodyPrimary, other.authBodyPrimary, t)!,
      authHintText: TextStyle.lerp(authHintText, other.authHintText, t)!,
      authOTPText: TextStyle.lerp(authOTPText, other.authOTPText, t)!,
      authOTPLarge: TextStyle.lerp(authOTPLarge, other.authOTPLarge, t)!,
      authTimerText: TextStyle.lerp(authTimerText, other.authTimerText, t)!,
      authResendText: TextStyle.lerp(authResendText, other.authResendText, t)!,
      authPasswordTitle: TextStyle.lerp(authPasswordTitle, other.authPasswordTitle, t)!,
      authGoogleButton: TextStyle.lerp(authGoogleButton, other.authGoogleButton, t)!,
      bottomNavLabelSelected: TextStyle.lerp(bottomNavLabelSelected, other.bottomNavLabelSelected, t)!,
      bottomNavLabelUnselected: TextStyle.lerp(bottomNavLabelUnselected, other.bottomNavLabelUnselected, t)!,
      homeGreetingTitle: TextStyle.lerp(homeGreetingTitle, other.homeGreetingTitle, t)!,
      homeGreetingSubtitle: TextStyle.lerp(homeGreetingSubtitle, other.homeGreetingSubtitle, t)!,
      homeCardTitle: TextStyle.lerp(homeCardTitle, other.homeCardTitle, t)!,
      homeCardDescription: TextStyle.lerp(homeCardDescription, other.homeCardDescription, t)!,
      imageCreatedTitle: TextStyle.lerp(imageCreatedTitle, other.imageCreatedTitle, t)!,
      imageCreatedError: TextStyle.lerp(imageCreatedError, other.imageCreatedError, t)!,
      imageCreatedPollingTitle: TextStyle.lerp(imageCreatedPollingTitle, other.imageCreatedPollingTitle, t)!,
      imageCreatedPollingTime: TextStyle.lerp(imageCreatedPollingTime, other.imageCreatedPollingTime, t)!,
      imageCreatedPollingSubtitle: TextStyle.lerp(imageCreatedPollingSubtitle, other.imageCreatedPollingSubtitle, t)!,
      imageCreatedPromptText: TextStyle.lerp(imageCreatedPromptText, other.imageCreatedPromptText, t)!,
      imageCreatedPromptHint: TextStyle.lerp(imageCreatedPromptHint, other.imageCreatedPromptHint, t)!,
      imageGenerateSectionTitle: TextStyle.lerp(imageGenerateSectionTitle, other.imageGenerateSectionTitle, t)!,
      imageGeneratePromptText: TextStyle.lerp(imageGeneratePromptText, other.imageGeneratePromptText, t)!,
      imageGeneratePromptHint: TextStyle.lerp(imageGeneratePromptHint, other.imageGeneratePromptHint, t)!,
      imageGenerateAISuggestion: TextStyle.lerp(imageGenerateAISuggestion, other.imageGenerateAISuggestion, t)!,
      imageGenerateLoadingPercent: TextStyle.lerp(imageGenerateLoadingPercent, other.imageGenerateLoadingPercent, t)!,
      imageGenerateLoadingTitle: TextStyle.lerp(imageGenerateLoadingTitle, other.imageGenerateLoadingTitle, t)!,
      imageGenerateLoadingStage: TextStyle.lerp(imageGenerateLoadingStage, other.imageGenerateLoadingStage, t)!,
      imageGenerateLoadingTime: TextStyle.lerp(imageGenerateLoadingTime, other.imageGenerateLoadingTime, t)!,
      imageGenerateStageLabel: TextStyle.lerp(imageGenerateStageLabel, other.imageGenerateStageLabel, t)!,
      onboardingTitle: TextStyle.lerp(onboardingTitle, other.onboardingTitle, t)!,
      onboardingSubtitle: TextStyle.lerp(onboardingSubtitle, other.onboardingSubtitle, t)!,
      onboardingButton: TextStyle.lerp(onboardingButton, other.onboardingButton, t)!,
      profileName: TextStyle.lerp(profileName, other.profileName, t)!,
      profileEmail: TextStyle.lerp(profileEmail, other.profileEmail, t)!,
      profileListItemTitle: TextStyle.lerp(profileListItemTitle, other.profileListItemTitle, t)!,
      profileListItemSubtitle: TextStyle.lerp(profileListItemSubtitle, other.profileListItemSubtitle, t)!,
      profileScreenTitle: TextStyle.lerp(profileScreenTitle, other.profileScreenTitle, t)!,
      profileScreenSubtitle: TextStyle.lerp(profileScreenSubtitle, other.profileScreenSubtitle, t)!,
      profileSectionTitle: TextStyle.lerp(profileSectionTitle, other.profileSectionTitle, t)!,
      profileHelperText: TextStyle.lerp(profileHelperText, other.profileHelperText, t)!,
      profileContactInfo: TextStyle.lerp(profileContactInfo, other.profileContactInfo, t)!,
      profileCardTitle: TextStyle.lerp(profileCardTitle, other.profileCardTitle, t)!,
      profileBodyText: TextStyle.lerp(profileBodyText, other.profileBodyText, t)!,
      profileDateText: TextStyle.lerp(profileDateText, other.profileDateText, t)!,
      customTextFieldLabel: TextStyle.lerp(customTextFieldLabel, other.customTextFieldLabel, t)!,
      customTextFieldInput: TextStyle.lerp(customTextFieldInput, other.customTextFieldInput, t)!,
      customButtonText: TextStyle.lerp(customButtonText, other.customButtonText, t)!,
      normalTextTitle: TextStyle.lerp(normalTextTitle, other.normalTextTitle, t)!,
      normalTextSubtitle: TextStyle.lerp(normalTextSubtitle, other.normalTextSubtitle, t)!,
      promptContainerText: TextStyle.lerp(promptContainerText, other.promptContainerText, t)!,
      sizeContainerText: TextStyle.lerp(sizeContainerText, other.sizeContainerText, t)!,
      customTextRichText1: TextStyle.lerp(customTextRichText1, other.customTextRichText1, t)!,
      customTextRichText2: TextStyle.lerp(customTextRichText2, other.customTextRichText2, t)!,
      passwordTextStyle: TextStyle.lerp(passwordTextStyle, other.passwordTextStyle, t)!,
      homeAlignText: TextStyle.lerp(homeAlignText, other.homeAlignText, t)!,
      alignTextStyle: TextStyle.lerp(alignTextStyle, other.alignTextStyle, t)!,
    );
  }
}

