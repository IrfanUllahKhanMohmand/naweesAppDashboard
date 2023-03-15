class CatNazam {
  final int id;
  final String title;
  final String content;
  final int catId;

  CatNazam({
    required this.id,
    required this.title,
    required this.content,
    required this.catId,
  });

  factory CatNazam.fromJson(Map<String, dynamic> json) {
    return CatNazam(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      catId: json['cat_id'],
    );
  }
}
