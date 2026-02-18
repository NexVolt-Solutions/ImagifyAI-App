import 'dart:io';

import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/user/user.dart';
import 'package:imagifyai/repositories/auth_repository.dart';
import 'package:imagifyai/viewModel/home_view_model.dart';
import 'package:imagifyai/viewModel/profile_screen_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileViewModel extends ChangeNotifier {
  EditProfileViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  // FormKey removed - should be created in widget state to avoid GlobalKey conflicts
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final usernameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int selectedIndex = -1;
  bool isLoading = false;
  bool isUpdatingPicture = false;
  String? errorMessage;
  User? currentUser;
  File? profileImage;

  final List<String> items = [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a,z)",
    "7 or more charactrers",
  ];

  void loadUserData(User? user) {
    if (user == null) return;

    // Only update if user data actually changed
    if (currentUser?.id == user.id &&
        currentUser?.firstName == user.firstName &&
        currentUser?.lastName == user.lastName &&
        currentUser?.email == user.email &&
        currentUser?.phoneNumber == user.phoneNumber &&
        currentUser?.username == user.username) {
      return; // No changes, skip update
    }

    currentUser = user;
    firstNameController.text = user.firstName ?? '';
    lastNameController.text = user.lastName ?? '';
    emailController.text = user.email ?? '';
    phoneNumberController.text = user.phoneNumber ?? '';
    usernameController.text = user.username ?? '';
    profileImage = null; // Reset selected image when loading user data
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (picked != null) {
        profileImage = File(picked.path);
        notifyListeners();
      }
    } catch (e) {
      // Handle image picker errors silently or show message if needed
      errorMessage = 'Couldn\'t select image. Please try again!';
      notifyListeners();
    }
  }

  Future<void> updateProfilePicture({
    required BuildContext context,
    String? accessToken,
    bool reloadUserData = true,
  }) async {
    if (isUpdatingPicture || profileImage == null || accessToken == null)
      return;

    isUpdatingPicture = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (currentUser?.id == null || currentUser!.id!.isEmpty) {
        throw ApiException('User ID is required to update profile picture');
      }

      final response = await _authRepository.updateProfilePicture(
        profileImage: profileImage!,
        accessToken: accessToken,
        userId: currentUser!.id!,
      );

      final message =
          response.message ?? 'Your profile picture has been updated!';
      SnackbarUtil.showTopSnackBar(context, message, isError: false);

      // Reload user data after update only if requested
      if (reloadUserData && currentUser?.id != null) {
        final userId = currentUser!.id!;
        currentUser = await _authRepository.getCurrentUser(
          accessToken: accessToken,
          userId: userId,
        );
        loadUserData(currentUser);

        // Also update ProfileScreenViewModel
        final profileViewModel = context.read<ProfileScreenViewModel>();
        profileViewModel.currentUser = currentUser;
        profileViewModel.notifyListeners();
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
      SnackbarUtil.showTopSnackBar(context, e.message);
    } catch (_) {
      errorMessage = 'Couldn\'t update your photo. Let\'s try again!';
      SnackbarUtil.showTopSnackBar(context, errorMessage!);
    } finally {
      isUpdatingPicture = false;
      notifyListeners();
    }
  }

  bool _shouldUpdatePassword() {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Update password only if all password fields are filled
    return oldPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty;
  }

  /// Check if profile data (name, username, profile image) has changed
  bool _hasProfileDataChanged() {
    if (currentUser == null) return false;

    final firstNameChanged =
        firstNameController.text.trim() != (currentUser!.firstName ?? '');
    final lastNameChanged =
        lastNameController.text.trim() != (currentUser!.lastName ?? '');
    final usernameChanged =
        usernameController.text.trim() != (currentUser!.username ?? '');
    final phoneNumberChanged =
        phoneNumberController.text.trim() != (currentUser!.phoneNumber ?? '');
    final profileImageChanged = profileImage != null;

    return firstNameChanged ||
        lastNameChanged ||
        usernameChanged ||
        phoneNumberChanged ||
        profileImageChanged;
  }

  /// Check if password has changed
  bool _hasPasswordChanged() {
    return _shouldUpdatePassword();
  }

  Future<void> updatePassword({
    required BuildContext context,
    String? accessToken,
  }) async {
    if (isLoading) return;

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validate password fields
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      SnackbarUtil.showTopSnackBar(
        context,
        'Please complete all password fields',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      SnackbarUtil.showTopSnackBar(
        context,
        'New password and confirm password must match',
      );
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (currentUser?.id == null || currentUser!.id!.isEmpty) {
        throw ApiException('User ID is required to update password');
      }

      final response = await _authRepository.updatePassword(
        oldPassword: oldPassword,
        password: newPassword,
        confirmPassword: confirmPassword,
        accessToken: accessToken!,
        userId: currentUser!.id!,
      );

      final message =
          response.message ??
          'Password updated successfully! Your account is secure';
      SnackbarUtil.showTopSnackBar(context, message, isError: false);

      // Clear password fields after successful update
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } on ApiException catch (e) {
      errorMessage = e.message;
      SnackbarUtil.showTopSnackBar(context, e.message);
    } catch (_) {
      errorMessage = 'Couldn\'t update password. Please try again!';
      SnackbarUtil.showTopSnackBar(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required BuildContext context,
    required String accessToken,
    required GlobalKey<FormState> formKey,
  }) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    // Check what has changed
    final hasProfileChanged = _hasProfileDataChanged();
    final hasPasswordChanged = _hasPasswordChanged();

    // If nothing changed, show message and return
    if (!hasProfileChanged && !hasPasswordChanged) {
      SnackbarUtil.showTopSnackBar(
        context,
        'No changes to save',
        isError: false,
      );
      return;
    }

    // Validate password fields if they are filled
    if (hasPasswordChanged) {
      final newPassword = newPasswordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (newPassword != confirmPassword) {
        SnackbarUtil.showTopSnackBar(
          context,
          'New password and confirm password must match',
        );
        return;
      }
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (currentUser?.id == null || currentUser!.id!.isEmpty) {
        throw ApiException('User ID is required to update profile');
      }

      String? successMessage;

      // Update profile data (name, username, profile image) if changed
      if (hasProfileChanged) {
        // Update user profile information (name, username, phone)
        final firstName = firstNameController.text.trim();
        final lastName = lastNameController.text.trim();
        final username = usernameController.text.trim();
        final phoneNumber = phoneNumberController.text.trim();

        // Check what changed
        final usernameChanged = username != (currentUser!.username ?? '');
        final hasOtherFieldsChanged =
            firstName != (currentUser!.firstName ?? '') ||
            lastName != (currentUser!.lastName ?? '') ||
            phoneNumber != (currentUser!.phoneNumber ?? '');

        // Username must be updated via /users/{user_id}/profile endpoint
        // Profile image can be combined with username update
        if (usernameChanged || profileImage != null) {
          // Use updateUserProfile endpoint for username and/or profile image
          final response = await _authRepository.updateUserProfile(
            username: usernameChanged ? username : null,
            profileImage: profileImage,
            accessToken: accessToken,
            userId: currentUser!.id!,
          );
          successMessage = response.message ?? 'Your profile has been updated!';
        }

        // Update other fields (first_name, last_name, phone_number) separately
        if (hasOtherFieldsChanged) {
          final response = await _authRepository.updateUser(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            username:
                null, // Don't send username here, it goes to /profile endpoint
            accessToken: accessToken,
            userId: currentUser!.id!,
          );
          if (successMessage == null) {
            successMessage =
                response.message ?? 'Your profile has been updated!';
          }
        }

        // Show success message for profile update
        if (successMessage != null) {
          SnackbarUtil.showTopSnackBar(context, successMessage, isError: false);
        }
      }

      // Update password if changed
      if (hasPasswordChanged) {
        await updatePassword(context: context, accessToken: accessToken);
        // Password update already shows its own success message
      }

      // Reload user data only once after all updates complete
      if (currentUser?.id != null) {
        final userId = currentUser!.id!;
        currentUser = await _authRepository.getCurrentUser(
          accessToken: accessToken,
          userId: userId,
        );
        loadUserData(currentUser);
      }

      // Update ProfileScreenViewModel with new user data (force reload to get latest)
      final profileViewModel = context.read<ProfileScreenViewModel>();
      await profileViewModel.loadCurrentUser(
        accessToken: accessToken,
        forceReload: true, // Force reload to get updated data from server
      );

      // Update HomeViewModel with new user data (force reload to get latest)
      final homeViewModel = context.read<HomeViewModel>();
      await homeViewModel.loadCurrentUser(context, forceReload: true);

      Navigator.pop(context);
    } on ApiException catch (e) {
      errorMessage = e.message;
      SnackbarUtil.showTopSnackBar(context, e.message);
    } catch (_) {
      errorMessage = 'Couldn\'t save your changes. Let\'s try again!';
      SnackbarUtil.showTopSnackBar(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    usernameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
