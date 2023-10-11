import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/components/grid_note.dart';
import 'package:notes/components/note_card.dart';
import 'package:notes/components/sort_dropdown.dart';
import 'package:notes/models/folder.dart';
import 'package:notes/models/folder_data.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/models/tag.dart';
import 'package:notes/models/tag_data.dart';
import 'package:notes/pages/editing_note.dart';
import 'package:pinput/pinput.dart';
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
  // bool isSearching = false;

  ValueNotifier<String> sortNotifier = ValueNotifier("");
  // final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    sortNotifier = ValueNotifier("Last Updated");
    Provider.of<NoteData>(context, listen: false).initializeNotes();
    Provider.of<TagData>(context, listen: false).initializeTags();
    Provider.of<FolderData>(context, listen: false).initializeFolders();

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
    int id = DateTime.now().millisecondsSinceEpoch;
    Note newNote = Note(
      id: id,
      text: '',
      title: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundColor: "white",
      isPinned: false,
      tags: [],
      folderId: 0,
      pin: '',
    );

    goToNotePage(newNote, true);
  }

  void deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.red,
              surface: Colors.white,
              background: Color.fromRGBO(238, 238, 238, 1),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black,
              onBackground: Colors.black,
            ),
          ),
          child: AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<NoteData>(context, listen: false)
                      .deleteNote(note);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }

  void sort(String sortBy, bool isSorted) {
    Provider.of<NoteData>(context, listen: false).sortNotes(sortBy, isSorted);
  }

  @override
  Widget build(BuildContext context) {
    List<Tag> allTags = Provider.of<TagData>(context).getAllTags();
    List<Folder> allFolders = Provider.of<FolderData>(context).getAllFolders();

    sort(sortNotifier.value, isSorted);
    return Consumer<NoteData>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 75, left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
                child: const Row(
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
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: SlidableAutoCloseBehavior(
                    child: value.getPinnedNotes().isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Center(
                              child: Text('No Pinned Notes Yet...'),
                            ),
                          )
                        : Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, right: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // isSearching
                                    //     ? Row(
                                    //         children: [
                                    //           SizedBox(
                                    //             width: MediaQuery.of(context)
                                    //                     .size
                                    //                     .width *
                                    //                 0.3,
                                    //             child: TextField(
                                    //               controller: _searchController,
                                    //               // placeholder: 'Search',
                                    //               decoration:
                                    //                   const InputDecoration(
                                    //                 hintText: 'Search',
                                    //                 hintStyle: TextStyle(
                                    //                   color: Colors.white,
                                    //                 ),
                                    //                 border: InputBorder.none,
                                    //               ),
                                    //               onChanged: (query) {
                                    //                 value.searchNotes(query);
                                    //               },
                                    //             ),
                                    //           ),
                                    //           SizedBox(
                                    //             width: 20,
                                    //             child: IconButton(
                                    //               onPressed: () {
                                    //                 setState(() {
                                    //                   isSearching =
                                    //                       !isSearching;
                                    //                 });
                                    //               },
                                    //               icon: const Icon(
                                    //                 CupertinoIcons.xmark,
                                    //                 color: Colors.grey,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       )
                                    //     : SizedBox(
                                    //         width: 20,
                                    //         child: IconButton(
                                    //           onPressed: () {
                                    //             setState(() {
                                    //               isSearching = !isSearching;
                                    //             });
                                    //           },
                                    //           icon: const Icon(
                                    //             CupertinoIcons.search,
                                    //             color: Colors.grey,
                                    //           ),
                                    //         ),
                                    //       ),
                                    Row(
                                      children: [
                                        SortDropdown(
                                          sortNotifier: sortNotifier,
                                          isSorted: isSorted,
                                          sort: sort,
                                        ),
                                        SizedBox(
                                          width: 24,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isSorted = !isSorted;
                                              });
                                              sort(
                                                  sortNotifier.value, isSorted);
                                            },
                                            icon: isSorted
                                                ? const Icon(
                                                    CupertinoIcons.arrow_up,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  )
                                                : const Icon(
                                                    CupertinoIcons.arrow_down,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                          child: isListView
                                              ? IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isListView = !isListView;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    CupertinoIcons
                                                        .rectangle_grid_2x2_fill,
                                                    color: Colors.grey,
                                                  ),
                                                )
                                              : IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isListView = !isListView;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    CupertinoIcons.list_bullet,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              isListView
                                  ? Flexible(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            value.getPinnedNotes().length,
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

                                          Folder? folder;

                                          for (int i = 0;
                                              i < allFolders.length;
                                              i++) {
                                            if (value
                                                    .allNotes[index].folderId ==
                                                allFolders[i].id) {
                                              folder = allFolders[i];
                                            }
                                          }

                                          return Slidable(
                                            startActionPane: ActionPane(
                                              extentRatio: 0.3,
                                              motion: const BehindMotion(),
                                              children: [
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    deleteNote(
                                                      value.getPinnedNotes()[
                                                          index],
                                                    );
                                                  },
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  icon:
                                                      CupertinoIcons.trash_fill,
                                                  foregroundColor: Colors.black,
                                                ),
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    allFolders.isNotEmpty
                                                        ? showCupertinoModalPopup(
                                                            context: context,
                                                            builder: (context) =>
                                                                CupertinoActionSheet(
                                                              actions: [
                                                                for (int i = 0;
                                                                    i <
                                                                        allFolders
                                                                            .length;
                                                                    i++)
                                                                  CupertinoActionSheetAction(
                                                                    onPressed:
                                                                        () {
                                                                      Provider.of<FolderData>(
                                                                              context,
                                                                              listen: false)
                                                                          .removeNoteFromFolder(
                                                                        value
                                                                            .getPinnedNotes()[index]
                                                                            .folderId,
                                                                        value.getPinnedNotes()[
                                                                            index],
                                                                      );
                                                                      value
                                                                          .moveNoteToFolder(
                                                                        value.getPinnedNotes()[
                                                                            index],
                                                                        allFolders[
                                                                            i],
                                                                      );

                                                                      Provider.of<FolderData>(
                                                                              context,
                                                                              listen: false)
                                                                          .moveNoteToFolder(
                                                                        value.getPinnedNotes()[
                                                                            index],
                                                                        allFolders[
                                                                            i],
                                                                      );
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                      allFolders[
                                                                              i]
                                                                          .title,
                                                                      style: TextStyle(
                                                                          color:
                                                                              getColorFromString(allFolders[i].color)),
                                                                    ),
                                                                  ),
                                                                // only remove if it's in one
                                                                if (value
                                                                        .getPinnedNotes()[
                                                                            index]
                                                                        .folderId !=
                                                                    0)
                                                                  CupertinoActionSheetAction(
                                                                    onPressed:
                                                                        () {
                                                                      Provider.of<FolderData>(
                                                                              context,
                                                                              listen: false)
                                                                          .removeNoteFromFolder(
                                                                        value
                                                                            .getPinnedNotes()[index]
                                                                            .folderId,
                                                                        value.getPinnedNotes()[
                                                                            index],
                                                                      );
                                                                      Provider.of<NoteData>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .removeFolder(
                                                                              value.getAllNotes()[index]);

                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: const Text(
                                                                        'Remove from Folder'),
                                                                  )
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
                                                          )
                                                        : Fluttertoast.showToast(
                                                            msg: "No folders",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Colors.red,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                  },
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  icon: CupertinoIcons
                                                      .folder_fill,
                                                  foregroundColor: Colors.black,
                                                ),
                                              ],
                                            ),
                                            endActionPane: ActionPane(
                                              extentRatio: 0.35,
                                              motion: const BehindMotion(),
                                              children: [
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    value.pinHandler(
                                                        value.getPinnedNotes()[
                                                            index]);
                                                    sort(
                                                      sortNotifier.value,
                                                      isSorted,
                                                    );
                                                    value.getPinnedNotes();
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
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    value
                                                                .getPinnedNotes()[
                                                                    index]
                                                                .pin ==
                                                            ''
                                                        ? showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              String notePin =
                                                                  '';
                                                              return Theme(
                                                                data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.red,
              surface: Colors.white,
              background: Color.fromRGBO(238, 238, 238, 1),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black,
              onBackground: Colors.black,
            ),
          ),
                                                                child:
                                                                    AlertDialog(
                                                                  title: const Text(
                                                                      'Lock Note'),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      const Text(
                                                                          'Enter a pin to lock this note:'),
                                                                      const SizedBox(
                                                                          height:
                                                                              12),
                                                                      Pinput(
                                                                        obscureText:
                                                                            true,
                                                                        onCompleted:
                                                                            (pin) {
                                                                          notePin =
                                                                              pin;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Provider.of<NoteData>(context, listen: false).lockNote(
                                                                            value.getPinnedNotes()[index],
                                                                            notePin);
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: const Text(
                                                                          'Lock'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              String notePin = value
                                                                  .getPinnedNotes()[
                                                                      index]
                                                                  .pin;
                                                              return Theme(
                                                                data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.red,
              surface: Colors.white,
              background: Color.fromRGBO(238, 238, 238, 1),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black,
              onBackground: Colors.black,
            ),
          ),
                                                                child:
                                                                    AlertDialog(
                                                                  title: const Text(
                                                                      'Unlocked Note'),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      const Text(
                                                                          'Enter the pin to unlock this note:'),
                                                                      const SizedBox(
                                                                          height:
                                                                              12),
                                                                      Pinput(
                                                                        obscureText:
                                                                            true,
                                                                        onCompleted:
                                                                            (pin) {
                                                                          if (pin ==
                                                                              notePin) {
                                                                            Provider.of<NoteData>(context, listen: false).lockNote(value.getPinnedNotes()[index],
                                                                                '');
                                                                            Navigator.of(context).pop();
                                                                          }
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          );
                                                  },
                                                  icon:
                                                      CupertinoIcons.lock_fill,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    16,
                                                  ),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  foregroundColor: Colors.black,
                                                ),
                                                // SlidableAction(
                                                //   onPressed: (context) {},
                                                //   icon:
                                                //       CupertinoIcons.bell_fill,
                                                //   borderRadius:
                                                //       BorderRadius.circular(
                                                //     16,
                                                //   ),
                                                //   backgroundColor:
                                                //       Colors.transparent,
                                                //   foregroundColor: Colors.black,
                                                // ),
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
                                              onTap: () {
                                                if (value
                                                        .getPinnedNotes()[index]
                                                        .pin ==
                                                    '') {
                                                  goToNotePage(
                                                      value.getPinnedNotes()[
                                                          index],
                                                      false);
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      String notePin = value
                                                          .getPinnedNotes()[
                                                              index]
                                                          .pin;
                                                      return Theme(
                                                        data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.red,
              surface: Colors.white,
              background: Color.fromRGBO(238, 238, 238, 1),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black,
              onBackground: Colors.black,
            ),
          ),
                                                        child: AlertDialog(
                                                          title: const Text(
                                                              'Open Locked Note'),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Text(
                                                                  'Enter the pin to enter this note:'),
                                                              const SizedBox(
                                                                  height: 12),
                                                              Pinput(
                                                                obscureText:
                                                                    true,
                                                                onCompleted:
                                                                    (pin) {
                                                                  if (pin ==
                                                                      notePin) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    goToNotePage(
                                                                        value.getPinnedNotes()[
                                                                            index],
                                                                        false);
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              tags: noteTags,
                                              folder: folder,
                                              pin: value
                                                  .getPinnedNotes()[index]
                                                  .pin,
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
                                          itemCount:
                                              value.getPinnedNotes().length,
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

                                            Folder? folder;

                                            for (int i = 0;
                                                i < allFolders.length;
                                                i++) {
                                              if (value.allNotes[index]
                                                      .folderId ==
                                                  allFolders[i].id) {
                                                folder = allFolders[i];
                                              }
                                            }
                                            return NoteGrid(
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
                                              tags: noteTags,
                                              folder: folder,
                                              pin: value
                                                  .getPinnedNotes()[index]
                                                  .pin,
                                              onTap: () {
                                                if (value
                                                        .getPinnedNotes()[index]
                                                        .pin ==
                                                    '') {
                                                  goToNotePage(
                                                      value.getPinnedNotes()[
                                                          index],
                                                      false);
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      String notePin = value
                                                          .getPinnedNotes()[
                                                              index]
                                                          .pin;
                                                      return Theme(
                                                        data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.red,
              surface: Colors.white,
              background: Color.fromRGBO(238, 238, 238, 1),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black,
              onBackground: Colors.black,
            ),
          ),
                                                        child: AlertDialog(
                                                          title: const Text(
                                                              'Open Locked Note'),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Text(
                                                                  'Enter the pin to enter this note:'),
                                                              const SizedBox(
                                                                  height: 12),
                                                              Pinput(
                                                                obscureText:
                                                                    true,
                                                                onCompleted:
                                                                    (pin) {
                                                                  if (pin ==
                                                                      notePin) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    goToNotePage(
                                                                        value.getPinnedNotes()[
                                                                            index],
                                                                        false);
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              onLongPress: () {
                                                showCupertinoModalPopup(
                                                  context: context,
                                                  builder: (context) =>
                                                      CupertinoActionSheet(
                                                    actions: [
                                                      CupertinoActionSheetAction(
                                                        onPressed: () {
                                                          deleteNote(
                                                            value.getPinnedNotes()[
                                                                index],
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
                                                          allFolders.isNotEmpty
                                                              ? showCupertinoModalPopup(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          CupertinoActionSheet(
                                                                    actions: [
                                                                      for (int i =
                                                                              0;
                                                                          i < allFolders.length;
                                                                          i++)
                                                                        CupertinoActionSheetAction(
                                                                          onPressed:
                                                                              () {
                                                                            Provider.of<FolderData>(context, listen: false).removeNoteFromFolder(
                                                                              value.getPinnedNotes()[index].folderId,
                                                                              value.getPinnedNotes()[index],
                                                                            );
                                                                            value.moveNoteToFolder(
                                                                              value.getPinnedNotes()[index],
                                                                              allFolders[i],
                                                                            );

                                                                            Provider.of<FolderData>(context, listen: false).moveNoteToFolder(
                                                                              value.getPinnedNotes()[index],
                                                                              allFolders[i],
                                                                            );
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            allFolders[i].title,
                                                                            style:
                                                                                TextStyle(color: getColorFromString(allFolders[i].color)),
                                                                          ),
                                                                        ),
                                                                      CupertinoActionSheetAction(
                                                                        onPressed:
                                                                            () {
                                                                          Provider.of<FolderData>(context, listen: false)
                                                                              .removeNoteFromFolder(
                                                                            value.getPinnedNotes()[index].folderId,
                                                                            value.getPinnedNotes()[index],
                                                                          );
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            'Remove from Folder'),
                                                                      ),
                                                                    ],
                                                                    cancelButton:
                                                                        CupertinoActionSheetAction(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Fluttertoast
                                                                  .showToast(
                                                                  msg:
                                                                      "No folders",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      16.0,
                                                                );
                                                        },
                                                        child: const Text(
                                                          'Move to Folder',
                                                        ),
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        onPressed: () {
                                                          value.pinHandler(value
                                                                  .getPinnedNotes()[
                                                              index]);
                                                          sort(
                                                              sortNotifier
                                                                  .value,
                                                              isSorted);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(value
                                                                .getPinnedNotes()[
                                                                    index]
                                                                .isPinned
                                                            ? 'Unpin'
                                                            : 'Pin'),
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          value
                                                                      .getPinnedNotes()[
                                                                          index]
                                                                      .pin ==
                                                                  ''
                                                              ? showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    String
                                                                        notePin =
                                                                        '';
                                                                    return Theme(
                                                                      data: Theme.of(
                                                                              context)
                                                                          .copyWith(
                                                                              dialogTheme: DialogTheme(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(16),
                                                                        ),
                                                                      )),
                                                                      child:
                                                                          AlertDialog(
                                                                        title: const Text(
                                                                            'Lock Note'),
                                                                        content:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            const Text('Enter a pin to lock this note:'),
                                                                            const SizedBox(height: 12),
                                                                            Pinput(
                                                                              obscureText: true,
                                                                              onCompleted: (pin) {
                                                                                notePin = pin;
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('Cancel'),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Provider.of<NoteData>(context, listen: false).lockNote(value.getPinnedNotes()[index], notePin);
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('Lock'),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                )
                                                              : showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    String
                                                                        notePin =
                                                                        value
                                                                            .getPinnedNotes()[index]
                                                                            .pin;
                                                                    return Theme(
                                                                      data: Theme.of(
                                                                              context)
                                                                          .copyWith(
                                                                              dialogTheme: DialogTheme(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(16),
                                                                        ),
                                                                      )),
                                                                      child:
                                                                          AlertDialog(
                                                                        title: const Text(
                                                                            'Unlocked Note'),
                                                                        content:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            const Text('Enter the pin to unlock this note:'),
                                                                            const SizedBox(height: 12),
                                                                            Pinput(
                                                                              obscureText: true,
                                                                              onCompleted: (pin) {
                                                                                if (pin == notePin) {
                                                                                  Provider.of<NoteData>(context, listen: false).lockNote(value.getPinnedNotes()[index], '');
                                                                                  Navigator.of(context).pop();
                                                                                }
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('Cancel'),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                        },
                                                        child: Text(value
                                                                    .getPinnedNotes()[
                                                                        index]
                                                                    .pin !=
                                                                ''
                                                            ? 'Unlock'
                                                            : 'Lock'),
                                                      ),
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                  ),
                                                );
                                              },
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
