import 'package:flutter/material.dart';
import 'package:notes/data/hive_database.dart';
import 'package:notes/models/note.dart';

class NoteData extends ChangeNotifier {
  final db = HiveDatabase();

  List<Note> allNotes = [];

  void initializeNotes() {
    allNotes = db.loadNotes();
    notifyListeners();
  }

  void addNewNote(Note note) {
    allNotes.add(note);
    saveNotes(allNotes);
    notifyListeners();
  }

  void deleteNote(Note note) {
    allNotes.remove(note);
    saveNotes(allNotes);

    notifyListeners();
  }

  void updateNote(Note note, String text, String title, DateTime updatedAt) {
    for (int i = 0; i < allNotes.length; i++) {
      if (allNotes[i].id == note.id) {
        allNotes[i].text = text;
        allNotes[i].title = title;
        allNotes[i].updatedAt = updatedAt;
      }
    }
    saveNotes(allNotes);
    notifyListeners();
  }

  List<Note> getAllNotes() {
    return allNotes;
  }

  void saveNotes(List<Note> allNotes) {
    db.saveNotes(allNotes);
  }

  void sortNotes(String sortBy, bool isSorted) {
    print(sortBy);
    print(isSorted);
    if (sortBy == 'Title') {
      if (isSorted) {
        print('sortNotesByTitle');
        sortNotesByTitle();
      } else {
        invertSortNotesByTitle();
      }
    } else if (sortBy == 'LastUpdated') {
      if (isSorted) {
        sortNotesByUpdate();
      } else {
        invertSortNotesByUpdate();
      }
    } else if (sortBy == 'Created') {
      if (isSorted) {
        sortNotesByCreate();
      } else {
        invertSortNotesByCreate();
      }
    }
    notifyListeners();
  }

  void sortNotesByCreate() {
    allNotes.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
  }

  void invertSortNotesByCreate() {
    allNotes.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  void sortNotesByUpdate() {
    allNotes.sort((a, b) => a.updatedAt!.compareTo(b.updatedAt!));
  }

  void invertSortNotesByUpdate() {
    allNotes.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
  }

  void sortNotesByTitle() {
    allNotes.sort((a, b) => a.title.compareTo(b.title));
  }

  void invertSortNotesByTitle() {
    allNotes.sort((a, b) => b.title.compareTo(a.title));
  }
}
