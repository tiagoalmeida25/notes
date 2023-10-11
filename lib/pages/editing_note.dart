import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:notes/app_colors.dart';
import 'package:notes/components/note_tag.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/models/tag.dart';
import 'package:notes/models/tag_data.dart';
import 'package:notes/pages/note_settings.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditingNote extends StatefulWidget {
  Note note;
  bool isNewNote;
  int? folderId;

  EditingNote({super.key, required this.note, required this.isNewNote, this.folderId});

  @override
  State<EditingNote> createState() => _EditingNoteState();
}

class _EditingNoteState extends State<EditingNote> {
  Color backgroundColor = Colors.white;
  QuillController _controller = QuillController.basic();

  final TextEditingController _titleController = TextEditingController();

  late List<Tag> _selectedTags;

  @override
  void initState() {
    super.initState();
    loadExistingNote();
    _selectedTags = widget.note.tags
        .map((id) => Provider.of<TagData>(context, listen: false).getTag(id))
        .toList();
  }

  void loadExistingNote() {
    if (widget.note.text.isNotEmpty) {
      setState(() {
        _controller = QuillController(
          document: Document.fromJson(jsonDecode(widget.note.text)),
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
        isPinned: false,
        tags: _selectedTags.map((e) => e.id).toList(),
        folderId: widget.folderId ?? 0,
        pin: '',
      ),
    );
  }

  void updateNote() {
    String text = jsonEncode(_controller.document.toDelta().toJson());
    String title = _titleController.text;

    Provider.of<NoteData>(context, listen: false).updateNote(
        widget.note,
        text,
        title,
        DateTime.now(),
        setStringFromColor(backgroundColor),
        widget.note.isPinned,
        _selectedTags.map((e) => e.id).toList());
  }

  void noteSettings() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => NoteSettings(currentColor: backgroundColor)));

