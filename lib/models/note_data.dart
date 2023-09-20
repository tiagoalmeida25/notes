import 'package:flutter/material.dart';
import 'package:notes/data/hive_database.dart';
import 'package:notes/models/note.dart';

class NoteData extends ChangeNotifier {
  final db = HiveDatabase();

  List<Note> _allNotes = [];
  List<Note> get allNotes => _allNotes;

  void initializeNotes() {
    _allNotes = db.loadNotes();
    notifyListeners();
  }

  void setAllNotes(List<Note> notes) {
    _allNotes = notes;
    notifyListeners();
  }


  void addNewNote(Note note) {
    _allNotes.add(note);
    saveNotes(_allNotes);
    notifyListeners();
  }

  void deleteNote(Note note) {
    _allNotes.remove(note);
    saveNotes(_allNotes);

    notifyListeners();
  }

  void updateNote(Note note, String text, String title, DateTime updatedAt, String backgroundColor, bool isPinned) {
    for (int i = 0; i < _allNotes.length; i++) {
      if (_allNotes[i].id == note.id) {
        _allNotes[i].text = text;
        _allNotes[i].title = title;
        _allNotes[i].updatedAt = updatedAt;
        _allNotes[i].backgroundColor = backgroundColor;
        _allNotes[i].isPinned = note.isPinned;
      }
    }
    saveNotes(_allNotes);
    notifyListeners();
  }

  List<Note> getAllNotes() {
    return _allNotes;
  }

  void saveNotes(List<Note> allNotes) {
    db.saveNotes(_allNotes);
  }

  void sortNotes(String sortBy, bool isSorted) {
    List<Note> sortedNotes = List.from(_allNotes);

    
    if (sortBy == 'Title') {
      if (isSorted) {
        sortedNotes.sort((a, b) => a.title.compareTo(b.title));
      } else {
        sortedNotes.sort((a, b) => b.title.compareTo(a.title));
      }
    } else if (sortBy == 'LastUpdated') {
      if (isSorted) {
        sortedNotes.sort((a, b) => a.updatedAt!.compareTo(b.updatedAt!));
      } else {
        sortedNotes.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
      }
    } else if (sortBy == 'Created') {
      if (isSorted) {
        sortedNotes.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      } else {
        sortedNotes.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      }
    }
    
    setAllNotes(sortedNotes);
  }
}
