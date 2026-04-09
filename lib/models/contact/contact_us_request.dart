/// Request body for `POST /contact/`. Subject strings must match the API exactly.
class ContactUsRequest {
  ContactUsRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.subject,
    required this.message,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String subject;
  final String message;

  /// Valid [subject] values (exact strings required by the API).
  static const List<String> subjects = [
    'Feature Request',
    'General Feedback',
    'Bug Report',
    'Issue with Wallpaper Generation',
  ];

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'subject': subject,
    'message': message,
  };

  static bool isValidSubject(String value) => subjects.contains(value);
}
