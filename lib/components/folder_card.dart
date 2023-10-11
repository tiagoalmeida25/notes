import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/models/note.dart';

class FolderCard extends StatelessWidget {
  final String title;
  final String color;
  final bool isPinned;
  final List<Note> notes;
  final Function() onTap;
  final String folder;
  final DateTime date;
  final String pin;

  const FolderCard({
    super.key,
    required this.title,
    required this.color,
    required this.isPinned,
    required this.notes,
    required this.onTap,
    required this.folder,
    required this.date,
    required this.pin,
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

    String month = '';
    switch (date.month) {
      case 1:
        month = 'Jan';
        break;
      case 2:
        month = 'Feb';
        break;
      case 3:
        month = 'Mar';
        break;
      case 4:
        month = 'Apr';
        break;
      case 5:
        month = 'May';
        break;
      case 6:
        month = 'Jun';
        break;
      case 7:
        month = 'Jul';
        break;
      case 8:
        month = 'Aug';
        break;
      case 9:
        month = 'Sep';
        break;
      case 10:
        month = 'Oct';
        break;
      case 11:
        month = 'Nov';
        break;
      case 12:
        month = 'Dec';
        break;
    }
    String formattedDate = '${date.day} $month ${date.year}';

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
                      pin == ''
                          ? Icon(
                              CupertinoIcons.folder_fill,
                              color: getColorFromString(color),
                              size: 60,
                            )
                          : Icon(
                              CupertinoIcons.lock_fill,
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
                if (pin == '')
                  if (notes.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      left: 108,
                      right: 8,
                      child: SizedBox(
                        height: 25,
                        child: Text(
                          '${notes.length} notes assigned',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
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
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
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
