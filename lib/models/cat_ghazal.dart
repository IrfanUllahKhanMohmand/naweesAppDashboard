class CatGhazal {
  final int id;
  final String content;
  final int catId;

  CatGhazal({
    required this.id,
    required this.content,
    required this.catId,
  });

  factory CatGhazal.fromJson(Map<String, dynamic> json) {
    return CatGhazal(
      id: json['id'],
      content: json['content'],
      catId: json['cat_id'],
    );
  }
}
