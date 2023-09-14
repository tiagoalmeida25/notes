import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:provider/provider.dart';

class EditingNote extends StatefulWidget {
  Note note;
  bool isNewNote;

  EditingNote({super.key, required this.note, required this.isNewNote});

  @override
  State<EditingNote> createState() => _EditingNoteState();
}

class _EditingNoteState extends State<EditingNote> {
  QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadExistingNote();
  }

  void loadExistingNote() {
    final doc = Document()..insert(0, widget.note.text);
    setState(() {
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _titleController.text = widget.note.title;
    });
  }

  void addNewNote(int i) {
    String text = _controller.document.toPlainText();

    Provider.of<NoteData>(context, listen: false).addNewNote(
      Note(
        id: i,
        text: text,
        title: _titleController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  void updateNote() {
    String text = _controller.document.toPlainText();
    String title = _titleController.text;

    Provider.of<NoteData>(context, listen: false)
        .updateNote(widget.note, text, title, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: widget.isNewNote
                ? 'Title'
                : widget.note.title == ''
                    ? 'Title'
                    : widget.note.title,
            border: InputBorder.none,
          ),
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(
            color: CupertinoColors.darkBackgroundGray,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (value) {
            widget.note.title = value;
          },
        ),
        leading: GestureDetector(
          onTap: () {
            if (_controller.document.isEmpty() &&
                _titleController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }

            if (widget.isNewNote) {
              addNewNote(
                Provider.of<NoteData>(context, listen: false)
                    .getAllNotes()
                    .length,
              );
            } else {
              updateNote();
            }

            Navigator.pop(context);
          },
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ),
      body: Column(
        children: [
          QuillToolbar.basic(
            controller: _controller,
            multiRowsDisplay: false,
            showDividers: true,
            showFontFamily: true,
            showFontSize: true,
            showBoldButton: true,
            showItalicButton: true,
            showSmallButton: false,
            showUnderLineButton: true,
            showStrikeThrough: true,
            showInlineCode: true,
            showColorButton: true,
            showBackgroundColorButton: true,
            showClearFormat: true,
            showAlignmentButtons: true,
            showLeftAlignment: true,
            showCenterAlignment: true,
            showRightAlignment: true,
            showJustifyAlignment: true,
            showHeaderStyle: true,
            showListNumbers: true,
            showListBullets: true,
            showListCheck: true,
            showCodeBlock: false,
            showQuote: true,
            showIndent: true,
            showLink: true,
            showUndo: true,
            showRedo: true,
            showDirection: false,
            showSearchButton: true,
            showSubscript: true,
            showSuperscript: true,
            toolbarIconSize: 20,
            fontSizeValues: const {
              'Small': '8',
              'Normal': '12',
              'Large': '20',
              'Huge': '30',
              'Clear': '0'
            },
          ),
          const Divider(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                controller: _controller,
                readOnly: false,
                autoFocus: false,
              ),
            ),
          )
        ],
      ),
    );
  }
}
