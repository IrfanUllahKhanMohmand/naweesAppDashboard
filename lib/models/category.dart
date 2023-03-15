class Category {
  final int id;
  final String name;

  final String description;
  final String pic;

  Category(
      {required this.id,
      required this.name,
      required this.description,
      required this.pic});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        pic: json['pic']);
  }
}
