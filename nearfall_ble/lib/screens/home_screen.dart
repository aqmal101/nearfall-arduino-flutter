import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HomePage extends StatefulWidget {
  final FlutterReactiveBle ble;
  final String deviceId;
  final StreamSubscription<ConnectionStateUpdate> connection;

  const HomePage({
    super.key,
    required this.ble,
    required this.deviceId,
    required this.connection,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<List<int>>? dataSub;
  StreamSubscription<BleStatus>? connectionStateSub;
  String latestData = "-";
  bool isConnected = true;
  int dataCount = 0;
  DateTime? lastUpdateTime;

  // Parsed sensor data
  Map<String, double> sensorData = {
    'ax': 0.0,
    'ay': 0.0,
    'az': 0.0,
    'gx': 0.0,
    'gy': 0.0,
    'gz': 0.0,
    'accMag': 0.0,
    'altitude': 0.0,
  };

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Keep screen awake
    subscribeData();
    monitorConnection();
  }

  void monitorConnection() {
    connectionStateSub = widget.ble.statusStream.listen((status) {
      setState(() {
        isConnected = status == BleStatus.ready;
      });
    });
  }

  void subscribeData() async {
    final services = await widget.ble.discoverServices(widget.deviceId);

    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.isNotifiable) {
          final qualified = QualifiedCharacteristic(
            serviceId: s.serviceId,
            characteristicId: c.characteristicId,
            deviceId: widget.deviceId,
          );
          dataSub = widget.ble.subscribeToCharacteristic(qualified).listen((
            data,
          ) {
            setState(() {
              latestData = utf8.decode(data);
              lastUpdateTime = DateTime.now();
              dataCount++;

              // Parse CSV data: ax,ay,az,gx,gy,gz,accMag,altitude
              try {
                final values = latestData.split(',');
                if (values.length >= 8) {
                  sensorData['ax'] = double.tryParse(values[0]) ?? 0.0;
                  sensorData['ay'] = double.tryParse(values[1]) ?? 0.0;
                  sensorData['az'] = double.tryParse(values[2]) ?? 0.0;
                  sensorData['gx'] = double.tryParse(values[3]) ?? 0.0;
                  sensorData['gy'] = double.tryParse(values[4]) ?? 0.0;
                  sensorData['gz'] = double.tryParse(values[5]) ?? 0.0;
                  sensorData['accMag'] = double.tryParse(values[6]) ?? 0.0;
                  sensorData['altitude'] = double.tryParse(values[7]) ?? 0.0;
                }
              } catch (e) {
                // Handle parsing errors
              }
            });
          });
        }
      }
    }
  }

  void disconnect() async {
    await WakelockPlus.disable();
    await dataSub?.cancel();
    await connectionStateSub?.cancel();
    await widget.connection.cancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    dataSub?.cancel();
    connectionStateSub?.cancel();
    widget.connection.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fall Risk Monitoring"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Disconnect Device?'),
                  content: const Text(
                    'Do you want to disconnect from the BLE device?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        disconnect();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Card(
              color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      size: 48,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Device: ${widget.deviceId.substring(0, 17)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Data Received:'),
                        Text(
                          '$dataCount packets',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Last Update:'),
                        Text(
                          lastUpdateTime != null
                              ? '${lastUpdateTime!.hour}:${lastUpdateTime!.minute.toString().padLeft(2, '0')}:${lastUpdateTime!.second.toString().padLeft(2, '0')}'
                              : '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Accelerometer Data Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Accelerometer (m/s²)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildSensorRow('X-axis', sensorData['ax']!, Colors.red),
                    _buildSensorRow('Y-axis', sensorData['ay']!, Colors.green),
                    _buildSensorRow('Z-axis', sensorData['az']!, Colors.blue),
                    const SizedBox(height: 8),
                    _buildSensorRow(
                      'Magnitude',
                      sensorData['accMag']!,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gyroscope Data Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.rotate_right, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Gyroscope (°/s)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildSensorRow('X-axis', sensorData['gx']!, Colors.red),
                    _buildSensorRow('Y-axis', sensorData['gy']!, Colors.green),
                    _buildSensorRow('Z-axis', sensorData['gz']!, Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Altitude Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.terrain, color: Colors.brown.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Altitude',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Center(
                      child: Text(
                        '${sensorData['altitude']!.toStringAsFixed(2)} m',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Raw Data Card
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Raw Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        latestData,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            value.toStringAsFixed(3),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
