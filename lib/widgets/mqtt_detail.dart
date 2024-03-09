import 'package:flutter/material.dart';
import 'package:mqtt_tool/models/sensor.dart';
import 'package:intl/intl.dart';

class MQTTDetail extends StatefulWidget {
  @override
  static const routeName = '/extractArguments';
  createState() => MQTTDetailState();
}

class MQTTDetailState extends State<MQTTDetail> {
  List<Widget> tableWidgets = <Widget>[];

  void updateWidgetListElements(Sensor args, BuildContext c) {
    tableWidgets = <Widget>[];

    List<Widget> topInformationList = <Widget>[
      ListTile(
        leading: const Icon(Icons.devices),
        title: Text(args.deviceName!),
        subtitle: Text('Device Name'.toUpperCase(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
      ),
      ListTile(
        leading: const Icon(Icons.textsms),
        title: Text(args.topic, style: const TextStyle(fontSize: 14.0)),
        subtitle: Text('Topic'.toUpperCase(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
      ),
      ListTile(
        leading: const Icon(Icons.developer_board),
        title: Text(args.deviceType),
        subtitle: Text('Device Type'.toUpperCase(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
      ),
      ListTile(
        leading: const Icon(Icons.wifi),
        title: Text('IP: ' + args.ip!),
        subtitle: Text('IP Address'.toUpperCase(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
      ),
      ListTile(
        leading: const Icon(Icons.cloud),
        title: Text(args.host!),
        subtitle: Text('Device Hostname'.toUpperCase(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
      ),
      ListTile(
        leading: const Icon(Icons.home),
        title: Text(args.location),
        subtitle: Text('Device Location'.toUpperCase(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
      ),
      ListTile(
        leading: const Icon(Icons.power_input),
        title: Text(args.macAddress!),
        subtitle: Text('Mac Address'.toUpperCase(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
      ),
      ListTile(
        leading: const Icon(Icons.access_time),
        title: Text(DateFormat("dd-MM-yyyy HH:mm:ss").format(args.lastMessage)),
        subtitle: Text('Last Message Sent'.toUpperCase(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
      ),
      const ListTile(
        leading: null,
        title: Text(''),
      ),
    ];

    tableWidgets = tableWidgets + topInformationList;

    Map? sensorList = args.getSensorsDataMap();
    if (sensorList != null) {
      sensorList.forEach((i, value) {
        ListTile sensorListItem = ListTile(
          leading: const Icon(Icons.arrow_forward_ios),
          title: Text(toBeginningOfSentenceCase('$value')!),
          subtitle: Text('$i'.toUpperCase(),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
        );
        tableWidgets.add(sensorListItem);
      });
    }
  }

  Sensor? args;
  var subscriber;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as Sensor?;

    // First Load
    if (args != null) {
      updateWidgetListElements(args!, context);
    }

    subscriber ??= args!.fetchDone.listen((data) {
      print("SJG: " + args!.jsonMessage!);
      if (args != null) {
        setState(() {
          updateWidgetListElements(args!, context);
        });
      }
    }, onDone: () {
      print("Listener Finished!");
    }, onError: (error) {
      print("Some Error1");
    });

    return Scaffold(
        body: ListView(
      children: tableWidgets,
    ));
  }

  @override
  void dispose() {
    if (subscriber != null) {
      subscriber.cancel();
    }

    print("MQTT Detail Closed");

    subscriber = null;
    super.dispose();
  }
}
