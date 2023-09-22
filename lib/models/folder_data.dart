import 'package:flutter/material.dart';
import 'package:notes/data/hive_database_folders.dart';
import 'package:notes/models/folder.dart';

class FolderData extends ChangeNotifier {
  final db = HiveFoldersDatabase();

  List<Folder> _allFolders = [];
  List<Folder> get allFolders => _allFolders;

  void initializeFolders() {
    _allFolders = db.loadFolders();
    notifyListeners();
  }

  void setAllFolders(List<Folder> folders) {
    _allFolders = folders;
    notifyListeners();
  }

  void addNewFolder(Folder folder) {
    List<Folder> allFolders = getAllFolders();
    allFolders.add(folder);
    saveFolders(allFolders);
    notifyListeners();
  }

  void deleteFolder(Folder folder) {
    _allFolders.remove(folder);
    saveFolders(_allFolders);

    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }
}
