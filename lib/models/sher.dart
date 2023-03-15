class Sher {
  final int id;
  final String content;
  final int poetId;

  Sher({
    required this.id,
    required this.content,
    required this.poetId,
  });

  factory Sher.fromJson(Map<String, dynamic> json) {
    return Sher(
      id: json['id'],
      content: json['content'],
      poetId: json['poet_id'],
    );
  }
}
