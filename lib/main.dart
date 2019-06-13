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
  List<String> times = [];

  void toggle() {
    // スタート、ストップ
    if (stopwatch.isRunning) {
      stopwatch.stop();
    } else {
      stopwatch.start();
    }
    notifyListeners();
  }

  void save() {
    // ラップタイムのセーブ
    times.insert(0, stopwatch.elapsed.toString());
    notifyListeners();
    print("time was saved");
    print(times);
  }

  void reset() {
    // ストップウォッチのリセット
    stopwatch.reset();
    times.clear();
    notifyListeners();
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
              // タイマー部分
              padding: EdgeInsets.only(top: 40, bottom: 40),
              child: TimerWidget(),
            ),
            Container(
              // ボタン類
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: ButtonWidget(),
            ),
            Expanded(
              // ラップタイムのリスト
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
  ButtonWidgetState createState() => ButtonWidgetState();
}

class ButtonWidgetState extends State<ButtonWidget> {
  void _playButtonPressed() {
    // スタート、ストップ処理
    // setStateしないとボタンのアイコンが切り替わらない
    setState(() {
      if (TimerModel.of(context).isRunning()) {
        TimerModel.of(context).toggle();
      } else {
        TimerModel.of(context).toggle();
      }
    });
  }

  void _resetButtonPressed() {
    // リセット処理
    TimerModel.of(context).reset();
  }

  void _saveButtonPressed() {
    // ラップタイムのセーブ処理
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
            // スタート、ストップ
            TimerModel.of(context).isRunning() ? Icons.stop : Icons.play_arrow,
            _playButtonPressed),
        _buildButton(
            // リセット、セーブ
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
      Duration(milliseconds: 16), // 60fpsで更新
      (_t) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _printDuration(Duration duration) {
    // HH:mm:ssにフォーマットする
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
  ListWidgetState createState() => ListWidgetState();
}

class ListWidgetState extends State<ListWidget> {
  Widget _buildRow(String time) {
    return ListTile(
      // リストタイル
      leading: Icon(Icons.timer),
      title: Text(
        time,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
        reverse: false,
        padding: EdgeInsets.all(16.0),
        itemCount: TimerModel.of(context).times.length,
        itemBuilder: (context, index) {
          return new Column(children: [
            Divider(), // 罫線
            _buildRow(TimerModel.of(context).times[index]), // タイル
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TimerModel>(builder: (context, child, model) {
      return _buildList();
    });
  }
}
