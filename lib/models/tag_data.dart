import 'package:flutter/material.dart';
import 'package:notes/data/hive_database_notes.dart';
import 'package:notes/data/hive_database_tags.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/tag.dart';

class TagData extends ChangeNotifier {
  final db = HiveTagsDatabase();
  final noteDb = HiveNotesDatabase();

  List<Tag> _allTags = [];
  List<Tag> get allTags => _allTags;

  void initializeTags() {
    _allTags = db.loadTags();
    notifyListeners();
  }

  void setAllTags(List<Tag> tags) {
    _allTags = tags;
    notifyListeners();
  }

  List<Tag> searchTags(String query) {
    List<Tag> filteredTags = [];
    if (query.isEmpty) {
      filteredTags = getAllTags();
    } else {
      filteredTags = getAllTags().where((tag) {
        return tag.text.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    return filteredTags;
  }


  void addNewTag(Tag tag) {
    List<Tag> _allTags = getAllTags();

    _allTags.add(tag);

    saveTags(_allTags);
  }

  void deleteTag(Tag tag) {
    _allTags.remove(tag);
    saveTags(_allTags);
  }

  void updateTag(Tag tag, String text, DateTime updatedAt,
      String backgroundColor, bool isPinned) {
    for (int i = 0; i < _allTags.length; i++) {
      if (_allTags[i].id == tag.id) {
        _allTags[i].text = text;
        _allTags[i].updatedAt = updatedAt;
        _allTags[i].backgroundColor = backgroundColor;
      }
    }
    saveTags(_allTags);
  }

  List<Note> getNotesWithTag(Tag tag) {
    List<Note> notesWithTag = [];

    List<Note> allNotes = noteDb.loadNotes();

    for (int i = 0; i < allNotes.length; i++) {
      for (int j = 0; j < allNotes[i].tags.length; j++) {
        if (allNotes[i].tags[j] == tag.id) {
          notesWithTag.add(allNotes[i]);
        }
      }
    }

    return notesWithTag;
  }

  Tag getTag(int id) {
    for (int i = 0; i < _allTags.length; i++) {
      if (_allTags[i].id == id) {
        return _allTags[i];
      }
    }
    return Tag(
      id: 0,
      text: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundColor: '',
    );
  }

  List<Tag> getAllTags() {
    _allTags = db.loadTags();
    return _allTags;
  }

  void saveTags(List<Tag> allTags) {
    db.saveTags(_allTags);
    notifyListeners();
  }

  List<Tag> sortTags(String sortBy, bool isSorted) {
    List<Tag> sortedTags = List.from(_allTags);

    if (sortBy == 'Title') {
      if (isSorted) {
        sortedTags.sort((a, b) => a.text.compareTo(b.text));
      } else {
        sortedTags.sort((a, b) => b.text.compareTo(a.text));
      }
    } else if (sortBy == 'Last Updated') {
      if (isSorted) {
        sortedTags.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      } else {
        sortedTags.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } else if (sortBy == 'Created') {
      if (isSorted) {
        sortedTags.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else {
        sortedTags.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }
    return sortedTags;
  }
}
