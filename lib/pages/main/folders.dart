import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/components/folder_card.dart';
import 'package:notes/components/sort_dropdown.dart';
import 'package:notes/models/folder.dart';
import 'package:notes/models/folder_data.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/models/tag_data.dart';
import 'package:notes/pages/inside_folder.dart';
import 'package:pinput/pinput.dart';
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

  ValueNotifier<String> sortNotifier = ValueNotifier("");

  // bool isSearching = false;

  // final TextEditingController _searchController = TextEditingController();

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

  void goInsideFolder(value, index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsideFolder(
          folder: value.getAllFolders()[index],
        ),
      ),
    );
  }

  

  void deleteFolder(Folder folder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
              dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          )),
          child: AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this folder?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<FolderData>(context, listen: false)
                      .deleteFolder(folder);
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
               Padding(
                padding: EdgeInsets.only(top: 75, left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
                child: const Row(
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
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
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
                                  //                   color: CupertinoColors
                                  //                       .systemGrey,
                                  //                 ),
                                  //                 border: InputBorder.none,
                                  //               ),
                                  //               onChanged: (query) {
                                  //                 value.searchFolders(query);
                                  //               },
                                  //             ),
                                  //           ),
                                  //           SizedBox(
                                  //             width: 20,
                                  //             child: IconButton(
                                  //               onPressed: () {
                                  //                 setState(() {
                                  //                   isSearching = !isSearching;
                                  //                 });
                                  //               },
                                  //               icon: const Icon(
                                  //                 CupertinoIcons.xmark,
                                  //                 color: CupertinoColors
                                  //                     .systemGrey,
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
                                  //             color: CupertinoColors.systemGrey,
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
                                    ],
                                  ),
                                ],
                              ),
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: value.getAllFolders().length,
                                  itemBuilder: (context, index) {
                                    List<Note> folderNotes = [];

                                    if (value
                                        .allFolders[index].notes.isNotEmpty) {
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
                                    }
                                    return Slidable(
                                      groupTag: 'delete',
                                      startActionPane: ActionPane(
                                        extentRatio: 0.15,
                                        motion: const BehindMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              deleteFolder(
                                                value.getAllFolders()[index],
                                              );
                                            },
                                            backgroundColor: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            icon: CupertinoIcons.trash_fill,
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
                                                  value.getAllFolders()[index]);
                                              sort(
                                                sortNotifier.value,
                                                isSorted,
                                              );
                                              value.getAllFolders();
                                            },
                                            icon: value
                                                    .getAllFolders()[index]
                                                    .isPinned
                                                ? CupertinoIcons.pin_slash_fill
                                                : CupertinoIcons.pin_fill,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: value
                                                    .getAllFolders()[index]
                                                    .isPinned
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                          SlidableAction(
                                            onPressed: (context) {
                                              value
                                                          .getAllFolders()[
                                                              index]
                                                          .pin ==
                                                      ''
                                                  ? showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        String folderPin = '';
                                                        return Theme(
                                                          data: Theme.of(
                                                                  context)
                                                              .copyWith(
                                                                  dialogTheme:
                                                                      DialogTheme(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                          )),
                                                          child: AlertDialog(
                                                            title: const Text(
                                                                'Lock Folder'),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Text(
                                                                    'Enter a pin to lock this folder:'),
                                                                const SizedBox(
                                                                    height: 12),
                                                                Pinput(
                                                                  obscureText:
                                                                      true,
                                                                  onCompleted:
                                                                      (pin) {
                                                                    folderPin =
                                                                        pin;
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
                                                              TextButton(
                                                                onPressed: () {
                                                                  Provider.of<FolderData>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .lockFolder(
                                                                          value.getAllFolders()[
                                                                              index],
                                                                          folderPin);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Lock'),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        String folderPin = value
                                                            .getAllFolders()[
                                                                index]
                                                            .pin;
                                                        return Theme(
                                                          data: Theme.of(
                                                                  context)
                                                              .copyWith(
                                                                  dialogTheme:
                                                                      DialogTheme(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                          )),
                                                          child: AlertDialog(
                                                            title: const Text(
                                                                'Unlocked Note'),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Text(
                                                                    'Enter the pin to unlock this note:'),
                                                                const SizedBox(
                                                                    height: 12),
                                                                Pinput(
                                                                  obscureText:
                                                                      true,
                                                                  onCompleted:
                                                                      (pin) {
                                                                    if (pin ==
                                                                        folderPin) {
                                                                      Provider.of<FolderData>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .lockFolder(
                                                                              value.getAllFolders()[index],
                                                                              '');
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
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
                                            },
                                            icon: CupertinoIcons.lock_fill,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.black,
                                          ),
                                          // SlidableAction(
                                          //   onPressed: (context) {},
                                          //   icon: CupertinoIcons.bell_fill,
                                          //   borderRadius: BorderRadius.circular(
                                          //     16,
                                          //   ),
                                          //   backgroundColor: Colors.transparent,
                                          //   foregroundColor: Colors.black,
                                          // ),
                                        ],
                                      ),
                                      child: FolderCard(
                                        title:
                                            value.getAllFolders()[index].title,
                                        color:
                                            value.getAllFolders()[index].color,
                                        isPinned: value
                                            .getAllFolders()[index]
                                            .isPinned,
                                        date: value
                                            .getAllFolders()[index]
                                            .createdAt,
                                        onTap: () {
                                          if (value
                                                  .getAllFolders()[index]
                                                  .pin ==
                                              '') {
                                            goInsideFolder(value, index);
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                String notePin = value
                                                    .getAllFolders()[index]
                                                    .pin;
                                                return Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                          dialogTheme:
                                                              DialogTheme(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  )),
                                                  child: AlertDialog(
                                                    title: const Text(
                                                        'Open Locked Folder'),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                            'Enter the pin to enter this folder:'),
                                                        const SizedBox(
                                                            height: 12),
                                                        Pinput(
                                                          obscureText: true,
                                                          onCompleted: (pin) {
                                                            if (pin ==
                                                                notePin) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              goInsideFolder(
                                                                  value, index);
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
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
                                          }
                                        },
                                        notes: folderNotes,
                                        folder: 'folder',
                                        pin: value.getAllFolders()[index].pin,
                                      ),
                                    );
                                  },
                                ),
                              ),
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
