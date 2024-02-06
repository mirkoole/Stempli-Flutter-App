import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.title, super.key});

  final String title;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();

    _deleteHistoryOlderThan1Month();
  }

  _getHistoryItemWidget(String weekday, String date, String worktime) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(weekday),
        Text(date),
        Text(worktime),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _items = [];
    _items.add(_getHistoryItemWidget("Mo", "05.02.24", "working"));
    _items.add(const Divider());
    _items.add(_getHistoryItemWidget("Fr", "02.02.24", "07:30h"));
    _items.add(_getHistoryItemWidget("Th", "01.02.24", "07:30h"));
    _items.add(_getHistoryItemWidget("We", "31.01.24", "07:30h"));
    _items.add(_getHistoryItemWidget("Tu", "30.02.24", "07:30h"));
    _items.add(_getHistoryItemWidget("Mo", "29.02.24", "07:30h"));
    _items.add(const Divider());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () => _deleteHistory(), icon: const Icon(Icons.delete))
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: _items,
        ),
      ),
    );
  }
}

void _deleteHistoryOlderThan1Month() {
  print("_deleteHistoryOlderThan1Month");
}

void _deleteHistory() {
  print("deleteHistory() = deleteHistory()");
}
