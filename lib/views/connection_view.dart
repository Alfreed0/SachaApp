import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../ble_manager.dart';
import 'dart:async';

class ConnectionView extends StatefulWidget {
  final BLEManager bleManager;
  final void Function(BluetoothDevice?) onDeviceConnected;
  final BluetoothDevice? connectedDevice;

  const ConnectionView({
    required this.bleManager,
    required this.onDeviceConnected,
    required this.connectedDevice,
  });

  @override
  _ConnectionViewState createState() => _ConnectionViewState();
}

class _ConnectionViewState extends State<ConnectionView> {
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  void startScanning() {
    widget.bleManager.startScanning();
    _scanSubscription =
        widget.bleManager.flutterBlue.isScanning.listen((isScanning) {
      if (!isScanning) {
        widget.bleManager.startScanning();
      }
    });
  }

  @override
  void dispose() {
    widget.bleManager.stopScanning();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDevice> filteredDevices = [];
    return StreamBuilder<List<ScanResult>>(
      stream: widget.bleManager.flutterBlue.scanResults,
      initialData: [],
      builder: (context, snapshot) {
        final scanResults = snapshot.data!;
        filteredDevices = scanResults
            .map((scanResult) => scanResult.device)
            .where((device) => device.name.isNotEmpty)
            .toList();

        if (widget.connectedDevice != null) {
          return Center(
            child: Container(
              height: 400,
              width: 400,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ListTile(
                      title: Center(child: Text('Connected to ${widget.connectedDevice!.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),)
                    ),
                    Image.asset('assets/images/device.png', height: 150),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black87,
                        onPrimary: Colors.white,
                        fixedSize: const Size(200, 50),
                      ),
                      onPressed: () async {
                        await widget.bleManager.disconnect(widget.connectedDevice!);
                        widget.onDeviceConnected(null);
                      },
                      child: const Text('Disconnect'),
                    ),
                  ]
                )
              ),
            ),
          );
        } else if (filteredDevices.isEmpty) {
          return const Center(
            child: Text('No devices available', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
          );
        } else {
          return ListView.builder(
            itemCount: filteredDevices.length,
            itemBuilder: (context, index) {
              final device = filteredDevices[index];
              return Card(
                margin: const EdgeInsets.all(40),
                color: Colors.black87,
                elevation: 2,
                child: ListTile(
                  title: Center(child: Text(device.name, style: const TextStyle(color: Colors.white),)),
                  //subtitle: Text(device.id.toString()),
                  onTap: () async {
                    await widget.bleManager.stopScanning();
                    await widget.bleManager.connect(device);
                    widget.onDeviceConnected(device);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
