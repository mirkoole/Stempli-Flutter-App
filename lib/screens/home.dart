import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // settings
  int workday = 8 * 60 * 60;
  bool showSeconds =
      Settings.getValue<bool>("key-seconds-enabled", defaultValue: true) != null
          ? true
          : false;
  bool showCountdown =
      Settings.getValue<bool>("key-countdown-enabled", defaultValue: true) !=
              null
          ? true
          : false;
  int adjustInterval = 60 * 10;

  // internal vars
  Timer? _timer;

  bool _working = false;

  int _lastToggleTimestamp = 0;
  int _workTimeTotal = 0;
  int _breakTimeTotal = 0;
  int breakTimeTotalLive = 0;

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
    showSeconds = prefs.getBool('key-seconds-enabled') ?? true;
    showCountdown = prefs.getBool('key-countdown-enabled') ?? true;

    setState(() {
      _working = prefs.getBool('working') ?? false;
      _workTimeTotal = prefs.getInt('workTimeTotal') ?? 0;
      _breakTimeTotal = prefs.getInt('breakTimeTotal') ?? 0;
      _lastToggleTimestamp = prefs.getInt('lastToggleTimestamp') ?? 0;
    });

    // start timer on first app launch
    if (_lastToggleTimestamp == 0) _toggleTimer();
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

    if (showSeconds) {
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
    }
  }

  void _displayTimer(Timer? timer) {
    _readState();

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
        breakTimeTotalLive =
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

  void _plusTimer() async {
    _workTimeTotal += adjustInterval;

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: const Text('Timer adjusted! 10 Minutes added to work time.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _workTimeTotal -= adjustInterval;
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _fixTimer() async {
    if (breakTimeTotalLive < adjustInterval) {
      _showSimpleSnackBar("This works only after 10 minutes of break.",
          const Duration(seconds: 10));
      return;
    }

    _workTimeTotal += adjustInterval;
    _breakTimeTotal -= adjustInterval;

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: const Text(
          'Timer adjusted! 10 Minutes moved from break to work time.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _workTimeTotal -= adjustInterval;
          _breakTimeTotal += adjustInterval;
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSimpleSnackBar(String title, Duration duration) {
    final snackBar = SnackBar(
      duration: duration,
      content: Text(title),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _resetTimer() {
    // save vars for possible undo
    bool oldWorking = _working;
    int oldLastToggleTimestamp = _lastToggleTimestamp;
    int oldWorkTimeTotal = _workTimeTotal;
    int oldBreakTimeTotal = _breakTimeTotal;

    // reset vars
    _working = false;
    _lastToggleTimestamp = 0;
    _workTimeTotal = 0;
    _breakTimeTotal = 0;
    _toggleTimer();

    // show snackBar
    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: const Text('Timer reset done. Have a nice day 🙂'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _working = oldWorking;
          _lastToggleTimestamp = oldLastToggleTimestamp;
          _workTimeTotal = oldWorkTimeTotal;
          _breakTimeTotal = oldBreakTimeTotal;
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              Icons.plus_one_rounded,
              color: Colors.white,
            ),
            onPressed: _plusTimer,
            tooltip: "Add 10 minutes to Work Time",
          ),
          IconButton(
            icon: const Icon(
              Icons.auto_fix_high,
              color: Colors.white,
            ),
            onPressed: _fixTimer,
            tooltip: "Move 10 minutes from Break to Work Time",
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _resetTimer,
            tooltip: "Reset Timer",
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () => {Navigator.pushNamed(context, '/settings')},
            tooltip: "Reset Timer",
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 3),
              LinearProgressIndicator(
                value: _progressBarValue,
                semanticsLabel: 'Linear progress indicator',
              ),
              showCountdown
                  ? GestureDetector(
                      onTap: _toggleTimer,
                      onLongPress: _resetTimer,
                      onPanUpdate: (d) {
                        if (d.delta.dx > 0) _resetTimer();
                      },
                      child: Column(
                        children: [
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
                        ],
                      ),
                    )
                  : Container(),
              const Spacer(flex: 1),
              GestureDetector(
                onTap: _toggleTimer,
                onLongPress: _resetTimer,
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
                        fontWeight:
                            _working ? FontWeight.w500 : FontWeight.w100,
                        fontSize: 80,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              GestureDetector(
                onTap: _toggleTimer,
                onLongPress: _resetTimer,
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
                        fontWeight:
                            _working ? FontWeight.w100 : FontWeight.w500,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTimer,
        tooltip: 'Toggle Work and Break Timer',
        foregroundColor: Colors.white,
        child: _working ? const Icon(Icons.coffee) : const Icon(Icons.work),
      ),
    );
  }
}
