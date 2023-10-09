import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/backup_service.dart';
import 'package:notes/models/note.dart';

class HiveNotesDatabase {
  final _myBox = Hive.box('note_database');

  List<Note> loadNotes() {
    List<Note> savedNotesFormatted = [];

    if (_myBox.get("ALL_NOTES") != null && _myBox.get("ALL_NOTES").length > 0) {
      List<dynamic> savedNotes = _myBox.get("ALL_NOTES");

      // saveNotes([]);

      for (int i = 0; i < savedNotes.length; i++) {
        Note eachNote = Note(
          id: savedNotes[i][0],
          text: savedNotes[i][1],
          title: savedNotes[i][2],
          createdAt: savedNotes[i][3],
          updatedAt: savedNotes[i][4],
          backgroundColor: savedNotes[i][5],
          isPinned: savedNotes[i][6],
          tags: savedNotes[i][7],
          folderId: savedNotes[i][8],
          pin: savedNotes[i][9],
        );

        savedNotesFormatted.add(eachNote);
      }
    }

    return savedNotesFormatted;
  }

  Future<String> createFirebaseBackup() async {
    final allNotes = loadNotes();
    final allNotesJson = jsonEncode(allNotes);
    return allNotesJson;
  }

  Future<void> restoreFromFirebaseBackup() async {
    final backupJson = await FirebaseBackupService.downloadBackup('notes_backup.json');
    // Deserialize backupJson and update local Hive database

    final List<dynamic> backupNotes = jsonDecode(backupJson);

    List<Note> allNotes = [];

    for (int i = 0; i < backupNotes.length; i++) {
      Note eachNote = Note(
        id: backupNotes[i][0],
        text: backupNotes[i][1],
        title: backupNotes[i][2],
        createdAt: backupNotes[i][3],
        updatedAt: backupNotes[i][4],
        backgroundColor: backupNotes[i][5],
        isPinned: backupNotes[i][6],
        tags: backupNotes[i][7],
        folderId: backupNotes[i][8],
        pin: backupNotes[i][9],
      );

      allNotes.add(eachNote);
    }
  }

  void saveNotes(List<Note> allNotes) {
    List<List<dynamic>> allNotesFormatted = [];

    for (var note in allNotes) {
      int id = note.id;
      String text = note.text;
      String title = note.title;
      DateTime? createdAt = note.createdAt;
      DateTime? updatedAt = note.updatedAt;
      String? backgroundColor = note.backgroundColor;
      bool? isPinned = note.isPinned;
      List<int> tags = note.tags;
      int folderId = note.folderId;
      String pin = note.pin;

      allNotesFormatted.add([
        id,
        text,
        title,
        createdAt,
        updatedAt,
        backgroundColor,
        isPinned,
        tags,
        folderId,
        pin
      ]);
    }
    _myBox.put("ALL_NOTES", allNotesFormatted);
  }
}
