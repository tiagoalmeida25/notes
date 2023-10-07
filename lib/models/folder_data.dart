import 'package:flutter/material.dart';
import 'package:notes/data/hive_database_folders.dart';
import 'package:notes/models/folder.dart';
import 'package:notes/models/note.dart';

class FolderData extends ChangeNotifier {
  final db = HiveFoldersDatabase();

  List<Folder> _allFolders = [];
  List<Folder> get allFolders => _allFolders;

  void initializeFolders() {
    _allFolders = db.loadFolders();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setAllFolders(List<Folder> folders) {
    _allFolders = folders;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void addNewFolder(Folder folder) {
    List<Folder> allFolders = getAllFolders();
    allFolders.add(folder);
    saveFolders(allFolders);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void deleteFolder(Folder folder) {
    _allFolders.remove(folder);
    saveFolders(_allFolders);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void removeNoteFromFolder(int folderId, Note note){
    for (int i = 0; i < _allFolders.length; i++) {
      if (_allFolders[i].id == folderId) {
        _allFolders[i].notes.remove(note.id);
      }
    }
    saveFolders(_allFolders);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateFolder(Folder folder, String title, DateTime updatedAt,
      String color, bool isPinned, List<int> notes) {
    for (int i = 0; i < _allFolders.length; i++) {
      if (_allFolders[i].id == folder.id) {
        _allFolders[i].title = title;
        _allFolders[i].updatedAt = updatedAt;
        _allFolders[i].color = color;
        _allFolders[i].isPinned = isPinned;
        _allFolders[i].notes = notes;
      }
    }
    saveFolders(_allFolders);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  List<Folder> getAllFolders() {
    _allFolders = db.loadFolders();
    return _allFolders;
  }

  void pinHandler(Folder folder) {
    for (int i = 0; i < _allFolders.length; i++) {
      if (_allFolders[i].id == folder.id) {
        _allFolders[i].isPinned = !_allFolders[i].isPinned;
      }
    }
    saveFolders(_allFolders);
  }

  void searchFolders(String query) {
    List<Folder> filteredFolders = [];
    if (query.isEmpty) {
      filteredFolders = getAllFolders();
    } else {
      filteredFolders = getAllFolders().where((folder) {
        return folder.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    _allFolders = filteredFolders;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void moveNoteToFolder(Note note, Folder folder) {
    for (int i = 0; i < allFolders.length; i++) {
      if (allFolders[i].id == folder.id) {
        folder.notes.add(note.id);
      }
    }

    saveFolders(allFolders);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  List<Folder> getPinnedFolders() {
    return _allFolders.where((folder) => folder.isPinned == true).toList();
  }

  void saveFolders(List<Folder> allFolders) {
    db.saveFolders(allFolders);
  }

  List<Folder> _sortInternally(
      String sortBy, bool isSorted, List<Folder> sortedFolders) {
    if (sortBy == 'Title') {
      if (isSorted) {
        sortedFolders.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      } else {
        sortedFolders.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      }
    } else if (sortBy == 'Last Updated') {
      if (isSorted) {
        sortedFolders.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      } else {
        sortedFolders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } else if (sortBy == 'Created') {
      if (isSorted) {
        sortedFolders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else {
        sortedFolders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }

    return sortedFolders;
  }

  void sortFolders(String sortBy, bool isSorted) {
    List<Folder> sortedFolders = getAllFolders();

    List<Folder> pinnedFolders =
        sortedFolders.where((folder) => folder.isPinned).toList();
    List<Folder> unpinnedFolders =
        sortedFolders.where((folder) => !folder.isPinned).toList();

    pinnedFolders = _sortInternally(sortBy, isSorted, pinnedFolders);
    unpinnedFolders = _sortInternally(sortBy, isSorted, unpinnedFolders);

    sortedFolders = [...pinnedFolders, ...unpinnedFolders];

    _allFolders = sortedFolders;
    saveFolders(_allFolders);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
