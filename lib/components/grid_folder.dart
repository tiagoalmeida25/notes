import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/components/note_tag.dart';
import 'package:notes/models/note.dart';

class FolderGrid extends StatelessWidget {
  final String title;
  final String color;
  final bool isPinned;
  final List<Note> notes;
  final Function() onTap;
  final Function()? onLongPress;

  const FolderGrid({
    super.key,
    required this.title,
    required this.color,
    required this.isPinned,
    required this.notes,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    String truncatedTitle = '';

    if (title.isEmpty) {
      truncatedTitle = 'New note...';
    } else {
      if (title.length > 12) {
        truncatedTitle = '${title.substring(0, 12)}...';
      } else {
        truncatedTitle = title;
      }
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 165,
          child: Card(
            elevation: 4,
            color: getColorFromString(color).withOpacity(0.3),
            // color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                truncatedTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Icon(
                              CupertinoIcons.folder_fill,
                              color: getColorFromString(color),
                              size: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (notes.isNotEmpty)
                  Positioned(
                    bottom: 34,
                    left: 4,
                    right: 8,
                    child: SizedBox(
                      height: 25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: NoteTag(
                                label: note.title,
                                backgroundColor:
                                    getColorFromString(note.backgroundColor),
                              ));
                        },
                      ),
                    ),
                  ),
                if (isPinned)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Transform.rotate(
                      angle: 0.5,
                      child: const Icon(Icons.push_pin, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
