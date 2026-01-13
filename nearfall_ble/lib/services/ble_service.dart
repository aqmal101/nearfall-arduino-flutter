import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../core/ble_constants.dart';
import '../models/gait_data.dart';

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  String? _deviceId;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  QualifiedCharacteristic? _characteristic;

  Stream<GaitData> startStream() async* {
    _deviceId = await _findDevice();

    // Connect to device
    await _connectToDevice(_deviceId!);

    // Discover services and characteristics
    await _discoverServices();

    final characteristic = _characteristic;
    if (characteristic == null) {
      throw StateError('BLE characteristic not found.');
    }

    // Subscribe to characteristic notifications
    yield* _ble.subscribeToCharacteristic(characteristic).map((data) {
      final raw = utf8.decode(data);
      return GaitData.fromCsv(raw);
    });
  }

  Future<String> _findDevice() async {
    final completer = Completer<String>();

    final scanSubscription = _ble
        .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
        .listen((device) {
          if (device.name == DEVICE_NAME) {
            completer.complete(device.id);
          }
        });

    // Timeout after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('BLE device $DEVICE_NAME not found.'),
        );
      }
    });

    final deviceId = await completer.future;
    await scanSubscription.cancel();
    return deviceId;
  }

  Future<void> _connectToDevice(String deviceId) async {
    final completer = Completer<void>();

    _connection = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen((state) {
          if (state.connectionState == DeviceConnectionState.connected) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          } else if (state.connectionState ==
              DeviceConnectionState.disconnected) {
            if (!completer.isCompleted) {
              completer.completeError(
                StateError('Failed to connect to device'),
              );
            }
          }
        });

    await completer.future;
  }

  Future<void> _discoverServices() async {
    final services = await _ble.discoverServices(_deviceId!);

    for (var s in services) {
      if (s.serviceId.toString() == SERVICE_UUID) {
        for (var c in s.characteristics) {
          if (c.characteristicId.toString() == CHARACTERISTIC_UUID) {
            _characteristic = QualifiedCharacteristic(
              serviceId: s.serviceId,
              characteristicId: c.characteristicId,
              deviceId: _deviceId!,
            );
            return;
          }
        }
      }
    }
  }

  void dispose() {
    _connection?.cancel();
  }
}
