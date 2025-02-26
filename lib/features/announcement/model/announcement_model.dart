class Announcement {
  final int id;
  final String title;
  final String content;
  final String type;
  final String? linkUrl;
  final String? linkType;
  final String? version;
  final List<String>? roles;
  final bool isActive;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.linkUrl,
    this.linkType,
    this.version,
    this.roles,
    this.isActive = true,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      linkUrl: json['link_url'] as String?,
      linkType: json['link_type'] as String?,
      version: json['version'] as String?,
      roles: json['roles'] != null ? List<String>.from(json['roles'] as List) : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String parseHtmlString() {
    return content
        .replaceAll('&#8217;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&#038;', '&')
        .replaceAll('&#8211;', '-')
        .replaceAll(RegExp(r'<[^>]*>'), '');
  }
}