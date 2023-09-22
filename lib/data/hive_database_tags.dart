import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/models/tag.dart';

class HiveTagsDatabase {
  final _myBox = Hive.box('tags_database');

  List<Tag> loadTags() {
    List<Tag> savedTagsFormatted = [];

    if (_myBox.get("ALL_TAGS") != null && _myBox.get("ALL_TAGS").length > 0) {
      List<dynamic> savedTags = _myBox.get("ALL_TAGS");

      // saveTags([]);

      for (int i = 0; i < savedTags.length; i++) {
        Tag eachTag = Tag(
          id: savedTags[i][0],
          text: savedTags[i][1],
          createdAt: savedTags[i][2],
          updatedAt: savedTags[i][3],
          backgroundColor: savedTags[i][4],
          order: savedTags[i][5],
        );

        savedTagsFormatted.add(eachTag);
      }
    }

    return savedTagsFormatted;
  }

  void saveTags(List<Tag> allTags) {
    List<List<dynamic>> allTagsFormatted = [];

    for (var tag in allTags) {
      int id = tag.id;
      String text = tag.text;
      DateTime createdAt = tag.createdAt;
      DateTime updatedAt = tag.updatedAt;
      String backgroundColor = tag.backgroundColor;
      int order = tag.order;

      allTagsFormatted.add([id, text, createdAt, updatedAt, backgroundColor, order]);
    }
    _myBox.put("ALL_TAGS", allTagsFormatted);
  }
}
