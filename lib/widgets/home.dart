import 'package:flutter/material.dart';
import 'package:mqtt_tool/widgets/sensor_list.dart';
import 'package:mqtt_tool/widgets/settings.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  // This widget is the root of your application.

  var title = "Home";
  int _currentIndex = 0;

  final List<Function> _children = [
    () => SensorList("UCL/OPS/107/#"),
    () => SensorList("UCL/OPS/Garden/#"),
    () => SensorList("UCL/OPS/206b/#"),
    () => Settings()
  ];

  final List<String> titles = ["OPS 107", "OPS Garden", "OPS 206", "Settings"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
      ),
      body: _children[_currentIndex](),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex:
            _currentIndex, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: titles[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forest),
            label: titles[1],
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.location_city), label: titles[2]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings), label: titles[3]),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
