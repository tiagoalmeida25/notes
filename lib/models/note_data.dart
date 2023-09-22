import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notes/data/hive_database_notes.dart';
import 'package:notes/models/note.dart';

class NoteData extends ChangeNotifier {
  final db = HiveNotesDatabase();

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
    List<Note> allNotes = getAllNotes();
    allNotes.add(note);
    saveNotes(allNotes);
    notifyListeners();
  }

  void deleteNote(Note note) {
    _allNotes.remove(note);
    saveNotes(_allNotes);
    
    notifyListeners();
  }

  List<Note> searchNotes(String query) {
    List<Note> filteredNotes = [];
    if (query.isEmpty) {
      filteredNotes = getAllNotes();
    } else {
      filteredNotes = getAllNotes().where((note) {
        String noteText = jsonDecode(note.text)[0]['insert'];
        return note.title.toLowerCase().contains(query.toLowerCase()) ||
            noteText.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    notifyListeners();
    return filteredNotes;
  }

  void updateNote(Note note, String text, String title, DateTime updatedAt,
      String backgroundColor, bool isPinned, List<int> tags) {
    for (int i = 0; i < _allNotes.length; i++) {
      if (_allNotes[i].id == note.id) {
        _allNotes[i].text = text;
        _allNotes[i].title = title;
        _allNotes[i].updatedAt = updatedAt;
        _allNotes[i].backgroundColor = backgroundColor;
        _allNotes[i].isPinned = isPinned;
        _allNotes[i].tags = tags;
      }
    }
    saveNotes(_allNotes);
    notifyListeners();
  }

  List<Note> getAllNotes() {
    _allNotes = db.loadNotes();
    return _allNotes;
  }

  void pinHandler(Note note) {
    for (int i = 0; i < _allNotes.length; i++) {
      if (_allNotes[i].id == note.id) {
        _allNotes[i].isPinned = !_allNotes[i].isPinned;
      }
    }
    saveNotes(_allNotes);
  }

  List<Note> getPinnedNotes() {
    return _allNotes.where((note) => note.isPinned == true).toList();
  }

  void saveNotes(List<Note> allNotes) {
    db.saveNotes(allNotes);
  }

  List<Note> _sortInternally(String sortBy, bool isSorted, List<Note> sortedNotes){
    if (sortBy == 'Title') {
      if (isSorted) {
        sortedNotes.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      } else {
        sortedNotes.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      }
    } else if (sortBy == 'Last Updated') {
      if (isSorted) {
        sortedNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      } else {
        sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } else if (sortBy == 'Created') {
      if (isSorted) {
        sortedNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else {
        sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }

    return sortedNotes;
  }
  void sortNotes(String sortBy, bool isSorted) {
    List<Note> sortedNotes = getAllNotes();

    print('sortBy: $sortBy, isSorted: $isSorted');

    print(sortedNotes.map((e) => e.title));

    List<Note> pinnedNotes =
        sortedNotes.where((note) => note.isPinned).toList();
    List<Note> unpinnedNotes =
        sortedNotes.where((note) => !note.isPinned).toList();

    pinnedNotes = _sortInternally(sortBy, isSorted, pinnedNotes);
    unpinnedNotes = _sortInternally(sortBy, isSorted, unpinnedNotes);    
    
    sortedNotes = [...pinnedNotes, ...unpinnedNotes];

    print(sortedNotes.map((e) => e.title));


    _allNotes = sortedNotes;
    saveNotes(_allNotes);
    notifyListeners();
  }
}
