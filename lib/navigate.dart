import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'gainz_ai/workout_screen.dart';
import 'gainz_ai/workout_summary.dart';

class NavigatePage extends StatefulWidget {
  @override
  _NavigatePageState createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    WorkoutScreen(),
    WorkoutSummaryScreen(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Pose Detector',
            backgroundColor: CupertinoColors.activeBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.summarize),
            label: 'Workout Summary',
            backgroundColor: CupertinoColors.activeBlue,
          ),

        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
