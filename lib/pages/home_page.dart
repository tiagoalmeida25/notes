import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/components/grid_note.dart';
import 'package:notes/components/list_note.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/pages/editing_note.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SortBy { title, lastUpdated, created }

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isSorted = false;
  bool isListView = true;
  ValueNotifier<SortBy> sortNotifier = ValueNotifier(SortBy.lastUpdated);

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
          Provider.of<NoteData>(context, listen: false).getAllNotes();

      Provider.of<NoteData>(context, listen: false).saveNotes(allNotes);
    }
  }

  void saveToPrefs(SortBy sortBy, bool isSorted, bool isListView) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('sortBy', sortBy.toString());
    await prefs.setBool('isSorted', isSorted);
    await prefs.setBool('isListView', isListView);
  }

  void getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    String? sortBy = prefs.getString('sortBy');
    bool? isSorted = prefs.getBool('isSorted');
    bool? isListView = prefs.getBool('isListView');

    if (sortBy != null) {
      if (sortBy == 'SortBy.title') {
        sortNotifier.value = SortBy.title;
      } else if (sortBy == 'SortBy.lastUpdated') {
        sortNotifier.value = SortBy.lastUpdated;
      } else if (sortBy == 'SortBy.created') {
        sortNotifier.value = SortBy.created;
      }
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
    );

    goToNotePage(newNote, true);
  }

  void deleteNote(Note note) {
    Provider.of<NoteData>(context, listen: false).deleteNote(note);
  }

  void sort(SortBy sortFor, bool isSorted) {
    String sortBy = '';
    if (sortFor == SortBy.title) {
      sortBy = 'Title';
    } else if (sortFor == SortBy.lastUpdated) {
      sortBy = 'LastUpdated';
    } else if (sortFor == SortBy.created) {
      sortBy = 'Created';
    }
    Provider.of<NoteData>(context, listen: false).sortNotes(sortBy, isSorted);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: CupertinoColors.systemBackground,
        floatingActionButton: FloatingActionButton(
          onPressed: createNewNote,
          backgroundColor: Colors.grey[400],
          child: const Icon(CupertinoIcons.add),
        ),
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
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SlidableAutoCloseBehavior(
                  child: value.getAllNotes().isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Center(
                            child: Text('No Notes Yet...'),
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<SortBy>(
                                        alignment: Alignment.centerRight,
                                        style: const TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 16,
                                        ),
                                        iconSize: 0.0,
                                        borderRadius: BorderRadius.circular(16),
                                        value: sortNotifier.value,
                                        items: const [
                                          DropdownMenuItem<SortBy>(
                                            value: SortBy.title,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons.textformat_alt,
                                                  color:
                                                      CupertinoColors.systemGrey,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 5),
                                                Text('Title'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem<SortBy>(
                                            value: SortBy.lastUpdated,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons.clock,
                                                  color:
                                                      CupertinoColors.systemGrey,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 5),
                                                Text('Last updated'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem<SortBy>(
                                            value: SortBy.created,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons.plus_app,
                                                  color:
                                                      CupertinoColors.systemGrey,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 5),
                                                Text('Created'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onChanged: (SortBy? value) {
                                          if (value != null) {
                                            sort(sortNotifier.value, isSorted);
                                          }
                                        },
                                      ),
                                    ),
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
                                              color: CupertinoColors.systemGrey,
                                            )
                                          : const Icon(CupertinoIcons.arrow_down,
                                              color: CupertinoColors.systemGrey),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        CupertinoIcons.search,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                    isListView ?
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isListView = !isListView;
                                          });
                                        },
                                        icon: const Icon(
                                          CupertinoIcons
                                              .rectangle_grid_2x2_fill,
                                          color: CupertinoColors.systemGrey,
                                        )) : IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isListView = !isListView;
                                              });
                                            },
                                            icon: const Icon(
                                              CupertinoIcons
                                                  .list_bullet,
                                              color: CupertinoColors.systemGrey,
                                            ))
                                  ],
                                ),
                              ],
                            ),
                            isListView ?
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: value.getAllNotes().length,
                              itemBuilder: (context, index) {
                                return Slidable(
                                  groupTag: 'delete',
                                  startActionPane: ActionPane(
                                    extentRatio: 0.15,
                                    motion: const StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) => deleteNote(
                                          value.getAllNotes()[index],
                                        ),
                                        backgroundColor: Colors.red,
                                        borderRadius: BorderRadius.circular(16),
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
                                          value.getAllNotes()[index].isPinned =
                                              !value
                                                  .getAllNotes()[index]
                                                  .isPinned!;
                                          value.saveNotes(value.getAllNotes());
                                          sort(sortNotifier.value, isSorted);
                                        },
                                        icon: value.getAllNotes()[index].isPinned!
                                            ? CupertinoIcons.pin_slash_fill
                                            : CupertinoIcons.pin_fill,
                                        borderRadius: BorderRadius.circular(16),
                                        foregroundColor:
                                            value.getAllNotes()[index].isPinned!
                                                ? Colors.grey
                                                : Colors.black,
                                      ),
                                    ],
                                  ),
                                  child: ListNote(
                                    title: value.getAllNotes()[index].title,
                                    text: jsonDecode(value
                                                .getAllNotes()[index]
                                                .text)[0]['insert'] !=
                                            '\n'
                                        ? jsonDecode(value
                                            .getAllNotes()[index]
                                            .text)[0]['insert']
                                        : '',
                                    updatedAt:
                                        value.getAllNotes()[index].updatedAt!,
                                    backgroundColor: value
                                        .getAllNotes()[index]
                                        .backgroundColor!,
                                    isPinned:
                                        value.getAllNotes()[index].isPinned!,
                                    onTap: () => goToNotePage(
                                        value.getAllNotes()[index], false),
                                  ),
                                );
                              },
                            ) : Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            2, // Number of items per row (2 in this case)
                                        crossAxisSpacing:
                                            8.0, // Adjust the spacing between items as needed
                                        mainAxisSpacing:
                                            8.0, // Adjust the spacing between rows as needed
                                      ),
                                      itemCount: value.getAllNotes().length,
                                      itemBuilder: (context, index) {
                                        
                                        return isListView ? Slidable(
                                          groupTag: 'delete',
                                          startActionPane: ActionPane(
                                            extentRatio: 0.15,
                                            motion: const StretchMotion(),
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) => deleteNote(
                                                  value.getAllNotes()[index],
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
                                                          .getAllNotes()[index]
                                                          .isPinned =
                                                      !value
                                                          .getAllNotes()[index]
                                                          .isPinned!;
                                                  value.saveNotes(
                                                      value.getAllNotes());
                                                  sort(
                                                      sortNotifier.value, isSorted);
                                                },
                                                icon: value
                                                        .getAllNotes()[index]
                                                        .isPinned!
                                                    ? CupertinoIcons.pin_slash_fill
                                                    : CupertinoIcons.pin_fill,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                foregroundColor: value
                                                        .getAllNotes()[index]
                                                        .isPinned!
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ],
                                          ),
                                          child: GridNote(
                                            title: value.getAllNotes()[index].title,
                                            text: jsonDecode(value
                                                        .getAllNotes()[index]
                                                        .text)[0]['insert'] !=
                                                    '\n'
                                                ? jsonDecode(value
                                                    .getAllNotes()[index]
                                                    .text)[0]['insert']
                                                : '',
                                            updatedAt: value
                                                .getAllNotes()[index]
                                                .updatedAt!,
                                            backgroundColor: value
                                                .getAllNotes()[index]
                                                .backgroundColor!,
                                            isPinned: value
                                                .getAllNotes()[index]
                                                .isPinned!,
                                            onTap: () => goToNotePage(
                                                value.getAllNotes()[index], false),
                                          ),
                                        ) : GridNote(
                                            title: value.getAllNotes()[index].title,
                                            text: jsonDecode(value
                                                        .getAllNotes()[index]
                                                        .text)[0]['insert'] !=
                                                    '\n'
                                                ? jsonDecode(value
                                                    .getAllNotes()[index]
                                                    .text)[0]['insert']
                                                : '',
                                            updatedAt: value
                                                .getAllNotes()[index]
                                                .updatedAt!,
                                            backgroundColor: value
                                                .getAllNotes()[index]
                                                .backgroundColor!,
                                            isPinned: value
                                                .getAllNotes()[index]
                                                .isPinned!,
                                            onTap: () => goToNotePage(
                                                value.getAllNotes()[index], false),
                                            onLongPress: (){
                                              // delete or pin
                                              showCupertinoModalPopup(
                                                context: context,
                                                builder: (context) => CupertinoActionSheet(
                                                  actions: [
                                                    CupertinoActionSheetAction(
                                                      onPressed: (){
                                                        value.deleteNote(
                                                          value.getAllNotes()[index],
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Delete'),
                                                      isDestructiveAction: true,
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      onPressed: (){
                                                        value.getAllNotes()[index].isPinned =
                                                            !value
                                                                .getAllNotes()[index]
                                                                .isPinned!;
                                                        value.saveNotes(
                                                            value.getAllNotes());
                                                        sort(
                                                            sortNotifier.value, isSorted);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(value
                                                              .getAllNotes()[index]
                                                              .isPinned!
                                                          ? 'Unpin'
                                                          : 'Pin'),
                                                    ),
                                                  ],
                                                  cancelButton: CupertinoActionSheetAction(
                                                    onPressed: (){
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                ),                                                
                                              );
                                            }
                                          );
                                      },
                                    ),
                            )
            
                          ],
                        ),
                ), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
