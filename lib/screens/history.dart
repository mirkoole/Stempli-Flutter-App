import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stempli_flutter/main.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.title, super.key});

  final String title;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> _historyList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  _loadHistory() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _historyList = sharedPreferences.getStringList("history")!;
    _deleteHistoryExceptLast30Days();
    setState(() {});
  }

  _getHistoryItemWidget(String date, String worktime) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(date),
        Text(worktime),
      ],
    );
  }

  _getItems() {
    List<Widget> widgetList = List.empty(growable: true);

    for (var item in _historyList) {
      var split = item.split(" ");
      widgetList.add(_getHistoryItemWidget(split[0], split[1]));
    }

    if (widgetList.isEmpty) {
      widgetList.add(const Center(child: Text("\nNo Work = No History!")));
    }

    setState(() {});

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // actions: [
        //   IconButton(
        //       onPressed: () => _deleteHistory(), icon: const Icon(Icons.delete))
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: _getItems(),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text("History only stores 30 days."),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  void _deleteHistoryExceptLast30Days() {
    if (_historyList.length > 30) {
      _historyList.removeAt(0);
      sharedPreferences.setStringList("history", _historyList);
    }
  }
}
