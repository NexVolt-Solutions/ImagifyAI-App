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

  final formKey = GlobalKey<FormState>();
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
      errorMessage = 'Failed to pick image';
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
      final response = await _authRepository.updateProfilePicture(
        profileImage: profileImage!,
        accessToken: accessToken,
      );

      final message = response.message ?? 'Profile picture updated successfully';
      SnackbarUtil.showTopSnackBar(context, message, isError: false);
      
      // Reload user data after update only if requested
      if (reloadUserData) {
        currentUser = await _authRepository.getCurrentUser(accessToken: accessToken);
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
      errorMessage = 'Failed to update profile picture';
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
      SnackbarUtil.showTopSnackBar(context, 'Please fill all password fields');
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
      final response = await _authRepository.updatePassword(
        oldPassword: oldPassword,
        password: newPassword,
        confirmPassword: confirmPassword,
        accessToken: accessToken,
      );

      final message = response.message ?? 'Password updated successfully';
      SnackbarUtil.showTopSnackBar(context, message, isError: false);
      
      // Clear password fields after successful update
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } on ApiException catch (e) {
      errorMessage = e.message;
      SnackbarUtil.showTopSnackBar(context, e.message);
    } catch (_) {
      errorMessage = 'Failed to update password';
      SnackbarUtil.showTopSnackBar(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required BuildContext context,
    String? accessToken,
  }) async {
    if (isLoading || accessToken == null) return;
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
      // Update user profile information
      final response = await _authRepository.updateUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        username: usernameController.text.trim(),
        accessToken: accessToken,
      );

      final message = response.message ?? 'Profile updated successfully';
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
      currentUser = await _authRepository.getCurrentUser(accessToken: accessToken);
      loadUserData(currentUser);
      
      // Also update ProfileScreenViewModel
      final profileViewModel = context.read<ProfileScreenViewModel>();
      profileViewModel.currentUser = currentUser;
      profileViewModel.notifyListeners();
      
      Navigator.pop(context);
    } on ApiException catch (e) {
      errorMessage = e.message;
      SnackbarUtil.showTopSnackBar(context, e.message);
    } catch (_) {
      errorMessage = 'Failed to update profile';
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
