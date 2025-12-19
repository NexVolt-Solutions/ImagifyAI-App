class SuggestResponse {
  SuggestResponse({
    this.suggestion,
  });

  final String? suggestion;

  factory SuggestResponse.fromJson(Map<String, dynamic> json) {
    return SuggestResponse(
      suggestion: json['suggestion']?.toString(),
    );
  }
  
  // Getter for backward compatibility
  String? get suggestionText => suggestion;
}

