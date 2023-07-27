import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BLEManager {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  FlutterBlue get flutterBlue => _flutterBlue;

  Future<void> startScanning() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _flutterBlue.startScan(
          timeout: const Duration(seconds: 4));
    }
  }

  Future<void> stopScanning() async {
    await _flutterBlue.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect();
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }
}
