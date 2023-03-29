import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/datetime.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // default values
  double _weeklyWorkHours = 40.0;
  int _weeklyWorkDays = 5;
  int _dailyWorkTime = 8 * 60 * 60;

  int _adjustInterval = 10 * 60;
  bool _showSeconds = true;
  bool _showCountdown = true;
  bool _showProgressbar = true;

  Timer? _timer;
  bool _working = false;

  int _lastToggleTimestamp = 0;
  int _workTimeTotal = 0;
  int _breakTimeTotal = 0;
  int _breakTimeTotalLive = 0;

  double _progressBarValue = 0.0;

  String _workCountdownTotalString = " ";
  String _workTimeTotalString = " ";
  String _breakTimeTotalString = " ";

  @override
  void initState() {
    super.initState();

    _readState();

    // show timer instantly on app launch
    Timer.run(() {
      _displayTimer(_timer);
    });

    // call display timer every second to update view
    _timer = Timer.periodic(const Duration(seconds: 1), _displayTimer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _readState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _weeklyWorkHours = prefs.getDouble('weeklyWorkHours') ?? _weeklyWorkHours;
    _weeklyWorkDays = prefs.getInt('weeklyWorkDays') ?? _weeklyWorkDays;
    _dailyWorkTime =
        (calcWeeklyWorkTimeToDailyWorktime(_weeklyWorkHours, _weeklyWorkDays) *
                60 *
                60)
            .toInt();

    _adjustInterval = prefs.getInt('adjustInterval') ?? _adjustInterval;

    _showSeconds = prefs.getBool('showSeconds') ?? _showSeconds;
    _showCountdown = prefs.getBool('showCountdown') ?? _showCountdown;
    _showProgressbar = prefs.getBool('showProgressbar') ?? _showProgressbar;

    _working = prefs.getBool('working') ?? _working;

    _lastToggleTimestamp =
        prefs.getInt('lastToggleTimestamp') ?? _lastToggleTimestamp;

    _workTimeTotal = prefs.getInt('workTimeTotal') ?? _workTimeTotal;
    _breakTimeTotal = prefs.getInt('breakTimeTotal') ?? _breakTimeTotal;

    setState(() {});
  }

  _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('working', _working);
    await prefs.setInt('workTimeTotal', _workTimeTotal);
    await prefs.setInt('breakTimeTotal', _breakTimeTotal);
    await prefs.setInt('lastToggleTimestamp', _lastToggleTimestamp);
  }

  void _displayTimer(Timer? timer) {
    _readState();

    if (_lastToggleTimestamp == 0) {
      _toggleTimer();
    }

    int nowTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int workCountdownTotalLive = 0;

    if (_working) {
      // do calc
      int workTimeTotalLive =
          _workTimeTotal + nowTimeStamp - _lastToggleTimestamp;

      workCountdownTotalLive = _dailyWorkTime - workTimeTotalLive;

      // set strings
      _workTimeTotalString = _printFormattedTimeTotal(workTimeTotalLive);
      _breakTimeTotalString = _printFormattedTimeTotal(_breakTimeTotal);

      // set progressbar
      _progressBarValue = workTimeTotalLive / _dailyWorkTime;
    } else {
      // do calc
      _breakTimeTotalLive =
          _breakTimeTotal + nowTimeStamp - _lastToggleTimestamp;
      workCountdownTotalLive = _dailyWorkTime - _workTimeTotal;

      // set strings
      _workTimeTotalString = _printFormattedTimeTotal(_workTimeTotal);
      _breakTimeTotalString = _printFormattedTimeTotal(_breakTimeTotalLive);

      // set progressbar
      _progressBarValue = _workTimeTotal / _dailyWorkTime;
    }

    // set work countdown
    _workCountdownTotalString = workCountdownTotalLive > 0
        ? _printFormattedTimeTotal(workCountdownTotalLive)
        : "✅";

    if (_progressBarValue > 1.0) {
      _progressBarValue = 1.0;
    }

    setState(() {});
  }

  String _printFormattedTimeTotal(int durationInSeconds) {
    Duration duration = Duration(seconds: durationInSeconds);

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

    if (_showSeconds) {
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
    }
  }

  void _toggleTimer() {
    int nowTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (_lastToggleTimestamp != 0) {
      if (_working) {
        _workTimeTotal = _workTimeTotal + nowTimeStamp - _lastToggleTimestamp;
      } else {
        _breakTimeTotal = _breakTimeTotal + nowTimeStamp - _lastToggleTimestamp;
      }
    }

    _working = !_working;
    _lastToggleTimestamp = nowTimeStamp;

    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.work,
            ),
            onPressed: _plusWorkTime,
            tooltip: "Add ${_adjustInterval ~/ 60} minutes to Work Time",
          ),
          IconButton(
            icon: const Icon(
              Icons.coffee,
            ),
            onPressed: _plusBreakTime,
            tooltip: "Add ${_adjustInterval ~/ 60} minutes to Break Time",
          ),
          IconButton(
            icon: const Icon(
              Icons.auto_fix_high,
            ),
            onPressed: _moveBreakToWorkTime,
            tooltip:
                "Move ${_adjustInterval ~/ 60} minutes from Break to Work Time",
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: _resetTimer,
            tooltip: "Reset Timer",
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () => {Navigator.pushNamed(context, '/settings')},
            tooltip: "Settings",
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
              _showProgressbar
                  ? LinearProgressIndicator(
                      value: _progressBarValue,
                      semanticsLabel: 'Linear progress indicator',
                    )
                  : Container(),
              _showCountdown
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
        child: _working ? const Icon(Icons.coffee) : const Icon(Icons.work),
      ),
    );
  }

  void _plusWorkTime() {
    _workTimeTotal += _adjustInterval;
    _saveState();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text("${_adjustInterval ~/ 60} Minutes added to Work Time."),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _workTimeTotal -= _adjustInterval;
          _saveState();
        },
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _plusBreakTime() {
    _breakTimeTotal += _adjustInterval;
    _saveState();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text("${_adjustInterval ~/ 60} Minutes added to Break Time."),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _breakTimeTotal -= _adjustInterval;
          _saveState();
        },
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _moveBreakToWorkTime() {
    if (_breakTimeTotalLive < _adjustInterval &&
        _breakTimeTotal < _adjustInterval) {
      _showSimpleSnackBar(
          "This works when Break Time is greater than ${_adjustInterval ~/ 60} Minutes.",
          const Duration(seconds: 10));
      return;
    }

    _workTimeTotal += _adjustInterval;
    _breakTimeTotal -= _adjustInterval;
    _saveState();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text(
          '${_adjustInterval ~/ 60} Minutes moved from Break to Work Time.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _workTimeTotal -= _adjustInterval;
          _breakTimeTotal += _adjustInterval;
          _saveState();
        },
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSimpleSnackBar(String title, Duration duration) {
    final snackBar = SnackBar(
      duration: duration,
      content: Text(title),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
          _saveState();
        },
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
