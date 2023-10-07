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
  }

  void setAllTags(List<Tag> tags) {
    _allTags = tags;
    WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
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
    List<Tag> allTags = getAllTags();

    allTags.add(tag);

    saveTags(allTags);
    WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
  }

  void deleteTag(Tag tag) {
    _allTags.remove(tag);
    saveTags(_allTags);
    WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
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
      order: 0,
    );
  }

  List<Tag> getAllTags() {
    _allTags = db.loadTags();
    return _allTags;
  }

  void saveTags(List<Tag> allTags) {
    db.saveTags(allTags);
  }

  void saveOrder(List<Tag> allTags) {
    for(int i = 0; i < allTags.length; i++) {
      allTags[i].order = i;
    }
  }

  void getTagsInOrder(List<Tag> allTags){
    List<Tag> sorted = [];

    while(sorted.length != _allTags.length){
      for (var tag in _allTags){
        if (tag.order == sorted.length){
          sorted.add(tag);
        }
      }
    }

    _allTags = sorted;
    saveTags(_allTags);
    WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
  }

  void sortTags(String sortBy, bool isSorted) {
    List<Tag> sortedTags = List.from(_allTags);

    if (sortBy == 'Title') {
      if (isSorted) {
        sortedTags.sort((a, b) => a.text.compareTo(b.text));
      } else {
        sortedTags.sort((a, b) => b.text.compareTo(a.text));
      }
    } else if (sortBy == 'Custom') {
      if (isSorted) {
        sortedTags.sort((a, b) => a.order.compareTo(b.order));
      } else {
        sortedTags.sort((a, b) => b.order.compareTo(a.order));
      }
    } 

    _allTags = sortedTags;
    saveTags(_allTags);
    WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
  }
}
