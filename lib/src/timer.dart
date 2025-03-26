import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Таймер',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with SingleTickerProviderStateMixin {
  int _selectedMinutes = 1;
  int _remainingSeconds = 60;
  Timer? _timer;
  bool _isRunning = false;
  final TextEditingController _minutesController = TextEditingController();
  final player = AudioPlayer();

  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: Duration(seconds: _selectedMinutes * 60),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.linear),
    );
  }

  void _playSound() async {
    await player.play(AssetSource('sounds/signal.mp3'));
  }

  void _startTimer() {
    if (_isRunning) return; // Не начинать, если уже запущен

    setState(() {
      _isRunning = true;
    });

    // Обновляем длительность анимации на основе оставшегося времени
    _progressAnimationController.duration = Duration(seconds: _remainingSeconds);
    _progressAnimationController.forward(from: _progressAnimationController.value);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        // Каждый раз обновляем анимацию с учетом оставшихся секунд
        _progressAnimationController.duration = Duration(seconds: _remainingSeconds);
        _progressAnimationController.forward(from: _progressAnimationController.value);
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
          _remainingSeconds = _selectedMinutes * 60; // Сброс оставшегося времени
        });
        _playSound();
        _progressAnimationController.reset(); // Сбросить анимацию
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    // Останавливаем анимацию без сброса
    _progressAnimationController.stop();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isRunning = false;
    });
    // Сбросить анимацию
    _progressAnimationController.reset();
  }

  void _setCustomTime() {
    final int? customMinutes = int.tryParse(_minutesController.text);
    if (customMinutes != null && customMinutes > 0) {
      setState(() {
        _selectedMinutes = customMinutes;
        _remainingSeconds = customMinutes * 60;
        _progressAnimationController.duration = Duration(seconds: _remainingSeconds);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите корректное время в минутах!'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressAnimationController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Таймер'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenSize,
              height: screenSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: screenSize,
                      height: screenSize,
                      child: AnimatedBuilder(
                        animation: _progressAnimationController,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _progressAnimation.value,
                            strokeWidth: 20,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    child: Text(
                      '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Введите время (в минутах)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _setCustomTime,
              child: const Text('Установить время'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTimer,
                  child: const Text('Старт'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : null,
                  child: const Text('Стоп'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Сброс'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
