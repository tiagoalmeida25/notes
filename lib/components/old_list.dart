import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/components/colors.dart';

class ListNote extends StatelessWidget {
  const ListNote({
    Key? key,
    required this.title,
    required this.text,
    required this.backgroundColor,
    required this.isPinned,
    required this.onTap,
    required this.updatedAt,
  }) : super(key: key);

  final String title;
  final String text;
  final String backgroundColor;
  final bool isPinned;
  final Function() onTap;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    String hourText = updatedAt!.hour < 10
        ? '0${updatedAt!.hour}'
        : updatedAt!.hour.toString();

    String minuteText = updatedAt!.minute < 10
        ? '0${updatedAt!.minute}'
        : updatedAt!.minute.toString();

    DateTime today = DateTime.now();

    String updatedAtText = '';

    if (updatedAt!.day == today.day &&
        updatedAt!.month == today.month &&
        updatedAt!.year == today.year) {
      updatedAtText = '$hourText:$minuteText';
    } else {
      updatedAtText =
          '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year} $hourText:$minuteText';
    }

    Color? newColor = const Color.fromRGBO(0, 0, 0, 1);

    String title = this.title;
    if (title.length > 30) title = '${title.substring(0, 30)}...';
    if (title == '') title = 'New note';

    String text = this.text;
    if (text.length > 30) text = '${text.substring(0, 30)}...';

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: SizedBox(
          width: width,
          height: text.length > 0 ? 100 : 65,
          child: Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Container(
                    width: 10,
                    color: getColorFromString(backgroundColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: newColor,
                                ),
                              ),
                              const SizedBox(
                                  width: 8), // Adjust the spacing as needed
                              Icon(
                                Icons
                                    .chevron_right, // Replace with your desired chevron icon
                                color: newColor,
                                size: 20,
                              ),
                            ],
                          ),
                          if (isPinned)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Transform.rotate(
                                  angle: 0.5,
                                  child: Icon(
                                    Icons.push_pin,
                                    color: newColor,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      text != ''
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: newColor,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            updatedAtText,
                            style: TextStyle(
                              fontSize: 12,
                              color: newColor,
                            ),
                          ),
                        ],
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
