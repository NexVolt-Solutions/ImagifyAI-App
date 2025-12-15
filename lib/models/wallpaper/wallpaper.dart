class Wallpaper {
  Wallpaper({
    required this.id,
    required this.prompt,
    required this.size,
    required this.style,
    required this.title,
    required this.aiModel,
    required this.thumbnailUrl,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String prompt;
  final String size;
  final String style;
  final String title;
  final String aiModel;
  final String thumbnailUrl;
  final String imageUrl;
  final DateTime? createdAt;

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      style: json['style']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      aiModel: json['ai_model']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

