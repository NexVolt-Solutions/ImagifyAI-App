# Auth Text Styles Guide

## Overview
All text styles from the Auth screens (SignUp, SignIn, ForgotPassword, Verification, etc.) have been extracted and added to the theme system. These styles are now available as theme extensions and automatically adapt to light/dark themes.

## Available Text Styles

### 1. **authTitlePrimary**
- **Usage**: Main titles like "Sign Up", "Sign In", "Forgot Password"
- **Size**: 20px
- **Weight**: w600
- **Color**: Primary purple (AppColors.primeryColor)
- **Example**: Screen titles

### 2. **authTitleWhite**
- **Usage**: White titles in dark mode, black in light mode
- **Size**: 20px
- **Weight**: w600
- **Color**: White (dark) / Black (light)
- **Example**: "Verify Your Account", "You are all done!"

### 3. **authSubtitlePrimary**
- **Usage**: Subtitles with primary color
- **Size**: 14px
- **Weight**: w500
- **Color**: Primary purple
- **Example**: "or Continue" divider text

### 4. **authSubtitleWhite**
- **Usage**: White subtitles
- **Size**: 14px
- **Weight**: w500
- **Color**: White (dark) / Black87 (light)
- **Example**: Subtitle text

### 5. **authBodyRegular**
- **Usage**: Regular body text with reduced opacity
- **Size**: 14px
- **Weight**: w400
- **Color**: White70 (dark) / Black54 (light)
- **Example**: "Enter your email address and we'll send you..."

### 6. **authBodyMedium**
- **Usage**: Medium weight body text
- **Size**: 14px
- **Weight**: w500
- **Color**: White (dark) / Black87 (light)
- **Example**: "Remember me" checkbox text

### 7. **authBodyGray**
- **Usage**: Gray body text
- **Size**: 14px
- **Weight**: w500
- **Color**: Gray (AppColors.grayColor)
- **Example**: "Continue with Google" button text

### 8. **authBodyPrimary**
- **Usage**: Primary colored body text
- **Size**: 14px
- **Weight**: w600
- **Color**: Primary purple
- **Example**: "Resend Code" button text

### 9. **authHintText**
- **Usage**: Text field hints and labels
- **Size**: 12px
- **Weight**: w500
- **Color**: TextFieldSubTitleColor
- **Example**: "Enter your email", "Create your username"

### 10. **authOTPText**
- **Usage**: OTP/PIN input text
- **Size**: 14px
- **Weight**: w500
- **Color**: White (dark) / Black87 (light)
- **Example**: OTP input field text

### 11. **authOTPLarge**
- **Usage**: Large OTP placeholder text
- **Size**: 20px
- **Weight**: w600
- **Color**: Gray
- **Example**: OTP separator "-"

### 12. **authTimerText**
- **Usage**: Timer countdown text
- **Size**: 16px
- **Weight**: w500
- **Color**: White (dark) / Black87 (light)
- **Example**: "Resend code in 30s"

### 13. **authResendText**
- **Usage**: Resend code button text
- **Size**: 16px
- **Weight**: w600
- **Color**: Primary purple
- **Example**: "Resend Code" button

### 14. **authPasswordTitle**
- **Usage**: Password requirement titles
- **Size**: 16px
- **Weight**: w500
- **Color**: White (dark) / Black87 (light)
- **Example**: "Password must contain"

### 15. **authGoogleButton**
- **Usage**: Google sign-in button text
- **Size**: 14px
- **Weight**: w500
- **Color**: White (dark) / Gray (light)
- **Example**: "Continue with Google"

## Usage Examples

### Method 1: Using Extension Method (Recommended)
```dart
import 'package:genwalls/Core/theme/theme_extensions.dart';

Text(
  'Sign Up',
  style: context.appTextStyles?.authTitlePrimary,
)
```

### Method 2: Using Theme Extension Directly
```dart
final textStyles = Theme.of(context).extension<AppTextStyles>();

Text(
  'Sign In',
  style: textStyles?.authTitlePrimary,
)
```

### Method 3: Using ThemeColors Helper
```dart
import 'package:genwalls/Core/theme/theme_extensions.dart';

final textStyles = ThemeColors.textStyles(context);

Text(
  'Forgot Password?',
  style: textStyles?.authBodyPrimary,
)
```

## Migration from Hardcoded Styles

### Before:
```dart
Text(
  'Sign Up',
  style: GoogleFonts.poppins(
    color: AppColors.primeryColor,
    fontSize: context.text(20),
    fontWeight: FontWeight.w600,
  ),
)
```

### After:
```dart
Text(
  'Sign Up',
  style: context.appTextStyles?.authTitlePrimary,
)
```

### Before:
```dart
Text(
  'Enter your email',
  style: TextStyle(
    color: AppColors.textFieldSubTitleColor,
    fontWeight: FontWeight.w500,
    fontSize: context.text(12),
  ),
)
```

### After:
```dart
Text(
  'Enter your email',
  style: context.appTextStyles?.authHintText,
)
```

## Benefits

1. **Theme-Aware**: Automatically adapts to light/dark themes
2. **Consistent**: All Auth screens use the same text styles
3. **Maintainable**: Change styles in one place (app_theme.dart)
4. **Type-Safe**: Compile-time checking for style names
5. **Google Fonts**: All styles use Poppins font automatically

## Notes

- All styles use **Google Fonts Poppins** automatically
- Colors adapt based on current theme (light/dark)
- Font sizes are fixed (not responsive) - use `context.text()` for responsive sizes if needed
- All styles are nullable - always use `?.` when accessing

## Next Steps

1. Gradually replace hardcoded text styles in Auth screens
2. Use these styles in other parts of the app for consistency
3. Add more custom styles as needed in `AppTextStyles` class

