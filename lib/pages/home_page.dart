import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/pages/editing_note.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SortBy { title, lastUpdated, created }

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isSorted = false;
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
    );

    goToNotePage(newNote, true);
  }

  void deleteNote(Note note) {
    Provider.of<NoteData>(context, listen: false).deleteNote(note);
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
              padding: EdgeInsets.only(top: 75, left: 18, right: 18),
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
            SlidableAutoCloseBehavior(
              child: value.getAllNotes().isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Center(
                        child: Text('No Notes Yet...'),
                      ),
                    )
                  : CupertinoListSection.insetGrouped(
                      backgroundColor: CupertinoColors.systemBackground,
                      header: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                                              color: CupertinoColors.systemGrey,
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
                                              color: CupertinoColors.systemGrey,
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
                                              color: CupertinoColors.systemGrey,
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
                                        String sortBy = '';
                                        if (value == SortBy.title) {
                                          sortBy = 'Title';
                                        } else if (value ==
                                            SortBy.lastUpdated) {
                                          sortBy = 'LastUpdated';
                                        } else if (value == SortBy.created) {
                                          sortBy = 'Created';
                                        }
                                        sortNotifier.value = value;

                                        Provider.of<NoteData>(context,
                                                listen: false)
                                            .sortNotes(sortBy, isSorted);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    String sortBy = '';
                                    if (sortNotifier.value == SortBy.title) {
                                      sortBy = 'Title';
                                    } else if (sortNotifier.value ==
                                        SortBy.lastUpdated) {
                                      sortBy = 'LastUpdated';
                                    } else if (sortNotifier.value ==
                                        SortBy.created) {
                                      sortBy = 'Created';
                                    }
                                    isSorted = !isSorted;
                                    Provider.of<NoteData>(context,
                                            listen: false)
                                        .sortNotes(sortBy, isSorted);
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
                          ]),
                      children: List.generate(
                        value.getAllNotes().length,
                        (index) => Slidable(
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
                                icon: CupertinoIcons.trash,
                                foregroundColor: Colors.white,
                              ),
                            ],
                          ),
                          child: CupertinoListTile(
                            title: Text(
                              value.getAllNotes()[index].title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle:
                                jsonDecode(value.getAllNotes()[index].text)[0]
                                            ['insert'] !=
                                        '\n'
                                    ? Text(jsonDecode(
                                            value.getAllNotes()[index].text)[0]
                                        ['insert'])
                                    : null,
                            trailing: const Icon(CupertinoIcons.chevron_right),
                            onTap: () {
                              goToNotePage(value.getAllNotes()[index], false);
                            },
                            backgroundColor: Colors.grey[200],
                          ),
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
