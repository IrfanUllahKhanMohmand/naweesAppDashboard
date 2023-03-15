class CatSher {
  final int id;
  final String content;
  final int catId;

  CatSher({
    required this.id,
    required this.content,
    required this.catId,
  });

  factory CatSher.fromJson(Map<String, dynamic> json) {
    return CatSher(
      id: json['id'],
      content: json['content'],
      catId: json['cat_id'],
    );
  }
}
