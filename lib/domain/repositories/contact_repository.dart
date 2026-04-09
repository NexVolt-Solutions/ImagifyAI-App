import 'package:imagifyai/Core/Constants/api_constants.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/models/contact/contact_us_request.dart';

class ContactRepository {
  ContactRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// Submits the contact form. Returns the server success [message] when status is 2xx.
  Future<String> submit({
    required ContactUsRequest request,
    required String accessToken,
  }) async {
    final json = await _apiService.post(
      ApiConstants.contact,
      headers: {'Authorization': 'Bearer $accessToken'},
      body: request.toJson(),
    );
    return json['message']?.toString() ??
        'Your message has been sent successfully. We will get back to you soon.';
  }
}
