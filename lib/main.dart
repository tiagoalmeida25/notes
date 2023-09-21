import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/pages/home_page.dart';
import 'package:notes/pages/pinned.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();

  await Hive.openBox('note_database');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
  ));


  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoteData(),
      builder: (context, child) => MaterialApp(
        title: 'Notes',
        theme: ThemeData(
          cupertinoOverrideTheme: const CupertinoThemeData(
            primaryColor: CupertinoColors.systemGrey2,
          ),
        ),
        home: const HomePage(),
        routes: {
          '/home': (context) => const HomePage(),
          '/pinned': (context) => const Pinned(),
        },
      ),
    );
  }
}
