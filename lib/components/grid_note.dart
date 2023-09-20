import 'package:flutter/material.dart';
import 'package:notes/components/colors.dart';

class GridNote extends StatelessWidget {
  const GridNote({
    Key? key,
    required this.title,
    required this.text,
    required this.backgroundColor,
    required this.isPinned,
    required this.onTap,
    required this.updatedAt,
    this.onLongPress,
  }) : super(key: key);

  final String title;
  final String text;
  final String backgroundColor;
  final bool isPinned;
  final Function() onTap;
  final DateTime? updatedAt;
  final Function()? onLongPress;

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
      updatedAtText = '${hourText}:${minuteText}';
    } else {
      updatedAtText =
          '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year} $hourText:$minuteText';
    }

    Color? newColor = darkColors.contains(getColorFromString(backgroundColor))
        ? const Color.fromRGBO(255, 255, 255, 1)
        : const Color.fromRGBO(0, 0, 0, 1);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 4,
        color: getColorFromString(backgroundColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text and chevron icon in a Row
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
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
                                Icons.push_pin_sharp,
                                color: newColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      text != ''
                          ? Text(
                              text,
                              style: TextStyle(
                                fontSize: 16,
                                color: newColor,
                              ),
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            ),
                    ],
                  ),
                ],
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
      ),
    );
  }
}
