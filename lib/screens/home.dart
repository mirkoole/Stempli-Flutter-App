// ignore_for_file: public_member_api_docs, diagnostic_describe_all_properties

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stempli_flutter/main.dart';

import 'package:stempli_flutter/utils/config.dart';

import '../utils/datetime.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.title, super.key});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dailyWorkTime =
      sharedPreferences.getInt('dailyWorkTime') ?? defaultDailyWorkTime;
  int _adjustInterval =
      sharedPreferences.getInt('adjustInterval') ?? defaultAdjustInterval;
  bool _showSeconds =
      sharedPreferences.getBool('showSeconds') ?? defaultShowSeconds;
  bool _showCountdown =
      sharedPreferences.getBool('showCountdown') ?? defaultShowCountdown;
  bool _showProgressbar =
      sharedPreferences.getBool('showProgressbar') ?? defaultShowProgressbar;

  Timer? _timer;
  bool _working = false;

  int _lastToggleTimestamp = 0;
  int _workTimeTotal = 0;
  int _breakTimeTotal = 0;
  int _breakTimeTotalLive = 0;

  double _progressBarValue = 0;

  String _workCountdownTotalString = ' ';
  String _workTimeTotalString = ' ';
  String _breakTimeTotalString = ' ';

  bool _enableAppBarButtons = true;

  @override
  void initState() {
    unawaited(_readState());

    // show timer instantly on app launch
    Timer.run(() {
      unawaited(_displayTimer(_timer));
    });

    // call display timer every second to update view
    _timer = Timer.periodic(const Duration(seconds: 1), _displayTimer);

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _readState() {
    // calc
    _working = sharedPreferences.getBool('working') ?? _working;
    _lastToggleTimestamp =
        sharedPreferences.getInt('lastToggleTimestamp') ?? _lastToggleTimestamp;
    _workTimeTotal =
        sharedPreferences.getInt('workTimeTotal') ?? _workTimeTotal;
    _breakTimeTotal =
        sharedPreferences.getInt('breakTimeTotal') ?? _breakTimeTotal;

    // timer settings
    var customDailyWorkTime =
        sharedPreferences.getBool("customDailyWorkTimes") ??
            defaultCustomDailyWorkTimes;
    if (customDailyWorkTime) {
      var dayOfWeek = getDayOfWeek();

      _dailyWorkTime = sharedPreferences.getInt('dailyWorkTime$dayOfWeek') ??
          defaultDailyWorkTime;
    } else {
      _dailyWorkTime =
          sharedPreferences.getInt('dailyWorkTime') ?? defaultDailyWorkTime;
    }

    _adjustInterval =
        sharedPreferences.getInt('adjustInterval') ?? defaultAdjustInterval;

    // UI Changes
    _showSeconds =
        sharedPreferences.getBool('showSeconds') ?? defaultShowSeconds;
    _showCountdown =
        sharedPreferences.getBool('showCountdown') ?? defaultShowCountdown;
    _showProgressbar =
        sharedPreferences.getBool('showProgressbar') ?? defaultShowProgressbar;

    setState(() {});
  }

  _saveState() {
    sharedPreferences.setBool('working', _working);
    sharedPreferences.setInt('workTimeTotal', _workTimeTotal);
    sharedPreferences.setInt('breakTimeTotal', _breakTimeTotal);
    sharedPreferences.setInt('lastToggleTimestamp', _lastToggleTimestamp);
  }

  Future<void> _displayTimer(Timer? timer) async {
    _readState();

    if (_lastToggleTimestamp == 0) {
      await _toggleTimer();
    }

    final nowTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var workCountdownTotalLive = 0;

    if (_working) {
      // do calc
      final workTimeTotalLive =
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
        : '✅';

    if (_progressBarValue > 1.0) {
      _progressBarValue = 1.0;
    }

    setState(() {});
  }

  String _printFormattedTimeTotal(int durationInSeconds) {
    final duration = Duration(seconds: durationInSeconds);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

    if (_showSeconds) {
      final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes';
    }
  }

  Future<void> _toggleTimer() async {
    final nowTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (_lastToggleTimestamp != 0) {
      if (_working) {
        _workTimeTotal = _workTimeTotal + nowTimeStamp - _lastToggleTimestamp;
      } else {
        _breakTimeTotal = _breakTimeTotal + nowTimeStamp - _lastToggleTimestamp;
      }
    }

    _working = !_working;
    _lastToggleTimestamp = nowTimeStamp;

    await _saveState();
  }

  @override
  Widget build(BuildContext context) {
    final adjustIntervalMin = _adjustInterval ~/ 60;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.work,
            ),
            onPressed: _enableAppBarButtons ? _plusWorkTime : null,
            tooltip: 'Add $adjustIntervalMin minutes to Worktime',
          ),
          IconButton(
            icon: const Icon(
              Icons.coffee,
            ),
            onPressed: _enableAppBarButtons ? _plusBreakTime : null,
            tooltip: 'Add ${_adjustInterval ~/ 60} minutes to Breaktime',
          ),
          IconButton(
            icon: const Icon(
              Icons.auto_fix_high,
            ),
            onPressed: _enableAppBarButtons ? _moveBreakToWorkTime : null,
            tooltip:
                'Move ${_adjustInterval ~/ 60} minutes from Break to Worktime',
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: _enableAppBarButtons ? _resetTimer : null,
            tooltip: 'Reset Timer',
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () async => {
              Navigator.pushNamed(context, '/settings')
                  .then((_) => setState(() {}))
            },
            tooltip: 'Settings',
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 3),
              if (_showProgressbar)
                GestureDetector(
                  onPanUpdate: (d) async {
                    if (d.delta.dx > 0) await _resetTimer();
                  },
                  child: LinearProgressIndicator(
                    minHeight: 30,
                    value: _progressBarValue,
                  ),
                )
              else
                Container(),
              if (_showProgressbar) const Spacer() else Container(),
              if (_showCountdown)
                GestureDetector(
                  onTap: _toggleTimer,
                  onLongPress: _resetTimer,
                  onPanUpdate: (d) async {
                    if (d.delta.dx > 0) await _resetTimer();
                  },
                  child: Column(
                    children: [
                      Text(
                        '⏱️ Countdown',
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
              else
                Container(),
              const Spacer(),
              GestureDetector(
                onTap: _toggleTimer,
                onLongPress: _moveOverTime,
                child: Column(
                  children: [
                    Text(
                      '💼 Worktime',
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
              const Spacer(),
              GestureDetector(
                onTap: _toggleTimer,
                onLongPress: _resetTimer,
                child: Column(
                  children: [
                    Text(
                      '☕️ Breaktime',
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
        tooltip: 'Toggle Work and Breaktimer',
        child: _working ? const Icon(Icons.coffee) : const Icon(Icons.work),
      ),
    );
  }

  Future<void> _plusWorkTime() async {
    _workTimeTotal += _adjustInterval;
    await _saveState();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text('${_adjustInterval ~/ 60} Minutes added to Worktime.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _workTimeTotal -= _adjustInterval;
          _saveState();
        },
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _plusBreakTime() async {
    _breakTimeTotal += _adjustInterval;
    await _saveState();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text('${_adjustInterval ~/ 60} Minutes added to Breaktime.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _breakTimeTotal -= _adjustInterval;
          _saveState();
        },
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _moveBreakToWorkTime() async {
    final adjustIntervalMin = _adjustInterval ~/ 60;

    if (_breakTimeTotalLive < _adjustInterval &&
        _breakTimeTotal < _adjustInterval) {
      _showSimpleSnackBar(
        // ignore: lines_longer_than_80_chars
        'This works when Breaktime is greater than $adjustIntervalMin Minutes.',
        const Duration(seconds: 10),
      );
      return;
    }

    _workTimeTotal += _adjustInterval;
    _breakTimeTotal -= _adjustInterval;
    await _saveState();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text(
        '${_adjustInterval ~/ 60} Minutes moved from Break to Worktime.',
      ),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _workTimeTotal -= _adjustInterval;
          _breakTimeTotal += _adjustInterval;
          _saveState();
        },
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _showSimpleSnackBar(String title, Duration duration) {
    final snackBar = SnackBar(
      duration: duration,
      content: Text(title),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _moveOverTime() async {
    if (_working) {
      _toggleTimer();
    }

    final overTime = _workTimeTotal - _dailyWorkTime;

    if (overTime > 0) {
      _resetTimer(showSnackbar: false);
      _workTimeTotal += overTime;
      await _saveState();

      _showSimpleSnackBar("💼 Timer reset and overtime moved to today!",
          const Duration(seconds: 10));
    } else {
      _resetTimer();
    }
  }



  Future<void> _resetTimer({bool showSnackbar = true}) async {
    disableAppBarButtons();

    // save vars for possible undo
    final oldWorking = _working;
    final oldLastToggleTimestamp = _lastToggleTimestamp;
    final oldWorkTimeTotal = _workTimeTotal;
    final oldBreakTimeTotal = _breakTimeTotal;

    // reset vars
    _working = false;
    _lastToggleTimestamp = 0;
    _workTimeTotal = 0;
    _breakTimeTotal = 0;
    await _toggleTimer();

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
          _enableAppBarButtons = true;
          _saveState();
        },
      ),
    );

    if (context.mounted && showSnackbar == true) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void disableAppBarButtons() {
      // disable button for some seconds to avoid double calls
    _enableAppBarButtons = false;
    Timer(const Duration(seconds: 5), () => _enableAppBarButtons = true);
  }
}
