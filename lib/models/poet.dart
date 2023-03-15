class Poet {
  final int id;
  final String name;
  final String fatherName;
  final String birthDate;
  final String deathDate;
  final String description;
  final String pic;

  Poet(
      {required this.id,
      required this.name,
      required this.fatherName,
      required this.birthDate,
      required this.deathDate,
      required this.description,
      required this.pic});

  factory Poet.fromJson(Map<String, dynamic> json) {
    return Poet(
        id: json['id'],
        name: json['name'],
        fatherName: json['father_name'],
        birthDate: json['birth_date'],
        deathDate: json['death_date'],
        description: json['description'],
        pic: json['pic']);
  }
}
