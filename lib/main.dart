import 'package:flutter/material.dart';
import 'package:mqtt_tool/widgets/home.dart';
import 'package:mqtt_tool/widgets/mqtt_detail.dart';
import 'package:mqtt_tool/widgets/sensor_list.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CE MQTT',
      theme: ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        // '/local': (context) => SensorList("UCL/OPS/107/#"),
        MQTTDetail.routeName: (context) => MQTTDetail(),
      },
    );
  }
}
