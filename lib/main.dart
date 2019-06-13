import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Timer"),
        ),
        body: TimerPage(TimerModel()),
      ),
    );
  }
}

class TimerModel extends Model {
  final stopwatch = new Stopwatch();
  List<String> times = ["one", "two"];

  void toggle() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
    } else {
      stopwatch.start();
    }
    //notifyListeners();
  }

  void save() {
    times.add(stopwatch.elapsed.toString());
    notifyListeners();
    print("time was saved");
    print(times);
  }

  void reset() {
    stopwatch.reset();
    print("stopwatch was refreshed");
  }

  bool isRunning() {
    return stopwatch.isRunning;
  }

  static TimerModel of(BuildContext context) =>
      ScopedModel.of<TimerModel>(context);
}

class TimerPage extends StatelessWidget {
  final TimerModel timerModel;
  TimerPage(this.timerModel);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TimerModel>(
      model: timerModel,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 40, bottom: 40),
              child: TimerWidget(),
            ),
            Container(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: ButtonWidget(),
            ),
            Expanded(
              child: ListWidget(),
            )
          ],
        ),
      ),
    );
  }
}

class ButtonWidget extends StatefulWidget {
  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  void _playButtonPressed() {
    setState(() {
      if (TimerModel.of(context).isRunning()) {
        TimerModel.of(context).toggle();
      } else {
        TimerModel.of(context).toggle();
      }
    });
  }

  void _resetButtonPressed() {
    TimerModel.of(context).reset();
  }

  void _saveButtonPressed() {
    TimerModel.of(context).save();
  }

  Widget _buildButton(IconData icon, VoidCallback callback) {
    return FloatingActionButton(
      child: Icon(icon),
      backgroundColor: Colors.blue,
      onPressed: callback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildButton(
            TimerModel.of(context).isRunning() ? Icons.stop : Icons.play_arrow,
            _playButtonPressed),
        _buildButton(
            TimerModel.of(context).isRunning() ? Icons.save : Icons.refresh,
            TimerModel.of(context).isRunning()
                ? _saveButtonPressed
                : _resetButtonPressed),
      ],
    );
  }
}

class TimerWidget extends StatefulWidget {
  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Duration(milliseconds: 16),
      (_t) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${TimerModel.of(context).stopwatch.elapsed}",
      style: TextStyle(fontSize: 36),
    );
  }
}

class ListWidget extends StatefulWidget {
  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  Widget _buildRow(String time) {
    return ListTile(
      leading: Icon(Icons.timer),
      title: Text(
        time,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
        reverse: true,
        padding: EdgeInsets.all(16.0),
        itemCount: TimerModel.of(context).times.length,
        itemBuilder: (context, index) {
          return new Column(children: [
            Divider(),
            _buildRow(TimerModel.of(context).times[index]),
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }
}
