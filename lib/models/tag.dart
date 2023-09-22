class Tag {
  int id;
  String text;
  DateTime createdAt;
  DateTime updatedAt;
  String backgroundColor;
  int order;

  Tag({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.backgroundColor,
    required this.order,
  });
}
