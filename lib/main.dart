import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raspberry Pi Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _data = 'No data';
  late MqttServerClient _mqttClient;

  void _setupMqtt() async {
    _mqttClient = MqttServerClient('raspberry_pi_ip_address', 'flutter-client');
    _mqttClient.port = 1883;

    try {
      await _mqttClient.connect();
      _mqttClient.subscribe('topic', MqttQos.atLeastOnce);
      _mqttClient.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        setState(() {
          _data = payload;
        });
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _setupMqtt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raspberry Pi Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Data from Raspberry Pi:',
            ),
            Text(
              _data,
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
