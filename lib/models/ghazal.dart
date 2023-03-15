class Ghazal {
  final int id;
  final String content;
  final int poetId;

  Ghazal({
    required this.id,
    required this.content,
    required this.poetId,
  });

  factory Ghazal.fromJson(Map<String, dynamic> json) {
    return Ghazal(
      id: json['id'],
      content: json['content'],
      poetId: json['poet_id'],
    );
  }
}
