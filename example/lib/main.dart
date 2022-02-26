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
          child: StreamBuilder<Rotation>(
            stream: Tilt().stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final rotation = snapshot.data!;
                return Text(rotation.toString());
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
