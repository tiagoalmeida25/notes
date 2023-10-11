import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes/models/folder_data.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/models/tag_data.dart';
import 'package:notes/pages/create_folder.dart';
import 'package:notes/pages/create_tag.dart';
import 'package:notes/pages/editing_note.dart';
import 'package:notes/pages/main/folders.dart';
import 'package:notes/pages/main/home_page.dart';
import 'package:notes/pages/main/pinned.dart';
import 'package:notes/pages/main/tags.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();

  await Hive.openBox('note_database');
  await Hive.openBox('folders_database');
  await Hive.openBox('tags_database');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoteData()),
        ChangeNotifierProvider(create: (context) => FolderData()),
        ChangeNotifierProvider(create: (context) => TagData()),
      ],
      builder: (context, child) => MaterialApp(
        title: 'Notes',
        home: const MainPage(),
        routes: {
          '/home': (context) => const HomePage(),
          '/pinned': (context) => const Pinned(),
          '/folders': (context) => const Folders(),
          '/tags': (context) => const Tags(),
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomePage(),
          Pinned(),
          Folders(),
          Tags(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 16,
        unselectedFontSize: 12,
        selectedItemColor: Colors.black,
        backgroundColor: CupertinoColors.white,
        elevation: 8,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 2.5),
              child: _currentIndex == 0
                  ? const Icon(
                      Icons.home,
                      color: Colors.black,
                    )
                  : const Icon(
                      Icons.home_outlined,
                      color: Colors.black,
                    ),
            ),
            label: 'Notes',
            tooltip: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 2.5),
              child: _currentIndex == 1
                  ? Transform.rotate(
                      angle: 20 * math.pi / 180,
                      child: const Icon(
                        Icons.push_pin,
                        color: Colors.black,
                      ),
                    )
                  : Transform.rotate(
                      angle: 20 * math.pi / 180,
                      child: const Icon(
                        Icons.push_pin_outlined,
                        color: Colors.black,
                      ),
                    ),
            ),
            label: 'Pinned',
            tooltip: 'Pinned',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 2.5),
              child: _currentIndex == 2
                  ? const Icon(
                      CupertinoIcons.folder_fill,
                      color: Colors.black,
                    )
                  : const Icon(
                      CupertinoIcons.folder,
                      color: Colors.black,
                    ),
            ),
            label: 'Folders',
            tooltip: 'Folders',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 3
                ? const Icon(
                    CupertinoIcons.tag_fill,
                    color: Colors.black,
                  )
                : const Icon(
                    CupertinoIcons.tag,
                    color: Colors.black,
                  ),
            label: 'Tags',
            tooltip: 'Tags',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  void goToNotePage(Note note, bool isNewNote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditingNote(
          note: note,
          isNewNote: isNewNote,
        ),
      ),
    );
  }

  void createNewNote() {
    int id = Provider.of<NoteData>(context, listen: false).getAllNotes().length;
    Note newNote = Note(
      id: id,
      text: '',
      title: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundColor: "white",
      isPinned: false,
      tags: [],
      folderId: 0,
      pin: '',
    );

    goToNotePage(newNote, true);
  }

  void createNewPinnedNote() {
    int id = Provider.of<NoteData>(context, listen: false).getAllNotes().length;
    Note newNote = Note(
      id: id,
      text: '',
      title: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundColor: "white",
      isPinned: true,
      tags: [],
      folderId: 0,
      pin: '',
    );

    goToNotePage(newNote, true);
  }

  void createTagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.red,
              surface: Colors.white,
              background: Color.fromRGBO(238, 238, 238, 1),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black,
              onBackground: Colors.black,
            ),
          ),
          child: CreateTag(
            tagData: Provider.of<TagData>(context, listen: false),
          ),
        );
      },
    );
  }

  void createFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.red,
              surface: Colors.white,
              background: Color.fromRGBO(238, 238, 238, 1),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black,
              onBackground: Colors.black,
            ),
          ),
          child: CreateFolder(
            folderData: Provider.of<FolderData>(context, listen: false),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: createNewNote,
          backgroundColor: Colors.black,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        );
      case 1:
        return FloatingActionButton(
          onPressed: createNewPinnedNote,
          backgroundColor: Colors.black,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => createFolderDialog(context),
          backgroundColor: Colors.black,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        );
      case 3:
        return FloatingActionButton(
          onPressed: () => createTagDialog(context),
          backgroundColor: Colors.black,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
