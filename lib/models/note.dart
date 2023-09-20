class Note {
  int id;
  String title;
  String text;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? backgroundColor;
  bool? isPinned;

  Note({
    required this.id,
    required this.text,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.backgroundColor,
    required this.isPinned,
  });
}
