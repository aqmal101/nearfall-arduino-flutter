import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home_screen.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final FlutterReactiveBle ble = FlutterReactiveBle();

  final List<DiscoveredDevice> devices = [];
  StreamSubscription<DiscoveredDevice>? scanSub;
  StreamSubscription<ConnectionStateUpdate>? connectionSub;

  bool isScanning = false;
  bool isConnecting = false;
  String? connectingDeviceId;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    scanSub?.cancel();
    connectionSub?.cancel();
    super.dispose();
  }

  /* ================= PERMISSION ================= */
  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
    }
  }

  /* ================= SCAN ================= */
  void startScan() async {
    if (isScanning) return;

    setState(() {
      devices.clear();
      isScanning = true;
    });

    scanSub = ble
        .scanForDevices(
          withServices: [], // bisa diisi service UUID jika mau filter
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (device) {
            // FILTER DEVICE ESP32
            if (device.name.contains("ESP32")) {
              final exists = devices.any((d) => d.id == device.id);
              if (!exists) {
                setState(() => devices.add(device));
              }
            }
          },
          onError: (e) {
            stopScan();
          },
        );
  }

  void stopScan() async {
    await scanSub?.cancel();
    scanSub = null;
    setState(() => isScanning = false);
  }

  /* ================= CONNECT ================= */
  void connectToDevice(DiscoveredDevice device) async {
    if (isConnecting) return;

    stopScan();

    setState(() {
      isConnecting = true;
      connectingDeviceId = device.id;
    });

    connectionSub = ble
        .connectToDevice(
          id: device.id,
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen(
          (state) {
            if (state.connectionState == DeviceConnectionState.connected) {
              setState(() => isConnecting = false);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(
                    ble: ble,
                    deviceId: device.id,
                    connection: connectionSub!,
                  ),
                ),
              );
            }

            if (state.connectionState == DeviceConnectionState.disconnected) {
              setState(() {
                isConnecting = false;
                connectingDeviceId = null;
              });
            }
          },
          onError: (e) {
            setState(() {
              isConnecting = false;
              connectingDeviceId = null;
            });

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Connection failed")));
          },
        );
  }

  /* ================= UI ================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect BLE Device"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: startScan,
        child: Icon(isScanning ? Icons.stop : Icons.bluetooth_searching),
      ),

      body: devices.isEmpty
          ? const Center(child: Text("No BLE device found"))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, i) {
                final d = devices[i];
                final connecting = isConnecting && connectingDeviceId == d.id;

                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(d.name.isNotEmpty ? d.name : "Unknown"),
                  subtitle: Text(d.id),
                  trailing: connecting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => connectToDevice(d),
                );
              },
            ),
    );
  }
}
