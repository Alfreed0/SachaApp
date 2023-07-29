import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class TestView extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  const TestView({Key? key, required this.connectedDevice}) : super(key: key);

  @override
  TestViewState createState() => TestViewState();
}

class TestViewState extends State<TestView> {
  String _message = 'Test your Sacha device';

  @override
  Widget build(BuildContext context) {
    return widget.connectedDevice == null ? const Center(
      child: Text(
        'No active connection',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ) : Center(
      child: Text(
        _message,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  void showMessage(String message) {
    setState(() {
      _message = message;
    });

    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (mounted) {
        setState(() {
          _message = 'Test your Sacha device';
        });
      }
    });
  }
}


