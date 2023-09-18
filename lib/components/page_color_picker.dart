import 'package:flutter/material.dart';

class PageColorPicker extends StatefulWidget {
  final List<Color> availableColors;
  final Color colorToSet;
  final Function(Color) onColorSelected;

  const PageColorPicker({
    Key? key,
    required this.colorToSet,
    required this.availableColors,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  PageColorPickerState createState() => PageColorPickerState();
}

class PageColorPickerState extends State<PageColorPicker> {
  final int crossAxisCount = 5;
  final double blockSize = 100.0;
  final double spacingFactor = 2;

  // double get crossAxisSpacing =>
  //     (MediaQuery.of(context).size.width - (crossAxisCount * blockSize)) /
  //     ((crossAxisCount - 1) + (crossAxisCount * spacingFactor));

  // double get mainAxisSpacing => blockSize * spacingFactor;

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 0,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final pickedColor = widget.availableColors[index];
        final isSelected = pickedColor == widget.colorToSet;

        return GestureDetector(
          onTap: () => handleColorTapped(pickedColor),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: blockSize / 2.2,
                  height: blockSize,
                  decoration: BoxDecoration(
                    color: pickedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? pickedColor == Colors.black
                              ? Colors.white
                              : Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Center(
                  child: Icon(
                    Icons.check,
                    color: pickedColor == Colors.white
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
            ],
          ),
        );
      },
      itemCount: widget.availableColors.length,
    );
  }

  void handleColorTapped(Color pickedColor) {
    widget.onColorSelected(pickedColor);
  }
}
