import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/models/folder.dart';

class HiveFoldersDatabase {
  final _myBox = Hive.box('folders_database');

  List<Folder> loadFolders() {
    List<Folder> savedFoldersFormatted = [];

    if (_myBox.get("ALL_FOLDERS") != null &&
        _myBox.get("ALL_FOLDERS").length > 0) {
      List<dynamic> savedFolders = _myBox.get("ALL_FOLDERS");

      // saveFolders([]);

      for (int i = 0; i < savedFolders.length; i++) {
        Folder eachFolder = Folder(
          id: savedFolders[i][0],
          title: savedFolders[i][1],
          createdAt: savedFolders[i][2],
          updatedAt: savedFolders[i][3],
          color: savedFolders[i][4],
          notes: savedFolders[i][5],
          isPinned: savedFolders[i][6],
          subfolderId: savedFolders[i][7],
          pin: savedFolders[i][8],
        );

        savedFoldersFormatted.add(eachFolder);
      }
    }

    return savedFoldersFormatted;
  }

  Future<String> createFirebaseBackup() async {
    final allFolders = loadFolders();
    final allFoldersJson = jsonEncode(allFolders);

    return allFoldersJson;
  }

  void saveFolders(List<Folder> allFolders) {
    List<List<dynamic>> allFoldersFormatted = [];

    for (var folder in allFolders) {
      int id = folder.id;
      String title = folder.title;
      DateTime createdAt = folder.createdAt;
      DateTime updatedAt = folder.updatedAt;
      String color = folder.color;
      bool isPinned = folder.isPinned;
      List<int> notes = folder.notes;
      int? subfolderId = folder.subfolderId;
      String pin = folder.pin;

      allFoldersFormatted.add([
        id,
        title,
        createdAt,
        updatedAt,
        color,
        notes,
        isPinned,
        subfolderId,
        pin,
      ]);
    }
    _myBox.put("ALL_FOLDERS", allFoldersFormatted);
  }
}
