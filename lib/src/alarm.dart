import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class MyApp3 extends StatefulWidget {
  const MyApp3({super.key});

  @override
  State<MyApp3> createState() => _MyApp3State();
}

class _MyApp3State extends State<MyApp3> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Будильник',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AlarmPage(),
    );
  }
}

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  TimeOfDay _alarmTime = TimeOfDay.now(); // Время будильника
  bool _isAlarmSet = false; // Включён ли будильник
  bool _isAlarmRinging = false; // Звонит ли будильник
  Timer? _alarmTimer;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadAlarmState(); // Загружаем сохранённые данные
  }

  // Загрузка сохранённых данных
  Future<void> _loadAlarmState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAlarmSet = prefs.getBool('alarm_set') ?? false;
      int? hour = prefs.getInt('alarm_hour');
      int? minute = prefs.getInt('alarm_minute');
      if (hour != null && minute != null) {
        _alarmTime = TimeOfDay(hour: hour, minute: minute);
      }
    });

    // Если будильник был включён, запустить таймер
    if (_isAlarmSet) {
      _startAlarmTimer();
    }
  }

  // Сохранение состояния будильника
  Future<void> _saveAlarmState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_set', _isAlarmSet);
    await prefs.setInt('alarm_hour', _alarmTime.hour);
    await prefs.setInt('alarm_minute', _alarmTime.minute);
  }

  // Установка времени будильника
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime,
    );
    if (picked != null) {
      setState(() {
        _alarmTime = picked;
      });
      _saveAlarmState();
    }
  }

  // Включение/выключение будильника
  void _toggleAlarm() {
    setState(() {
      _isAlarmSet = !_isAlarmSet;
    });
    if (_isAlarmSet) {
      _startAlarmTimer();
    } else {
      _stopAlarm();
    }
    _saveAlarmState();
  }

  // Запуск таймера для проверки времени будильника
  void _startAlarmTimer() {
    _alarmTimer?.cancel();
    _alarmTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = TimeOfDay.now();
      if (now.hour == _alarmTime.hour && now.minute == _alarmTime.minute) {
        _startAlarmSound();
        setState(() {
          _isAlarmRinging = true;
        });
      }
    });
  }

  // Воспроизведение звука будильника
  void _startAlarmSound() async {
    while (_isAlarmRinging) {
      await _player.play(AssetSource('sounds/signal.mp3'));
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  // Остановка будильника
  void _stopAlarm() {
    _alarmTimer?.cancel();
    _player.stop();
    setState(() {
      _isAlarmRinging = false;
    });
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Будильник'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Время будильника: ${_alarmTime.format(context)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('Установить время'),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Будильник выкл / вкл'),
              value: _isAlarmSet,
              onChanged: (value) => _toggleAlarm(),
            ),
          ],
        ),
      ),
    );
  }
}
