import 'package:flutter/material.dart';
import 'package:timer/src/alarm.dart';
import 'package:timer/src/timer.dart';
import 'package:timer/src/secundomer.dart';

class MyApp4 extends StatefulWidget {
  @override
  State<MyApp4> createState() => _MyApp4State();
}

class _MyApp4State extends State<MyApp4> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  @override
  _BottomNavigationBarExampleState createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MyApp(),  // Таймер
    const MyApp2(), // Секундомер
    const MyApp3(), // Будильник
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Сохраняет состояние страниц
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Таймер',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch),
            label: 'Секундомер',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Будильник',
          ),
        ],
      ),
    );
  }
}
