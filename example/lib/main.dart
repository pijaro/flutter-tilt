import 'package:flutter/material.dart';
import 'package:tilt/tilt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: StreamBuilder<Tilt>(
            stream: DeviceTilt(
              samplingRateMs: 20,
              initialTilt: const Tilt(0, 0),
              filterGain: 0.1,
            ).stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Text(snapshot.data!.toString());
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
