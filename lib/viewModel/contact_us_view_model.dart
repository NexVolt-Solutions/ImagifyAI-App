import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/domain/repositories/contact_repository.dart';
import 'package:imagifyai/models/contact/contact_us_request.dart';
import 'package:imagifyai/models/user/user.dart';

class ContactUsViewModel extends ChangeNotifier {
  ContactUsViewModel({ContactRepository? contactRepository})
    : _repository = contactRepository ?? ContactRepository();

  final ContactRepository _repository;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  int selectedSubjectIndex = 0;
  bool isSubmitting = false;

  List<String> get subjects => ContactUsRequest.subjects;

  String get selectedSubject => subjects[selectedSubjectIndex];

  /// Prefill from profile and reset message / default subject (call when the screen opens).
  void prepareForm(User? user) {
    firstNameController.text = user?.firstName?.trim() ?? '';
    lastNameController.text = user?.lastName?.trim() ?? '';
    emailController.text = user?.email?.trim() ?? '';
    messageController.clear();
    selectedSubjectIndex = 0;
    notifyListeners();
  }

  void setSelectedSubjectIndex(int index) {
    if (index < 0 || index >= subjects.length) return;
    if (selectedSubjectIndex == index) return;
    selectedSubjectIndex = index;
    notifyListeners();
  }

  /// Returns the server success message when submission succeeds.
  /// Returns `null` if [formKey] validation failed (no API call).
  /// Throws [ApiException] on API errors.
  Future<String?> submitIfValid({
    required GlobalKey<FormState> formKey,
    required String? accessToken,
  }) async {
    if (!formKey.currentState!.validate()) return null;

    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException('Not signed in', statusCode: 401);
    }

    final request = ContactUsRequest(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      subject: selectedSubject,
      message: messageController.text.trim(),
    );

    if (!ContactUsRequest.isValidSubject(request.subject)) {
      throw ApiException('Please select a subject', statusCode: 422);
    }

    isSubmitting = true;
    notifyListeners();
    try {
      return await _repository.submit(
        request: request,
        accessToken: accessToken,
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
