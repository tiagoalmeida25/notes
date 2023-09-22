import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/components/grid_folder.dart';
import 'package:notes/components/sort_dropdown.dart';
import 'package:notes/models/folder.dart';
import 'package:notes/models/folder_data.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/models/tag_data.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Folders extends StatefulWidget {
  const Folders({Key? key}) : super(key: key);

  @override
  State<Folders> createState() => _FoldersState();
}

class _FoldersState extends State<Folders> with WidgetsBindingObserver {
  bool isSorted = false;
  bool isSearching = false;

  ValueNotifier<String> sortNotifier = ValueNotifier("");

  @override
  void initState() {
    super.initState();
    sortNotifier = ValueNotifier("Title");
    Provider.of<FolderData>(context, listen: false).initializeFolders();
    Provider.of<NoteData>(context, listen: false).initializeNotes();
    Provider.of<TagData>(context, listen: false).initializeTags();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      List<Folder> allFolders =
          Provider.of<FolderData>(context, listen: false).getAllFolders();

      Provider.of<FolderData>(context, listen: false).saveFolders(allFolders);
    }
  }

  void saveToPrefs(String sortBy, bool isSorted, bool isListView) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('sortBy', sortBy);
    await prefs.setBool('isSorted', isSorted);
  }

  void getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    String? sortBy = prefs.getString('sortBy');
    bool? isSorted = prefs.getBool('isSorted');

    if (sortBy != null) {
      sortNotifier.value = sortBy;
    }

    if (isSorted != null) {
      this.isSorted = isSorted;
    }
  }

  void deleteFolder(Folder folder) {
    Provider.of<FolderData>(context, listen: false).deleteFolder(folder);
  }

  void sort(String sortBy, bool isSorted) {
    Provider.of<FolderData>(context, listen: false)
        .sortFolders(sortBy, isSorted);
  }

  @override
  Widget build(BuildContext context) {
    List<Note> allNotes = Provider.of<NoteData>(context).getAllNotes();

    sort(sortNotifier.value, isSorted);
    return Consumer<FolderData>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: CupertinoColors.systemBackground,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 75, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Folders',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SlidableAutoCloseBehavior(
                    child: value.getAllFolders().isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Center(
                              child: Text('No Folders Yet...'),
                            ),
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isSorted = !isSorted;
                                          });
                                          sort(sortNotifier.value, isSorted);
                                        },
                                        icon: isSorted
                                            ? const Icon(
                                                CupertinoIcons.arrow_up,
                                                color:
                                                    CupertinoColors.systemGrey,
                                                size: 18,
                                              )
                                            : const Icon(
                                                CupertinoIcons.arrow_down,
                                                color:
                                                    CupertinoColors.systemGrey,
                                                size: 18,
                                              ),
                                      ),
                                      SortDropdown(
                                        sortNotifier: sortNotifier,
                                        isSorted: isSorted,
                                        sort: sort,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Flexible(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.72,
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    itemCount: value.getAllFolders().length,
                                    itemBuilder: (context, index) {
                                      List<Note> folderNotes = [];

                                      for (int i = 0;
                                          i <
                                              value.allFolders[index].notes
                                                  .length;
                                          i++) {
                                        for (int j = 0;
                                            j < allNotes.length;
                                            j++) {
                                          if (value
                                                  .allFolders[index].notes[i] ==
                                              allNotes[j].id) {
                                            folderNotes.add(allNotes[j]);
                                          }
                                        }
                                      }
                                      return Slidable(
                                        groupTag: 'delete',
                                        startActionPane: ActionPane(
                                          extentRatio: 0.15,
                                          motion: const StretchMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) =>
                                                  deleteFolder(
                                                value.getAllFolders()[index],
                                              ),
                                              backgroundColor: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              icon: CupertinoIcons.trash,
                                              foregroundColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                        endActionPane: ActionPane(
                                          extentRatio: 0.15,
                                          motion: const StretchMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) {
                                                value
                                                        .getAllFolders()[index]
                                                        .isPinned =
                                                    !value
                                                        .getAllFolders()[index]
                                                        .isPinned;
                                                value.saveFolders(
                                                    value.getAllFolders());
                                                sort(sortNotifier.value,
                                                    isSorted);
                                              },
                                              icon: value
                                                      .getAllFolders()[index]
                                                      .isPinned
                                                  ? CupertinoIcons
                                                      .pin_slash_fill
                                                  : CupertinoIcons.pin_fill,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              foregroundColor: value
                                                      .getAllFolders()[index]
                                                      .isPinned
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ],
                                        ),
                                        child: FolderGrid(
                                          title: value
                                              .getAllFolders()[index]
                                              .title,
                                          date: value
                                              .getAllFolders()[index]
                                              .updatedAt,
                                          color: value
                                              .getAllFolders()[index]
                                              .color,
                                          isPinned: value
                                              .getAllFolders()[index]
                                              .isPinned,
                                          notes: folderNotes,
                                          onTap: () {},
                                          onLongPress: () {
                                            showCupertinoModalPopup(
                                              context: context,
                                              builder: (context) =>
                                                  CupertinoActionSheet(
                                                actions: [
                                                  CupertinoActionSheetAction(
                                                    onPressed: () {
                                                      value.deleteFolder(
                                                        value.getAllFolders()[
                                                            index],
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    isDestructiveAction: true,
                                                    child: const Text('Delete'),
                                                  ),
                                                  CupertinoActionSheetAction(
                                                    onPressed: () {
                                                      value
                                                              .getAllFolders()[
                                                                  index]
                                                              .isPinned =
                                                          !value
                                                              .getAllFolders()[
                                                                  index]
                                                              .isPinned;
                                                      value.saveFolders(value
                                                          .getAllFolders());
                                                      sort(sortNotifier.value,
                                                          isSorted);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(value
                                                            .getAllFolders()[
                                                                index]
                                                            .isPinned
                                                        ? 'Unpin'
                                                        : 'Pin'),
                                                  ),
                                                ],
                                                cancelButton:
                                                    CupertinoActionSheetAction(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
