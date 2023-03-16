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
  int _dailyWorkTime = 0;
  bool _showSeconds = true;
  bool _showCountdown = true;
  int _adjustInterval = 0;

  // internal vars
  Timer? _timer;

  bool _working = true;

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

  _readState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _dailyWorkTime =
        (60 * 60 * Settings.getValue<double>("dailyWorkTime", defaultValue: 8)!)
            .toInt();
    _showSeconds = Settings.getValue<bool>("showSeconds", defaultValue: true)!;
    _showCountdown =
        Settings.getValue<bool>("showCountdown", defaultValue: true)!;
    _adjustInterval = prefs.getInt('adjustInterval') ?? 60 * 10;

    setState(() {
      _working = prefs.getBool('working') ?? true;
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

    if (_showSeconds) {
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

  void _plusWorkTime() {
    _workTimeTotal += _adjustInterval;
    _saveState();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text(
          "${_adjustInterval ~/ 60} Minutes added to Work Time."),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _workTimeTotal -= _adjustInterval;
          _saveState();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _plusBreakTime() {
    _breakTimeTotal += _adjustInterval;
    _saveState();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text(
          "${_adjustInterval ~/ 60} Minutes added to Break Time."),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _breakTimeTotal -= _adjustInterval;
          _saveState();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _moveBreakToWorkTime() {
    if (_breakTimeTotalLive < _adjustInterval || _breakTimeTotal < _adjustInterval) {
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
          '${_adjustInterval~/60} Minutes moved from Break to Work Time.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _workTimeTotal -= _adjustInterval;
          _breakTimeTotal += _adjustInterval;
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
              Icons.work,
              color: Colors.white,
            ),
            onPressed: _plusWorkTime,
            tooltip: "Add ${_adjustInterval ~/ 60} minutes to Work Time",
          ),
          IconButton(
            icon: const Icon(
              Icons.coffee,
              color: Colors.white,
            ),
            onPressed: _plusBreakTime,
            tooltip: "Add ${_adjustInterval ~/ 60} minutes to Work Time",
          ),
          IconButton(
            icon: const Icon(
              Icons.auto_fix_high,
              color: Colors.white,
            ),
            onPressed: _moveBreakToWorkTime,
            tooltip:
                "Move ${_adjustInterval ~/ 60} minutes from Break to Work Time",
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
