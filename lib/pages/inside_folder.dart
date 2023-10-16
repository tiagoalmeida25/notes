import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/components/note_card.dart';
import 'package:notes/models/folder.dart';
import 'package:notes/models/folder_data.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/models/tag.dart';
import 'package:notes/models/tag_data.dart';
import 'package:notes/pages/editing_note.dart';
import 'package:provider/provider.dart';

class InsideFolder extends StatefulWidget {
  final Folder? folder;

  const InsideFolder({Key? key, this.folder}) : super(key: key);

  @override
  InsideFolderState createState() => InsideFolderState();
}

class InsideFolderState extends State<InsideFolder> {
  List<Note> notes = [];

  late TextEditingController _textEditingController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: widget.folder?.title ?? '');
    _color = widget.folder != null
        ? getColorFromString(widget.folder!.color)
        : AppColors.tagColors.first;
  }

  @override
  void dispose() {
    _handleSave();
    _textEditingController.dispose();
    super.dispose();
  }

  void _handleColorChanged(Color color) {
    setState(() {
      _color = color;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      notes = Provider.of<NoteData>(context, listen: false)
          .getAllNotes()
          .where((note) => note.folderId == widget.folder!.id)
          .toList();
    });
  }

  void goToNotePage(Note note, bool isNewNote, int folderId) {
    final folderData = Provider.of<FolderData>(context, listen: false);
    final folder = widget.folder;

    folderData.updateFolder(folder!, folder.title, DateTime.now(),
        setStringFromColor(_color), false, folder.notes);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditingNote(
          note: note,
          isNewNote: isNewNote,
          folderId: folderId,
        ),
      ),
    ).then((value) {
      setState(() {
        notes = Provider.of<NoteData>(context, listen: false)
            .getAllNotes()
            .where((note) => note.folderId == widget.folder!.id)
            .toList();
        Provider.of<FolderData>(context, listen: false).updateFolder(
            folder,
            folder.title,
            DateTime.now(),
            setStringFromColor(_color),
            false,
            notes.map((e) => e.id).toList());
      });
    });
  }

  void _handleSave() {
    final folderData = Provider.of<FolderData>(context, listen: false);
    final folder = widget.folder;
    if (folder != null) {
      folderData.updateFolder(folder, _textEditingController.text,
          DateTime.now(), setStringFromColor(_color), false, folder.notes);
    } else {
      folderData.addNewFolder(
        Folder(
          id: DateTime.now().millisecondsSinceEpoch,
          title: _textEditingController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          color: setStringFromColor(_color),
          isPinned: false,
          notes: [],
          pin: '',
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Tag> allTags =
        Provider.of<TagData>(context, listen: false).getAllTags();

    // for (int i = 0; i < allNotes.length; i++) {
    //   if (allNotes[i].folderId == widget.folder!.id) {
    //     notes.add(allNotes[i]);
    //   }
    // }

    print('notes: ${notes.length}');

    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: IconButton(
          onPressed: () {
            _handleSave();
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
        ),
        backgroundColor: getColorFromString(widget.folder!.color),
        middle: TextField(
          controller: _textEditingController,
          decoration: const InputDecoration(
            hintText: 'Enter folder name',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: 8,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Folder Color',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                ColorPicker(
                  initialColor: _color,
                  onColorChanged: _handleColorChanged,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                List<Tag> noteTags = [];

                for (int i = 0; i < notes[index].tags.length; i++) {
                  for (int j = 0; j < allTags.length; j++) {
                    if (notes[index].tags[i] == allTags[j].id) {
                      noteTags.add(allTags[j]);
                    }
                  }
                }

                Note note = notes[index];

                return NoteCard(
                  title: note.title,
                  text: jsonDecode(note.text)[0]['insert'] != '\n'
                      ? jsonDecode(note.text)[0]['insert']
                      : '',
                  date: note.updatedAt,
                  backgroundColor: note.backgroundColor,
                  isPinned: note.isPinned,
                  folder: widget.folder,
                  tags: noteTags,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditingNote(note: note, isNewNote: false)));
                  },
                  pin: note.pin,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          int id = widget.folder!.id;
          Note newNote = Note(
            id: id,
            text: '',
            title: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            backgroundColor: "white",
            isPinned: false,
            tags: [],
            folderId: widget.folder!.id,
            pin: '',
          );

          goToNotePage(newNote, true, widget.folder!.id);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    Key? key,
    required this.initialColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  void _handleColorChanged(Color color) {
    setState(() {
      _color = color;
    });
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          for (final color in AppColors.tagColors)
            Expanded(
              child: InkWell(
                onTap: () => _handleColorChanged(color),
                child: Container(
                  height: 32,
                  color: color,
                  child: _color == color
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
