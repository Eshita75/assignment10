import 'package:flutter/material.dart';
import 'real_time_location_tracker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RealTimeLocationTracker(),
    );
  }
}
