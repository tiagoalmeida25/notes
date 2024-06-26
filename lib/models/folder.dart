class Folder {
  int id;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  String color;
  List<int> notes;
  bool isPinned;
  int? subfolderId;
  String pin;

  Folder({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.color,
    required this.notes,
    required this.isPinned,
    this.subfolderId,
    required this.pin,
  });
}
