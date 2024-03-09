import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  static const routeName = '/extractArguments';

  @override
  Widget build(BuildContext context) {
    List<Widget> tableWidgets = <Widget>[];

    List<Widget> topInformationList = <Widget>[
      const ListTile(
        leading: Icon(Icons.devices),
        title: Text('Name: '),
      ),
      const ListTile(
        leading: Icon(Icons.developer_board),
        title: Text('Type: '),
      ),
      const ListTile(
        leading: Icon(Icons.wifi),
        title: Text('IP: '),
      ),
      const ListTile(
        leading: Icon(Icons.cloud),
        title: Text('Host: '),
      ),
      const ListTile(
        leading: Icon(Icons.home),
        title: Text('Location: '),
      ),
      const ListTile(
        leading: Icon(Icons.power_input),
        title: Text('Mac Address: '),
      ),
      const ListTile(
        leading: Icon(Icons.access_time),
        title: Text('Last Message: '),
      ),
      const ListTile(
        leading: null,
        title: Text(''),
      ),
    ];

    tableWidgets = tableWidgets + topInformationList;

    return Scaffold(
        body: ListView(
      children: tableWidgets,
    ));
  }
}
