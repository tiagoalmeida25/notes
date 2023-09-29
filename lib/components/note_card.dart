import 'package:flutter/material.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/components/note_tag.dart';
import 'package:notes/models/folder.dart';
import 'package:notes/models/tag.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String text;
  final DateTime date;
  final String backgroundColor;
  final bool isPinned;
  final List<Tag> tags;
  final Function() onTap;
  final Folder? folder;
  final String pin;

  const NoteCard({
    super.key,
    required this.title,
    required this.text,
    required this.backgroundColor,
    required this.date,
    required this.isPinned,
    required this.tags,
    required this.onTap,
    required this.folder,
    required this.pin,
  });

  @override
  Widget build(BuildContext context) {
    String dateHour = date.hour < 10 ? '0${date.hour}' : date.hour.toString();
    String dateMinute =
        date.minute < 10 ? '0${date.minute}' : date.minute.toString();

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
    String formattedDate =
        '${date.day} $month ${date.year%100} $dateHour:$dateMinute';
    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      formattedDate = '$dateHour:$dateMinute';
    }

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
          height: text.isNotEmpty ? 135 : 100,
          child: Card(
            elevation: 4,
            color: Colors.white,
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
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                          if (text.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            pin == ''
                                ? Text(
                                    text,
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : const Text(''),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                if (pin == '')
                  if (tags.isNotEmpty)
                    Positioned(
                      bottom: 30,
                      left: 4,
                      right: 8,
                      child: SizedBox(
                        height: 25,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tags.length,
                          itemBuilder: (context, index) {
                            final tag = tags[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: NoteTag(
                                label: tag.text,
                                backgroundColor:
                                    getColorFromString(tag.backgroundColor),
                              ),
                            );
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
                if (pin != '')
                  Positioned(
                    top: 32,
                    left: MediaQuery.of(context).size.width * 0.35,
                    child: const Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 80,
                    ),
                  ),
                if (pin == '')
                  if (folder != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder,
                            size: 16,
                            color: getColorFromString(folder!.color),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            folder!.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: getColorFromString(folder!.color),
                            ),
                          ),
                        ],
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
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
