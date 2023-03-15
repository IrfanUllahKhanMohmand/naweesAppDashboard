class Nazam {
  final int id;
  final String title;
  final String content;
  final int poetId;

  Nazam({
    required this.id,
    required this.title,
    required this.content,
    required this.poetId,
  });

  factory Nazam.fromJson(Map<String, dynamic> json) {
    return Nazam(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      poetId: json['poet_id'],
    );
  }
}