    if (result != null) {
      setState(() {
        backgroundColor = result[0];
      });
    }
  }

  void _handleTagSelected(Tag tag, List<Tag> allTags) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var allTags = Provider.of<TagData>(context).allTags;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: darkColors.contains(backgroundColor)
          ? Brightness.light
          : Brightness.dark,
    ));

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
                  : backgroundColor == const Color.fromRGBO(101, 110, 117, 1)
                      ? Colors.grey[800]
                      : backgroundColor == const Color.fromRGBO(84, 110, 122, 1)
                          ? Colors.blueGrey[800]
                          : backgroundColor ==
                                  const Color.fromRGBO(176, 178, 199, 1)
                              ? const Color.fromARGB(255, 123, 126, 152)
                              : backgroundColor ==
                                      const Color.fromRGBO(176, 82, 76, 1)
                                  ? const Color.fromARGB(255, 135, 42, 42)
                                  : backgroundColor ==
                                          const Color.fromRGBO(56, 142, 60, 1)
                                      ? const Color.fromARGB(255, 52, 106, 55)
                                      : backgroundColor ==
                                              const Color.fromRGBO(
                                                  236, 176, 47, 1)
                                          ? const Color.fromARGB(
                                              255, 180, 121, 26)
                                          : backgroundColor ==
                                                  const Color.fromRGBO(
                                                      25, 82, 148, 1)
                                              ? const Color.fromARGB(
                                                  255, 24, 59, 99)
                                              : backgroundColor ==
                                                      const Color.fromRGBO(
                                                          209, 196, 233, 1)
                                                  ? const Color.fromRGBO(
                                                      183, 171, 204, 1)
                                                  : backgroundColor ==
                                                          const Color.fromRGBO(
                                                              255, 224, 178, 1)
                                                      ? Colors.orange[200]
                                                      : backgroundColor ==
                                                              const Color.fromRGBO(
                                                                  220, 237, 200, 1)
                                                          ? Colors.green[200]
                                                          : backgroundColor ==
                                                                  const Color.fromRGBO(
                                                                      255, 249, 196, 1)
                                                              ? Colors
                                                                  .yellow[200]
                                                              : backgroundColor ==
                                                                      const Color.fromRGBO(
                                                                          187,
                                                                          222,
                                                                          251,
                                                                          1)
                                                                  ? Colors
                                                                      .blue[200]
                                                                  : backgroundColor ==
                                                                          const Color.fromRGBO(
                                                                              252,
                                                                              228,
                                                                              236,
                                                                              1)
                                                                      ? Colors.pink[200]
                                                                      : Colors.white,
          middle: TextField(
            autofocus: false,
            controller: _titleController,
            decoration: InputDecoration(
              hintText: widget.isNewNote
                  ? 'Title'
                  : widget.note.title == ''
                      ? 'Title'
                      : widget.note.title,
              hintStyle: TextStyle(
                color: darkColors.contains(backgroundColor) &&
                        (widget.isNewNote || widget.note.title == '')
                    ? Colors.grey[300]
                    : lightColors.contains(backgroundColor) &&
                            (widget.isNewNote || widget.note.title == '')
                        ? Colors.grey[700]
                        : darkColors.contains(backgroundColor)
                            ? Colors.white
                            : lightColors.contains(backgroundColor)
                                ? Colors.black
                                : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
            ),
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              color: darkColors.contains(backgroundColor) &&
                      (widget.isNewNote || widget.note.title == '')
                  ? Colors.grey[300]
                  : lightColors.contains(backgroundColor) &&
                          (widget.isNewNote || widget.note.title == '')
                      ? Colors.grey[700]
                      : darkColors.contains(backgroundColor)
                          ? Colors.white
                          : lightColors.contains(backgroundColor)
                              ? Colors.black
                              : Colors.black,
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
            icon: Icon(
              CupertinoIcons.back,
              color: darkColors.contains(backgroundColor)
                  ? Colors.grey[300]
                  : lightColors.contains(backgroundColor)
                      ? Colors.grey[700]
                      : Colors.grey[700],
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
            icon: Icon(
              CupertinoIcons.ellipsis_vertical,
              size: 20,
              color: darkColors.contains(backgroundColor)
                  ? Colors.grey[300]
                  : lightColors.contains(backgroundColor)
                      ? Colors.grey[700]
                      : Colors.grey[700],
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: Container(
                  color: backgroundColor,
                  width: MediaQuery.of(context).size.width,
                  height: 58,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, bottom: 8, top: 2),
                    child: allTags.isEmpty
                        ? Center(
                            child: Text(
                              'No Tags created yet...',
                              style: TextStyle(
                                color: darkColors.contains(backgroundColor)
                                    ? Colors.grey[300]
                                    : lightColors.contains(backgroundColor)
                                        ? Colors.grey[700]
                                        : Colors.grey[700],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tags',
                                style: TextStyle(
                                  color: darkColors.contains(backgroundColor)
                                      ? Colors.grey[300]
                                      : lightColors.contains(backgroundColor)
                                          ? Colors.grey[700]
                                          : Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: allTags.length,
                                    itemBuilder: (context, index) {
                                      Tag tag = allTags[index];

                                      return GestureDetector(
                                        onTap: () =>
                                            _handleTagSelected(tag, allTags),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: SizedBox(
                                            height: 28,
                                            width: tag.text.length * 12.0,
                                            child: _selectedTags.contains(tag)
                                                ? NoteTag(
                                                    label: tag.text,
                                                    backgroundColor:
                                                        getColorFromString(tag
                                                            .backgroundColor),
                                                  )
                                                : NoteTag(
                                                    label: tag.text,
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 208, 208, 208),
                                                  ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: QuillEditor.basic(
                    controller: _controller,
                    readOnly: false,
                    autoFocus: false,
                    placeholder: 'Start writing...',
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ]),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: SafeArea(
                  child: QuillToolbar.basic(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
