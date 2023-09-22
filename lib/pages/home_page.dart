import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/components/grid_note.dart';
import 'package:notes/components/note_card.dart';
import 'package:notes/components/sort_dropdown.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/models/tag.dart';
import 'package:notes/models/tag_data.dart';
import 'package:notes/pages/editing_note.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isSorted = false;
  bool isListView = true;
  bool isSearching = false;

  ValueNotifier<String> sortNotifier = ValueNotifier("");
  final TextEditingController _searchController = TextEditingController();
  List<Note> _allNotes = [];

  @override
  void initState() {
    super.initState();
    sortNotifier = ValueNotifier("Last Updated");
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
      List<Note> allNotes =
          Provider.of<NoteData>(context, listen: false).getAllNotes();

      Provider.of<NoteData>(context, listen: false).saveNotes(allNotes);
    }
  }

  void saveToPrefs(String sortBy, bool isSorted, bool isListView) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('sortBy', sortBy);
    await prefs.setBool('isSorted', isSorted);
    await prefs.setBool('isListView', isListView);
  }

  void getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    String? sortBy = prefs.getString('sortBy');
    bool? isSorted = prefs.getBool('isSorted');
    bool? isListView = prefs.getBool('isListView');

    if (sortBy != null) {
      sortNotifier.value = sortBy;
    }

    if (isSorted != null) {
      this.isSorted = isSorted;
    }

    if (isListView != null) {
      this.isListView = isListView;
    }
  }

  void goToNotePage(Note note, bool isNewNote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditingNote(
          note: note,
          isNewNote: isNewNote,
        ),
      ),
    );
  }

  void createNewNote() {
    int id = Provider.of<NoteData>(context, listen: false).getAllNotes().length;
    Note newNote = Note(
      id: id,
      text: '',
      title: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundColor: "white",
      isPinned: false,
      tags: [],
    );

    goToNotePage(newNote, true);
  }

  void deleteNote(Note note) {
    Provider.of<NoteData>(context, listen: false).deleteNote(note);
  }

  void sort(String sortBy, bool isSorted) {
    Provider.of<NoteData>(context, listen: false).sortNotes(sortBy, isSorted);
  }

  @override
  Widget build(BuildContext context) {
    _allNotes = Provider.of<NoteData>(context).getAllNotes();
    List<Tag> allTags = Provider.of<TagData>(context).getAllTags();

    sort(sortNotifier.value, isSorted);
    return Consumer<NoteData>(
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
                      'Notes',
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
                    child: _allNotes.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Center(
                              child: Text('No Notes Yet...'),
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
                                  isSearching
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              child:
                                                  CupertinoTextField.borderless(
                                                controller: _searchController,
                                                placeholder: 'Search notes',
                                                onChanged: (query) {
                                                  value.searchNotes(query);
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.clear,
                                                  color: Colors.grey),
                                              onPressed: () {
                                                setState(() {
                                                  isSearching = !isSearching;
                                                  _searchController.clear();
                                                  value.getAllNotes();
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            CupertinoIcons.search,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isSearching = !isSearching;
                                              if (!isSearching) {
                                                _searchController.clear();
                                                value.getAllNotes();
                                              }
                                            });
                                          },
                                        ),
                                  isListView
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isListView = !isListView;
                                            });
                                          },
                                          icon: const Icon(
                                            CupertinoIcons
                                                .rectangle_grid_2x2_fill,
                                            color: CupertinoColors.systemGrey,
                                          ))
                                      : IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isListView = !isListView;
                                            });
                                          },
                                          icon: const Icon(
                                            CupertinoIcons.list_bullet,
                                            color: CupertinoColors.systemGrey,
                                          ))
                                ],
                              ),
                              isListView
                                  ? Flexible(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _allNotes.length,
                                        itemBuilder: (context, index) {
                                          List<Tag> noteTags = [];

                                          for (int i = 0;
                                              i <
                                                  value.allNotes[index].tags
                                                      .length;
                                              i++) {
                                            for (int j = 0;
                                                j < allTags.length;
                                                j++) {
                                              if (value.allNotes[index]
                                                      .tags[i] ==
                                                  allTags[j].id) {
                                                noteTags.add(allTags[j]);
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
                                                  onPressed: (context) {
                                                    deleteNote(
                                                      _allNotes[index],
                                                    );
                                                    value.saveNotes(_allNotes);
                                                    sort(
                                                      sortNotifier.value,
                                                      isSorted,
                                                    );
                                                  },
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
                                                    _allNotes[index].isPinned =
                                                        !_allNotes[index]
                                                            .isPinned;
                                                    value.saveNotes(_allNotes);
                                                    sort(
                                                      sortNotifier.value,
                                                      isSorted,
                                                    );
                                                  },
                                                  icon: value
                                                          .getAllNotes()[index]
                                                          .isPinned
                                                      ? CupertinoIcons
                                                          .pin_slash_fill
                                                      : CupertinoIcons.pin_fill,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    16,
                                                  ),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  foregroundColor: value
                                                          .getAllNotes()[index]
                                                          .isPinned
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ],
                                            ),
                                            child: NoteCard(
                                              title: value
                                                  .getAllNotes()[index]
                                                  .title,
                                              text: jsonDecode(value
                                                          .getAllNotes()[index]
                                                          .text)[0]['insert'] !=
                                                      '\n'
                                                  ? jsonDecode(value
                                                      .getAllNotes()[index]
                                                      .text)[0]['insert']
                                                  : '',
                                              date: value
                                                  .getAllNotes()[index]
                                                  .updatedAt,
                                              backgroundColor: value
                                                  .getAllNotes()[index]
                                                  .backgroundColor,
                                              isPinned: value
                                                  .getAllNotes()[index]
                                                  .isPinned,
                                              onTap: () => goToNotePage(
                                                  _allNotes[index], false),
                                              tags: noteTags,
                                              folder: 'folder',
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Flexible(
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.72,
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                          ),
                                          itemCount: _allNotes.length,
                                          itemBuilder: (context, index) {
                                            List<Tag> noteTags = [];

                                            for (int i = 0;
                                                i <
                                                    value.allNotes[index].tags
                                                        .length;
                                                i++) {
                                              for (int j = 0;
                                                  j < allTags.length;
                                                  j++) {
                                                if (value.allNotes[index]
                                                        .tags[i] ==
                                                    allTags[j].id) {
                                                  noteTags.add(allTags[j]);
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
                                                        deleteNote(
                                                      _allNotes[index],
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    icon: CupertinoIcons.trash,
                                                    foregroundColor:
                                                        Colors.white,
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
                                                              .getAllNotes()[index]
                                                              .isPinned =
                                                          !value
                                                              .getAllNotes()[
                                                                  index]
                                                              .isPinned;
                                                      value.saveNotes(
                                                          value.getAllNotes());
                                                      sort(sortNotifier.value,
                                                          isSorted);
                                                    },
                                                    icon: value
                                                            .getAllNotes()[
                                                                index]
                                                            .isPinned
                                                        ? CupertinoIcons
                                                            .pin_slash_fill
                                                        : CupertinoIcons
                                                            .pin_fill,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    foregroundColor: value
                                                            .getAllNotes()[
                                                                index]
                                                            .isPinned
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                ],
                                              ),
                                              child: NoteGrid(
                                                title: value
                                                    .getAllNotes()[index]
                                                    .title,
                                                text: jsonDecode(
                                                                _allNotes[index]
                                                                    .text)[0]
                                                            ['insert'] !=
                                                        '\n'
                                                    ? jsonDecode(value
                                                        .getAllNotes()[index]
                                                        .text)[0]['insert']
                                                    : '',
                                                date: value
                                                    .getAllNotes()[index]
                                                    .updatedAt,
                                                backgroundColor: value
                                                    .getAllNotes()[index]
                                                    .backgroundColor,
                                                isPinned: value
                                                    .getAllNotes()[index]
                                                    .isPinned,
                                                tags: noteTags,
                                                folder: 'folder',
                                                onTap: () => goToNotePage(
                                                    _allNotes[index], false),
                                                onLongPress: () {
                                                  // delete or pin
                                                  showCupertinoModalPopup(
                                                    context: context,
                                                    builder: (context) =>
                                                        CupertinoActionSheet(
                                                      actions: [
                                                        CupertinoActionSheetAction(
                                                          onPressed: () {
                                                            value.deleteNote(
                                                              _allNotes[index],
                                                            );
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          isDestructiveAction:
                                                              true,
                                                          child: const Text(
                                                              'Delete'),
                                                        ),
                                                        CupertinoActionSheetAction(
                                                          onPressed: () {
                                                            _allNotes[index]
                                                                    .isPinned =
                                                                !value
                                                                    .getAllNotes()[
                                                                        index]
                                                                    .isPinned;
                                                            value.saveNotes(value
                                                                .getAllNotes());
                                                            sort(
                                                                sortNotifier
                                                                    .value,
                                                                isSorted);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(value
                                                                  .getAllNotes()[
                                                                      index]
                                                                  .isPinned
                                                              ? 'Unpin'
                                                              : 'Pin'),
                                                        ),
                                                      ],
                                                      cancelButton:
                                                          CupertinoActionSheetAction(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Cancel'),
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
