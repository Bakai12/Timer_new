import 'package:flutter/material.dart';
import 'dart:async';



class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Секундомер',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StopwatchPage(),
    );
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  Timer? _timer;
  int _elapsedTime = 0; // Прошедшее время в миллисекундах
  bool _isRunning = false;
  final List<String> _laps = []; // Список для сохранения кругов

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _elapsedTime += 10; // Увеличиваем время на 10 миллисекунд
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedTime = 0;
      _laps.clear(); // Очищаем список кругов
      _isRunning = false;
    });
  }

  void _recordLap() {
    setState(() {
      _laps.add(_formatTime(_elapsedTime)); // Добавляем текущее время в список кругов
    });
  }

  String _formatTime(int milliseconds) {
    int hours = milliseconds ~/ 3600000;
    int minutes = (milliseconds % 3600000) ~/ 60000;
    int seconds = (milliseconds % 60000) ~/ 1000;
    int centiseconds = (milliseconds % 1000) ~/ 10;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
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
        title: const Text('Секундомер'),
        centerTitle: true,
      ),
        body: Padding(
        padding: const EdgeInsets.only(top: 220.0),
        child:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_elapsedTime),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  child: Text(_isRunning ? 'Стоп' : 'Старт'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isRunning ? _recordLap : null,
                  child: const Text('Круг'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Сброс'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _laps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Круг ${index + 1}: ${_laps[index]}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}