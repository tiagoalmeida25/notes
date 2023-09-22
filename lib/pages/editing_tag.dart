import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/components/note_card.dart';
import 'package:notes/models/tag.dart';
import 'package:notes/models/tag_data.dart';
import 'package:notes/pages/editing_note.dart';
import 'package:provider/provider.dart';

class EditingTag extends StatefulWidget {
  final Tag? tag;

  const EditingTag({Key? key, this.tag}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditingTagState createState() => _EditingTagState();
}

class _EditingTagState extends State<EditingTag> {
  late TextEditingController _textEditingController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: widget.tag?.text ?? '');
    _color = widget.tag != null
        ? getColorFromString(widget.tag!.backgroundColor)
        : AppColors.tagColors.first;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _handleColorChanged(Color color) {
    setState(() {
      _color = color;
    });
  }

  void _handleSave() {
    final tagData = Provider.of<TagData>(context, listen: false);
    final tag = widget.tag;
    if (tag != null) {
      tagData.updateTag(tag, _textEditingController.text, DateTime.now(),
          setStringFromColor(_color), false);
    } else {
      tagData.addNewTag(
        Tag(
          id: DateTime.now().millisecondsSinceEpoch,
          text: _textEditingController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          backgroundColor: setStringFromColor(_color),
          order: tagData.getAllTags().length,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tagData = Provider.of<TagData>(context);
    final notes = tagData.getNotesWithTag(widget.tag!);
    List<Tag> allTags = tagData.getAllTags();

    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
        ),
        backgroundColor: getColorFromString(widget.tag!.backgroundColor),
        middle: TextField(
          controller: _textEditingController,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
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
                Text('Tag Color', style: Theme.of(context).textTheme.bodySmall),
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
                final note = notes[index];
                List<Tag> noteTags = [];

                for (int i = 0; i < note.tags.length; i++) {
                  for (int j = 0; j < allTags.length; j++) {
                    if (note.tags[i] == allTags[j].id) {
                      noteTags.add(allTags[j]);
                    }
                  }
                }

                return NoteCard(
                  title: note.title,
                  text: jsonDecode(note.text)[0]['insert'] != '\n'
                      ? jsonDecode(note.text)[0]['insert']
                      : '',
                  date: note.updatedAt,
                  backgroundColor: note.backgroundColor,
                  isPinned: note.isPinned,
                  tags: noteTags,
                  folder: 'Folder',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditingNote(note: note, isNewNote: false)));
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _handleSave,
        child: const Icon(
          Icons.save,
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
