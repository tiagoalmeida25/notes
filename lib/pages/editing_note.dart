import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes/components/colors.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/pages/note_settings.dart';
import 'package:provider/provider.dart';
import 'package:super_editor/super_editor.dart';
// import document from quill
import 'package:flutter_quill/src/models/documents/document.dart' as quill_doc;

// ignore: must_be_immutable
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

  Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    loadExistingNote();
  }

  void loadExistingNote() {
    if (widget.note.text.isNotEmpty) {
      setState(() {
        _controller = QuillController(
          document: quill_doc.Document.fromJson(jsonDecode(widget.note.text)),
          selection: const TextSelection.collapsed(offset: 0),
        );
        _titleController.text = widget.note.title;
        backgroundColor = getColorFromString(widget.note.backgroundColor);
      });
    }
  }

  void addNewNote(int i) {
    String text = jsonEncode(_controller.document.toDelta().toJson());

    Provider.of<NoteData>(context, listen: false).addNewNote(
      Note(
        id: i,
        text: text,
        title: _titleController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        backgroundColor: setStringFromColor(backgroundColor),
      ),
    );
  }

  void updateNote() {
    // String text = _controller.document.toPlainText();
    String text = jsonEncode(_controller.document.toDelta().toJson());
    String title = _titleController.text;

    Provider.of<NoteData>(context, listen: false).updateNote(widget.note, text,
        title, DateTime.now(), setStringFromColor(backgroundColor));
  }

  void noteSettings() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const NoteSettings()));

    if (result != null) {
      setState(() {
        backgroundColor = result[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final myDoc = MutableDocument(
      nodes: [
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText(text: 'This is a header'),
          metadata: {
            'blockType': header1Attribution,
          },
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText(text: 'This is the first paragraph'),
        ),
      ],
    );

    final docEditor = DocumentEditor(document: myDoc);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        if (_controller.document.isEmpty() && _titleController.text.isEmpty) {
          return true;
        }

        if (widget.isNewNote) {
          addNewNote(DateTime.now().millisecondsSinceEpoch);
        } else {
          updateNote();
        }

        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: CupertinoNavigationBar(
          backgroundColor: backgroundColor == Colors.white
            ? Colors.white
            : backgroundColor == Colors.black
                ? Colors.black
                : backgroundColor == Color.fromRGBO(117, 117, 117, 1)
                    ? Colors.grey[800]
                    : backgroundColor == Colors.pink[50]
                        ? Colors.pink[100]
                        : backgroundColor == Colors.blue[100]
                            ? Colors.blue[200]
                            : backgroundColor == Colors.orange[100]
                                ? Colors.orange[200]
                                : backgroundColor,
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
          leading: IconButton(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 0),
            icon: const Icon(
              CupertinoIcons.back,
              color: CupertinoColors.systemGrey,
            ),
            onPressed: () {
              if (_controller.document.isEmpty() &&
                  _titleController.text.isEmpty) {
                Navigator.pop(context);
                return;
              }

              if (widget.isNewNote) {
                addNewNote(DateTime.now().millisecondsSinceEpoch);
              } else {
                updateNote();
              }

              Navigator.pop(context);
            },
          ),
          trailing: IconButton(
            onPressed: () {
              noteSettings();
            },
            icon: const Icon(
              CupertinoIcons.ellipsis_vertical,
              size: 20,
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            QuillToolbar.basic(
              sectionDividerSpace: 0,
              controller: _controller,
              multiRowsDisplay: false,
              showDividers: true,
              showFontFamily: false,
              showFontSize: false,
              showBoldButton: true,
              showItalicButton: true,
              showSmallButton: false,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showInlineCode: true,
              showColorButton: true,
              showBackgroundColorButton: true,
              showClearFormat: false,
              showAlignmentButtons: false,
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
              showSubscript: false,
              showSuperscript: false,
              toolbarIconSize: 18,
              fontSizeValues: const {
                '5': '5',
                '6': '6',
                '7': '7',
                '8': '8',
                '9': '9',
                '10': '10',
                '11': '11',
                '12': '12',
                '13': '13',
                '14': '14',
                '15': '15',
                '16': '16',
                '18': '18',
                '20': '20',
                '22': '22',
                '24': '24',
                '28': '28',
                '32': '32',
                '36': '36',
                '40': '40',
                'Clear': '0'
              },
            ),
            const Divider(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 25, right: 25),
                height: height * 0.8,
                child: QuillEditor.basic(
                  controller: _controller,
                  readOnly: false,
                  autoFocus: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
