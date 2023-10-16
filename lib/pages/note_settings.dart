import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/components/page_color_picker.dart';

class NoteSettings extends StatefulWidget {
  final Color currentColor;

  const NoteSettings({Key? key, required this.currentColor}) : super(key: key);

  @override
  NoteSettingsState createState() => NoteSettingsState();
}

class NoteSettingsState extends State<NoteSettings> {
  Color _color = Colors.white;

  @override
  void initState() {
    super.initState();
    _color = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        CupertinoIcons.back,
                      ),
                    ),
                    const Text(
                      'Note settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Background color',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Choose a color for the background of your note.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: SizedBox(
                    height: 350,
                    child: PageColorPicker(
                      colorToSet: _color,
                      availableColors: const [
                        Color.fromRGBO(0, 0, 0, 1),
                        Color.fromRGBO(101, 110, 117, 1),
                        Color.fromRGBO(84, 110, 122, 1),
                        Color.fromRGBO(176, 178, 199, 1),
                        Color.fromRGBO(255, 255, 255, 1),
                        Color.fromARGB(255, 176, 82, 76),
                        Color.fromRGBO(56, 142, 60, 1),
                        Color.fromRGBO(236, 176, 47, 1),
                        Color.fromRGBO(25, 82, 148, 1),
                        Color.fromRGBO(209, 196, 233, 1),
                        Color.fromRGBO(255, 224, 178, 1),
                        Color.fromRGBO(220, 237, 200, 1),
                        Color.fromRGBO(255, 249, 196, 1),
                        Color.fromRGBO(187, 222, 251, 1),
                        Color.fromRGBO(252, 228, 236, 1),
                      ],
                      onColorSelected: (color) {
                        setState(() => _color = color);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // save button
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all<Size>(
                  const Size(100, 50),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, [_color]);
              },
              child: const Text('Save',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
