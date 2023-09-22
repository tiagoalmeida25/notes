import 'package:flutter/material.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/models/folder_data.dart';
import 'package:notes/models/folder.dart';
import 'package:provider/provider.dart';

class CreateFolder extends StatefulWidget {
  final FolderData folderData;
  const CreateFolder({Key? key, required this.folderData}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateFolderState createState() => _CreateFolderState();
}

class _CreateFolderState extends State<CreateFolder> {
  late TextEditingController _textEditingController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _color = AppColors.tagColors.first;
  }

  void _handleColorChanged(Color color) {
    setState(() {
      _color = color;
    });
  }

  void _handleSave() {
    final text = _textEditingController.text.trim();
    final allFolders = widget.folderData.getAllFolders();

    for (int i = 0; i < allFolders.length; i++) {
      if (allFolders[i].title.toLowerCase() == text.toLowerCase()) {
        return;
      }
    }

    if (text.isNotEmpty) {
      widget.folderData.addNewFolder(
        Folder(
          title: text,
          color: setStringFromColor(_color),
          id: DateTime.now().millisecondsSinceEpoch,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPinned: false,
          notes: [],
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: Theme.of(context).textTheme.bodySmall),
            TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                hintText: 'Enter folder name',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.bodySmall),
            ColorPicker(
                initialColor: _color, onColorChanged: _handleColorChanged),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
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
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
