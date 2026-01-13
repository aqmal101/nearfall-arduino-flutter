import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/connect_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request to ignore battery optimization for better background performance
  await Permission.ignoreBatteryOptimizations.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fall Risk Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ConnectPage(),
    );
  }
}
