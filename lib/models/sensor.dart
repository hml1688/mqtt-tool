import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:convert';

class Sensor {
  String topic;

  String? deviceName;
  String? macAddress;
  late String deviceType;
  late String location;
  String? ip;
  String? host;
  late DateTime lastMessage;
  String? jsonMessage;

  StreamController fetchDoneController = StreamController.broadcast();
  Stream get fetchDone => fetchDoneController.stream;

  Sensor(String passedTopic) : topic = passedTopic {
    topic = passedTopic;
    parseTopic(topic);
  }

  void parseTopic(String topicID) {
    List<String> s = p.split(topicID);
    ip = "";
    host = "";
    deviceName = "";
    macAddress = "";
    deviceType = "";
    location = "";
    jsonMessage = "{}";
    lastMessage = DateTime.now();
  }

  void updateLastMessage() {
    lastMessage = DateTime.now();
  }

  void updateLastMessageJSON(String jsonString) {
    jsonMessage = jsonString;
    if (!fetchDoneController.isClosed) {
      fetchDoneController.add("all done");
    }
  }

  void createStream() {
    fetchDoneController = StreamController.broadcast();
  }

  Map? getSensorsDataMap() {
    if (jsonMessage != null) {
      Map decodedJSON = jsonDecode(jsonMessage!);

      decodedJSON.removeWhere((key, value) => key == "mac");
      decodedJSON.removeWhere((key, value) => key == "ip");
      decodedJSON.removeWhere((key, value) => key == "host");
      decodedJSON.removeWhere((key, value) => key == "id");
      decodedJSON.removeWhere((key, value) => key == "time");

      return decodedJSON;
    } else {
      return null;
    }
  }
}
