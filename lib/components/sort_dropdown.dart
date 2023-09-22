import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SortDropdown extends StatefulWidget {
  final ValueNotifier<String> sortNotifier;
  final void Function(String, bool) sort;
  final isSorted;
  
  const SortDropdown({Key? key, required this.sortNotifier, required this.isSorted, required this.sort}) : super(key: key);

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  String _selectedSort = '';
  bool isSorted = false;
  void Function(String, bool) get sort => widget.sort;
  
  @override
  void initState() {
    super.initState();
    isSorted = widget.isSorted;
    _selectedSort = widget.sortNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        alignment: Alignment.centerLeft,
        style: const TextStyle(
          color: CupertinoColors.systemGrey,
          fontSize: 16,
        ),
        iconSize: 0.0,
        borderRadius: BorderRadius.circular(16),
        value: _selectedSort,
        items: <String>['Last Updated', 'Title', 'Created']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                if (value == 'Last Updated')
                  const Icon(
                    Icons.update,
                    color: CupertinoColors.systemGrey,
                    size: 18,
                  ),
                if (value == 'Title')
                  const Icon(
                    Icons.title,
                    color: CupertinoColors.systemGrey,
                    size: 18,
                  ),
                if (value == 'Created')
                  const Icon(
                    Icons.create,
                    color: CupertinoColors.systemGrey,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Text(value,
                    style: const TextStyle(
                      fontSize: 15,
                    )),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedSort = newValue!;
            widget.sortNotifier.value = _selectedSort;
            sort(_selectedSort, isSorted);
          });
        },
      ),
    );
  }
}
