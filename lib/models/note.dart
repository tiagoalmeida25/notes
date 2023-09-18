class Note {
  int id;
  String title;
  String text;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? backgroundColor;

  Note({
    required this.id,
    required this.text,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.backgroundColor,
  });
}
