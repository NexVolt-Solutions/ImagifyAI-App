import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/user/user.dart';
import 'package:genwalls/repositories/auth_repository.dart';
import 'package:genwalls/viewModel/profile_screen_view_model.dart';
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
    if (isUpdatingPicture || profileImage == null || accessToken == null) return;

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

      final message = response.message ?? 'Your profile picture has been updated!';
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
      SnackbarUtil.showTopSnackBar(context, 'Please complete all password fields');
      return;
    }

    if (newPassword != confirmPassword) {
      SnackbarUtil.showTopSnackBar(context, 'New password and confirm password must match');
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

      final message = response.message ?? 'Password updated successfully! Your account is secure';
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

    // Validate password fields if they are filled
    if (_shouldUpdatePassword()) {
      final newPassword = newPasswordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      
      if (newPassword != confirmPassword) {
        SnackbarUtil.showTopSnackBar(context, 'New password and confirm password must match');
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

      // Update user profile information
      final response = await _authRepository.updateUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        username: usernameController.text.trim(),
        accessToken: accessToken,
        userId: currentUser!.id!,
      );

      final message = response.message ?? 'Your profile has been updated!';
      SnackbarUtil.showTopSnackBar(context, message, isError: false);
      
      // Update profile picture if selected (don't reload user data here)
      if (profileImage != null) {
        await updateProfilePicture(
          context: context, 
          accessToken: accessToken,
          reloadUserData: false, // Will reload once at the end
        );
      }
      
      // Update password if password fields are filled (don't reload user data here)
      if (_shouldUpdatePassword()) {
        await updatePassword(context: context, accessToken: accessToken);
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
      
      // Also update ProfileScreenViewModel
      final profileViewModel = context.read<ProfileScreenViewModel>();
      profileViewModel.currentUser = currentUser;
      profileViewModel.notifyListeners();
      
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
