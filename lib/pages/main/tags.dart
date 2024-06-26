import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notes/app_colors.dart';
import 'package:notes/components/sort_tags.dart';
import 'package:notes/models/note_data.dart';
import 'package:notes/models/tag.dart';
import 'package:notes/models/tag_data.dart';
import 'package:notes/pages/editing_tag.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tags extends StatefulWidget {
  const Tags({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TagsState createState() => _TagsState();
}

class _TagsState extends State<Tags> with WidgetsBindingObserver {
  List<Tag> allTags = [];

  ValueNotifier<String> sortNotifier = ValueNotifier('Title');

  bool isSorted = false;
  // bool isSearching = false;

  // final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<TagData>(context, listen: false).initializeTags();
    Provider.of<NoteData>(context, listen: false).initializeNotes();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      List<Tag> allTags =
          Provider.of<TagData>(context, listen: false).getAllTags();

      Provider.of<TagData>(context, listen: false).saveTags(allTags);
    }
  }

  void saveToPrefs(String sortBy, bool isSorted, bool isListView) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('sortBy', sortBy);
    await prefs.setBool('isSorted', isSorted);
  }

  void getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    String? sortBy = prefs.getString('sortBy');
    bool? isSorted = prefs.getBool('isSorted');

    if (sortBy != null) {
      sortNotifier.value = sortBy;
    }

    if (isSorted != null) {
      this.isSorted = isSorted;
    }
  }

  void goToTagPage(Tag tag, bool isNewTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditingTag(
          tag: tag,
        ),
      ),
    );
  }

  void createNewTag() {
    int id = Provider.of<TagData>(context, listen: false).getAllTags().length;
    Tag newTag = Tag(
      id: id,
      text: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundColor: "white",
      order: id,
    );

    goToTagPage(newTag, true);
  }

  void deleteTag(Tag tag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
          child: AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this tag?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<TagData>(context, listen: false).deleteTag(tag);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }

  void sort(String sortBy, bool isSorted) {
    Provider.of<TagData>(context, listen: false).sortTags(sortBy, isSorted);
  }

  @override
  Widget build(BuildContext context) {
    allTags = Provider.of<TagData>(context).getAllTags();

    return Consumer<TagData>(
        builder: (BuildContext context, TagData value, Widget? child) {
      return Scaffold(
        backgroundColor: CupertinoColors.systemBackground,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 75,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: SlidableAutoCloseBehavior(
                  child: allTags.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Center(
                            child: Text('No Tags Yet...'),
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // isSearching
                                //     ? Row(
                                //         children: [
                                //           SizedBox(
                                //             width: MediaQuery.of(context)
                                //                     .size
                                //                     .width *
                                //                 0.3,
                                //             child: TextField(
                                //               controller: _searchController,
                                //               // placeholder: 'Search',
                                //               decoration: const InputDecoration(
                                //                 hintText: 'Search',
                                //                 hintStyle: TextStyle(
                                //                   color: CupertinoColors
                                //                       .systemGrey,
                                //                 ),
                                //                 border: InputBorder.none,
                                //               ),
                                //               onChanged: (query) {
                                //                 value.searchTags(query);
                                //               },
                                //             ),
                                //           ),
                                //           SizedBox(
                                //             width: 20,
                                //             child: IconButton(
                                //               onPressed: () {
                                //                 setState(() {
                                //                   isSearching = !isSearching;
                                //                 });
                                //               },
                                //               icon: const Icon(
                                //                 CupertinoIcons.xmark,
                                //                 color:
                                //                     CupertinoColors.systemGrey,
                                //               ),
                                //             ),
                                //           ),
                                //         ],
                                //       )
                                //     : SizedBox(
                                //         width: 20,
                                //         child: IconButton(
                                //           onPressed: () {
                                //             setState(() {
                                //               isSearching = !isSearching;
                                //             });
                                //           },
                                //           icon: const Icon(
                                //             CupertinoIcons.search,
                                //             color: CupertinoColors.systemGrey,
                                //           ),
                                //         ),
                                //       ),
                                Row(
                                  children: [
                                    SortTag(
                                      sortNotifier: sortNotifier,
                                      isSorted: isSorted,
                                      sort: sort,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isSorted = !isSorted;
                                        });
                                        sort(sortNotifier.value, isSorted);
                                      },
                                      icon: isSorted
                                          ? const Icon(
                                              CupertinoIcons.arrow_up,
                                              color: CupertinoColors.systemGrey,
                                              size: 18,
                                            )
                                          : const Icon(
                                              CupertinoIcons.arrow_down,
                                              color: CupertinoColors.systemGrey,
                                              size: 18,
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Flexible(
                              child: ReorderableListView.builder(
                                shrinkWrap: true,
                                itemCount: allTags.length,
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) {
                                      newIndex -= 1;
                                    }
                                    final Tag tag = allTags.removeAt(oldIndex);
                                    allTags.insert(newIndex, tag);
                                    value.saveOrder(allTags);
                                    value.saveTags(allTags);
                                  });
                                },
                                itemBuilder: (context, index) {
                                  String tagText = '';

                                  if (allTags[index].text.length > 29) {
                                    tagText =
                                        '${allTags[index].text.substring(0, 29)}...';
                                  } else {
                                    tagText = allTags[index].text;
                                  }

                                  return Slidable(
                                    key: ValueKey(allTags[index].id),
                                    groupTag: 'delete',
                                    startActionPane: ActionPane(
                                      extentRatio: 0.15,
                                      motion: const StretchMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            deleteTag(allTags[index]);
                                          },
                                          backgroundColor: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          icon: CupertinoIcons.trash_fill,
                                          foregroundColor: Colors.black,
                                        ),
                                      ],
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        goToTagPage(allTags[index], false);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8),
                                        child: SizedBox(
                                          height: 40,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Container(
                                              color: getColorFromString(
                                                      allTags[index]
                                                          .backgroundColor)
                                                  .withOpacity(0.3),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                            CupertinoIcons
                                                                .tag_fill,
                                                            color: getColorFromString(
                                                                allTags[index]
                                                                    .backgroundColor)),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          tagText,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      goToTagPage(
                                                          allTags[index],
                                                          false);
                                                    },
                                                    icon: const Icon(
                                                      CupertinoIcons
                                                          .chevron_forward,
                                                      color: CupertinoColors
                                                          .systemGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
