import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/components/note_tag.dart';
import 'package:notes/models/note.dart';

class FolderCard extends StatelessWidget {
  final String title;
  final String color;
  final bool isPinned;
  final List<Note> notes;
  final Function() onTap;
  final String folder;

  const FolderCard({
    super.key,
    required this.title,
    required this.color,
    required this.isPinned,
    required this.notes,
    required this.onTap,
    required this.folder,
  });

  @override
  Widget build(BuildContext context) {
    String truncatedTitle = '';

    if (title.isEmpty) {
      truncatedTitle = 'New note...';
    } else {
      if (title.length > 35) {
        truncatedTitle = '${title.substring(0, 35)}...';
      } else {
        truncatedTitle = title;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 75,
          child: Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.folder_fill,
                        color: getColorFromString(color),
                        size: 60,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 32, top: 8, right: 8, bottom: 8),
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
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
                if (notes.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    left: 108,
                    right: 8,
                    child: SizedBox(
                      height: 25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: NoteTag(
                              label: note.title,
                              backgroundColor:
                                  getColorFromString(note.backgroundColor),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (notes.isEmpty)
                  const Positioned(
                    bottom: 10,
                    left: 108,
                    right: 8,
                    child: SizedBox(
                      height: 25,
                      child: Text(
                        'No notes assigned',
                        style: TextStyle(color: Colors.grey),
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
