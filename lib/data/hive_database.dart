import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/models/note.dart';

class HiveDatabase {
  final _myBox = Hive.box('note_database');

  List<Note> loadNotes() {
    List<Note> savedNotesFormatted = [];

    if (_myBox.get("ALL_NOTES") != null) {
      if (_myBox.get("ALL_NOTES").length > 0) {
        List<dynamic> savedNotes = _myBox.get("ALL_NOTES");

        for (int i = 0; i < savedNotes.length; i++) {
          Note eachNote = Note(
            id: savedNotes[i][0],
            text: savedNotes[i][1],
            title: savedNotes[i][2],
            createdAt: savedNotes[i][3],
            updatedAt: savedNotes[i][4],
            backgroundColor: savedNotes[i][5],
          );

          savedNotesFormatted.add(eachNote);
        }
      }
    }

    return savedNotesFormatted;
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

      allNotesFormatted.add([id, text, title, createdAt, updatedAt, backgroundColor]);
    }
    _myBox.put("ALL_NOTES", allNotesFormatted);
  }
}
