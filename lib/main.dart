import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const StempliApp());
}

class StempliApp extends StatelessWidget {
  const StempliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stempli App',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.blue,
          onPrimary: Colors.white,
          secondary: Colors.blue,
          onSecondary: Colors.white,
          background: Colors.grey,
          onBackground: Colors.white70,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.blue,
          onSurface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.blue,
          onPrimary: Colors.white,
          secondary: Colors.blue,
          onSecondary: Colors.white70,
          background: Colors.black54,
          onBackground: Colors.white70,
          error: Colors.red,
          onError: Colors.black87,
          surface: Colors.blue,
          onSurface: Colors.white,
        ),
        dividerColor: Colors.black12,
      ),
      home: const StempliAppState(title: 'Stempli App 1.0'),
    );
  }
}

class StempliAppState extends StatefulWidget {
  const StempliAppState({super.key, required this.title});

  final String title;

  @override
  State<StempliAppState> createState() => _StempliAppState();
}

class _StempliAppState extends State<StempliAppState> {
  // settings
  int workday = 8 * 60 * 60;
  bool showSeconds = true;

  // internal vars
  Timer? _timer;

  bool _working = false;

  int _lastToggleTimestamp = 0;
  int _workTimeTotal = 0;
  int _breakTimeTotal = 0;

  double _progressBarValue = 0.0;

  String _workCountdownTotalString = "00:00:00";
  String _workTimeTotalString = "00:00:00";
  String _breakTimeTotalString = "00:00:00";

  @override
  void initState() {
    super.initState();
    _readState();
    _timer = Timer.periodic(const Duration(seconds: 1), _displayTimer);
  }

  _readState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _working = prefs.getBool('working') ?? false;
      _workTimeTotal = prefs.getInt('workTimeTotal') ?? 0;
      _breakTimeTotal = prefs.getInt('breakTimeTotal') ?? 0;
      _lastToggleTimestamp = prefs.getInt('lastToggleTimestamp') ?? 0;

      showSeconds = prefs.getBool('showSeconds') ?? true;
    });
  }

  _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('working', _working);
    await prefs.setInt('workTimeTotal', _workTimeTotal);
    await prefs.setInt('breakTimeTotal', _breakTimeTotal);
    await prefs.setInt('lastToggleTimestamp', _lastToggleTimestamp);
  }

  String _printFormattedTimeTotal(int durationInSeconds) {
    Duration duration = Duration(seconds: durationInSeconds);

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (showSeconds) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
    }
  }

  void _displayTimer(Timer? timer) {
    if (_lastToggleTimestamp == 0) return;
    int nowTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int workCountdownTotalLive = 0;

    setState(() {
      if (_working) {
        // do calc
        int workTimeTotalLive =
            _workTimeTotal + nowTimeStamp - _lastToggleTimestamp;
        workCountdownTotalLive = workday - workTimeTotalLive;

        // set strings
        _workTimeTotalString = _printFormattedTimeTotal(workTimeTotalLive);
        _breakTimeTotalString = _printFormattedTimeTotal(_breakTimeTotal);

        // set progressbar
        _progressBarValue = workTimeTotalLive / workday;
      } else {
        // do calc
        int breakTimeTotalLive =
            _breakTimeTotal + nowTimeStamp - _lastToggleTimestamp;
        workCountdownTotalLive = workday - _workTimeTotal;

        // set strings
        _workTimeTotalString = _printFormattedTimeTotal(_workTimeTotal);
        _breakTimeTotalString = _printFormattedTimeTotal(breakTimeTotalLive);

        // set progressbar
        _progressBarValue = _workTimeTotal / workday;
      }

      // set work countdown
      _workCountdownTotalString = workCountdownTotalLive > 0
          ? _printFormattedTimeTotal(workCountdownTotalLive)
          : "✅";

      if (_progressBarValue > 1.0) _progressBarValue = 1.0;
    });
  }

  void _toggleTimer() {
    setState(() {
      int nowTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (_lastToggleTimestamp != 0) {
        if (_working) {
          _workTimeTotal = _workTimeTotal + nowTimeStamp - _lastToggleTimestamp;
        } else {
          _breakTimeTotal =
              _breakTimeTotal + nowTimeStamp - _lastToggleTimestamp;
        }
      }

      _working = !_working;
      _lastToggleTimestamp = nowTimeStamp;
    });

    _saveState();
  }

  void _resetTimer() {
    _working = false;
    _lastToggleTimestamp = 0;
    _workTimeTotal = 0;
    _breakTimeTotal = 0;
    _toggleTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _resetTimer,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 3),
            LinearProgressIndicator(
              value: _progressBarValue,
              semanticsLabel: 'Linear progress indicator',
            ),
            Text(
              '⏱️ Work Countdown',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              _workCountdownTotalString,
              style: const TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.w100,
                fontSize: 80,
              ),
            ),
            const Spacer(flex: 1),
            GestureDetector(
              onTap: _toggleTimer,
              child: Column(
                children: [
                  Text(
                    '💼 Work Time',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    _workTimeTotalString,
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: _working ? FontWeight.w500 : FontWeight.w100,
                      fontSize: 80,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            GestureDetector(
              onTap: _toggleTimer,
              child: Column(
                children: [
                  Text(
                    '☕️ Break Time ',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    _breakTimeTotalString,
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: _working ? FontWeight.w100 : FontWeight.w500,
                      fontSize: 80,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTimer,
        tooltip: 'Toggle',
        foregroundColor: Colors.white,
        child:
            _working ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      ),
    );
  }
}
