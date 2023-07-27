import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble_manager.dart';
import 'views/connection_view.dart';
import 'views/test_view.dart';
import 'views/alert_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BLEManager _bleManager = BLEManager();
  BluetoothDevice? _connectedDevice;
  int _currentIndex = 0;
  final GlobalKey<TestViewState> _testViewKey = GlobalKey<TestViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        titleSpacing: 0,
        title: Transform(
          transform: Matrix4.translationValues(10, 0, 0),
          child: const Text(
            'Sacha',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ConnectionView(
            bleManager: _bleManager, // Pass the BLEManager instance
            connectedDevice: _connectedDevice,
            onDeviceConnected: (BluetoothDevice? device) async {
              setState(() {
                _connectedDevice = device;
              });

              if (device != null) {
                print('Connected to ${device.name}');
                List<BluetoothService> services = await device.discoverServices();
                for (var service in services) {
                  if (service.uuid.toString() == '00001bc0-0000-1000-8000-00805f9b34fb') {
                    print('Found the correct service');
                    var characteristics = service.characteristics;
                    for (BluetoothCharacteristic c in characteristics) {
                      if (c.uuid.toString() == '00002a06-0000-1000-8000-00805f9b34fb') {
                        print('Found the correct characteristic');
                        _listenToCharacteristic(c);
                      }
                    }
                  }
                }
              }
            },
          ),
          TestView(
            key: _testViewKey,
            connectedDevice: _connectedDevice,
          ),
          AlertView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth_connected_rounded),
            label: 'Connection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alert',
          ),
        ],
      ),
    );
  }

  void _listenToCharacteristic(BluetoothCharacteristic c) {
    c.setNotifyValue(true);
    c.value.listen((value) {
      print(value);

      if (value.isNotEmpty && value[0] == 1) {
        _testViewKey.currentState?.showMessage("Alert! Something happened!");
      }
    });
  }
}
