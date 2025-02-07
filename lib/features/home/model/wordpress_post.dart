class WordPressPost {
  final String title;
  final String content;
  final String date;
  final String link;
  final String thumbnailUrl;

  WordPressPost({
    required this.title,
    required this.content,
    required this.date,
    required this.link,
    required this.thumbnailUrl,
  });

  factory WordPressPost.fromJson(Map<String, dynamic> json) {
    String thumbnailUrl = '';
    if (json['yoast_head_json'] != null &&
        json['yoast_head_json']['schema'] != null &&
        json['yoast_head_json']['schema']['@graph'] != null) {
      for (var item in json['yoast_head_json']['schema']['@graph']) {
        if (item['@type'] == 'Article' && item['thumbnailUrl'] != null) {
          thumbnailUrl = item['thumbnailUrl'];
          break;
        }
      }
    }

    return WordPressPost(
      title: json['title']['rendered'] ?? '',
      content: json['content']['rendered'] ?? '',
      date: json['date'] ?? '',
      link: json['link'] ?? '',
      thumbnailUrl: thumbnailUrl,
    );
  }
}
