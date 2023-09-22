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

class Pinned extends StatefulWidget {
  const Pinned({Key? key}) : super(key: key);

  @override
  State<Pinned> createState() => _PinnedState();
}

class _PinnedState extends State<Pinned> with WidgetsBindingObserver {
  bool isSorted = false;
  bool isListView = true;
  bool isSearching = false;

  ValueNotifier<String> sortNotifier = ValueNotifier('Last Updated');
  final TextEditingController _searchController = TextEditingController();
  List<Note> _allNotes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<NoteData>(context, listen: false).initializeNotes();
  }

  @override
  void initState() {
    super.initState();
    Provider.of<NoteData>(context, listen: false).initializeNotes();
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
          Provider.of<NoteData>(context, listen: false).getPinnedNotes();

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
    int id =
        Provider.of<NoteData>(context, listen: false).getPinnedNotes().length;
    Note newNote = Note(
      id: id,
      text: '',
      title: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundColor: "white",
      isPinned: true,
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
    _allNotes = Provider.of<NoteData>(context).getPinnedNotes();
    List<Tag> allTags = Provider.of<TagData>(context).getAllTags();
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
                      'Pinned Notes',
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
                              child: Text('No Pinned Notes Yet...'),
                            ),
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                size: 20,
                                              )
                                            : const Icon(
                                                CupertinoIcons.arrow_down,
                                                color:
                                                    CupertinoColors.systemGrey,
                                                size: 20,
                                              ),
                                      ),
                                      SortDropdown(
                                        sortNotifier: sortNotifier,
                                        isSorted: isSorted,
                                        sort: sort,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      isSearching
                                          ? Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isSearching = false;
                                                      _searchController.clear();
                                                      _allNotes =
                                                          Provider.of<NoteData>(
                                                                  context)
                                                              .getPinnedNotes();
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    CupertinoIcons.clear,
                                                    color: CupertinoColors
                                                        .systemGrey,
                                                  ),
                                                ),
                                                TextField(
                                                    controller:
                                                        _searchController,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'Search',
                                                      border: InputBorder.none,
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _allNotes.where((note) {
                                                          return note.title
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      _searchController
                                                                          .text
                                                                          .toLowerCase()) ||
                                                              note.text
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      _searchController
                                                                          .text
                                                                          .toLowerCase());
                                                        }).toList();
                                                      });
                                                    }),
                                              ],
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isSearching = !isSearching;
                                                });
                                              },
                                              icon: const Icon(
                                                CupertinoIcons.search,
                                                color:
                                                    CupertinoColors.systemGrey,
                                              ),
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
                                                color:
                                                    CupertinoColors.systemGrey,
                                              ))
                                          : IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isListView = !isListView;
                                                });
                                              },
                                              icon: const Icon(
                                                CupertinoIcons.list_bullet,
                                                color:
                                                    CupertinoColors.systemGrey,
                                              ))
                                    ],
                                  ),
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
                                              i < _allNotes[index].tags.length;
                                              i++) {
                                            for (int j = 0;
                                                j < allTags.length;
                                                j++) {
                                              if (_allNotes[index].tags[i] ==
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
                                                          .getPinnedNotes()[
                                                              index]
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
                                                          .getPinnedNotes()[
                                                              index]
                                                          .isPinned
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ],
                                            ),
                                            child: NoteCard(
                                              title: value
                                                  .getPinnedNotes()[index]
                                                  .title,
                                              text: jsonDecode(value
                                                          .getPinnedNotes()[
                                                              index]
                                                          .text)[0]['insert'] !=
                                                      '\n'
                                                  ? jsonDecode(value
                                                      .getPinnedNotes()[index]
                                                      .text)[0]['insert']
                                                  : '',
                                              date: value
                                                  .getPinnedNotes()[index]
                                                  .updatedAt,
                                              backgroundColor: value
                                                  .getPinnedNotes()[index]
                                                  .backgroundColor,
                                              isPinned: value
                                                  .getPinnedNotes()[index]
                                                  .isPinned,
                                              onTap: () => goToNotePage(
                                                  _allNotes[index], false),
                                              tags: noteTags,
                                              folder: 'Folder',
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
                                            crossAxisSpacing: 8.0,
                                            mainAxisSpacing: 8.0,
                                          ),
                                          itemCount: _allNotes.length,
                                          itemBuilder: (context, index) {
                                            List<Tag> noteTags = [];

                                            for (int i = 0;
                                                i <
                                                    _allNotes[index]
                                                        .tags
                                                        .length;
                                                i++) {
                                              for (int j = 0;
                                                  j < allTags.length;
                                                  j++) {
                                                if (_allNotes[index].tags[i] ==
                                                    allTags[j].id) {
                                                  noteTags.add(allTags[j]);
                                                }
                                              }
                                            }
                                            return NoteGrid(
                                                title: value
                                                    .getAllNotes()[index]
                                                    .title,
                                                text: jsonDecode(_allNotes[index]
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
                                                });
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
