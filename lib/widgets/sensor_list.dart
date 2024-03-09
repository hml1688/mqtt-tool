import 'package:flutter/material.dart';
import 'package:mqtt_tool/widgets/mqtt_detail.dart';
import '../models/sensor.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
//import 'package:progress_hud/progress_hud.dart';
import 'package:string_validator/string_validator.dart' as sV;

import 'dart:async';

class SensorListState extends State<SensorList> {
  String _topic = '';

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
    _populateSensorList();
  }

  List<Sensor> _mqttSensors = <Sensor>[];

  String broker = 'mqtt.cetools.org';
  int port = 1883;
  String clientIdentifier = 'ce-mqtt-mobile-app';

  mqtt.MqttClient? client;
  mqtt.MqttConnectionState? connectionState;
  //String _topic = "UCL/OPS/107/#";

  StreamSubscription? subscription;

  bool _sensorInList = false;

  //late ProgressHUD _progressHUD;
  bool _loading = true;

  int dissmissView = 0;

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ' + broker + ':\t ${topic.trim()}');
      client!.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  @override
  void dispose() {
    print("MQTT Server View is Closed");
    dissmissView = 1;
    if (client!.connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Disconnecting from MQTT Server: ' + broker);
      _disconnect();
    }

    super.dispose();
  }

  void _populateSensorList() {
    _connect();
  }

  ListTile _buildItemsForListView(BuildContext context, int i) {
    return ListTile(
      leading: CircleAvatar(child: Text("$i")),
      title: Text(_mqttSensors[i].topic),
      subtitle: Text("Last Message: " +
          DateFormat("dd-MM-yyyy HH:mm:ss")
              .format(_mqttSensors[i].lastMessage)),
      trailing: Icon(Icons.keyboard_arrow_right,
          color: Color.fromRGBO(58, 66, 86, 1.0), size: 30.0),
      isThreeLine: true,
      onTap: () {
        Navigator.pushNamed(context, MQTTDetail.routeName,
            arguments: _mqttSensors[i]);
      },
      onLongPress: () {
        print(
          Text("Long Pressed"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        body: Stack(
      children: <Widget>[
        ListView.builder(
          itemCount: _mqttSensors.length,
          itemBuilder: _buildItemsForListView,
          padding: const EdgeInsets.all(8.0),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
        ),
        // _progressHUD,
      ],
    ));
  }

  //  ************** MQTT Stuff from here down **********************************

  void dismissProgressHUD() {
    setState(() {
      _loading = !_loading;
    });
  }

  void _connect() async {
    client = MqttServerClient(broker, '');
    client!.port = port;

    client!.logging(on: false);
    client!.keepAlivePeriod = 30;

    client!.onDisconnected = _onDisconnected;

    dissmissView = 0;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean() // Non persistent session for testing
        .withWillQos(mqtt.MqttQos.atMostOnce);

    print('[MQTT client] MQTT client connecting....');

    client!.connectionMessage = connMess;

    try {
      await client!.connect();
    } catch (e) {
      print(e);
      dismissProgressHUD();
      Fluttertoast.showToast(
          msg: "Error: Couldn't connect to MQTT",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      _disconnect();
    }

    /// Check if we are connected
    if (client!.connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Connected to ' + broker);
      dismissProgressHUD();
      setState(() {
        connectionState = client!.connectionState;
      });
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client!.connectionStatus}');

      _disconnect();
    }

    subscription = client!.updates!.listen(_onMessage);

    _subscribeToTopic(_topic);
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client!.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');

    if (dissmissView != 1) {
      setState(() {
        if (client != null) {
          connectionState = client!.connectionState;
        }
        client = null;
        if (subscription != null) {
          subscription!.cancel();
        }
        subscription = null;
      });
    } else {
      if (client != null) {
        connectionState = client!.connectionState;
      }

      client = null;
      if (subscription != null) {
        subscription!.cancel();
      }
      subscription = null;
    }

    print('[MQTT client] MQTT client disconnected');

    if (dissmissView != 1) {
      dismissProgressHUD();

      Fluttertoast.showToast(
          msg: "Disconnected from MQTT Server",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    final mqtt.MqttPublishMessage recMess =
        event[0].payload as mqtt.MqttPublishMessage;
    final String message =
        mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    // Extract sensor data from the message (replace with your logic)
    String sensorId = event[0]
        .topic
        .split("/")[1]; // Assuming topic format "personal/<sensorId>"

    // Check if sensor already exists
    bool sensorFound = false;
    for (var i = 0; i < _mqttSensors.length; i++) {
      if (_mqttSensors[i].topic == event[0].topic) {
        sensorFound = true;
        _mqttSensors[i].updateLastMessage(); // Update existing sensor
        break;
      }
    }

    // Add new sensor if not found
    if (!sensorFound) {
      _mqttSensors.add(Sensor(event[0].topic)); // Create new sensor
    }

    setState(() {});
  }
}

class SensorList extends StatefulWidget {
  final String topic; // Declare a final variable to hold the topic

  // Constructor to receive the topic
  SensorList(this.topic);

  @override
  createState() => SensorListState();
}
