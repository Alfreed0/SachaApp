import 'dart:typed_data';

import 'package:ble_connection/services/extern_service.dart';
import 'package:ble_connection/views/alert_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ble_manager.dart';
import 'views/connection_view.dart';
import 'views/test_view.dart';
import 'dart:async';
 import 'dart:io';

Future main() async {
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

 class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
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
  //final TwilioService twilioService  = TwilioService();
  final ExternalApiService externalApiService = ExternalApiService();

  //PRUEBAS
   int _signalCount = 0;
  Timer? _timer;
  bool _isAlertSent = false;


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
          const AlertView(),
        /*  ElevatedButton(
            onPressed: () {
              int receivedSignal = 1;
              _listenToCharacteristic(receivedSignal);
            },
            child: Text('Enviar Señal'),
          ),*/
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


  /*void _listenToCharacteristic(BluetoothCharacteristic c) {
    c.setNotifyValue(true);
    c.value.listen((value) {
      print(value);

      if (value.isNotEmpty && value[0] == 1) {
        setState(() {
          _signalCount++;
        });

        _timer?.cancel();
        _timer = Timer(Duration(seconds: 30), () { 
            setState(() {
              _signalCount = 0;
            });
        }); 

        if(_signalCount == 2){
          _sendAlert();
        }
        
      }
    });
  }*/
void _listenToCharacteristic(BluetoothCharacteristic c){
    c.setNotifyValue(true);
    c.value.listen((value) {
    print("Esto manda la placa");
   if (value.isNotEmpty && value[0] == 1) {
    print("signal count ");
    print(_signalCount);
      if(_isAlertSent){
        _signalCount = 0;
        _isAlertSent = false;
      }
      _timer?.cancel();
      _signalCount++;
      _timer = Timer(Duration(seconds: 15), () {
        setState(() {
          _signalCount = 0;
        });
      });

      if (_signalCount == 2) {
        _sendAlert();
        _signalCount = 0;
        _isAlertSent = true;
      }
    }
    });
}
/*void _listenToCharacteristic(int receivedSignal){
   if (receivedSignal == 1) {
      print(_signalCount);
      if(_isAlertSent){
        _signalCount = 0;
        _isAlertSent = false;
      }
      // Incrementamos el contador
      _signalCount++;

      // Cancelamos el temporizador si ya estaba corriendo
      _timer?.cancel();

      // Iniciamos un nuevo temporizador de 30 segundos
      _timer = Timer(Duration(seconds: 15), () {
        // Cuando el temporizador expire, reiniciamos el contador
        setState(() {
          _signalCount = 0;
          _isAlertSent = true;
        });
      });

      // Si el contador llega a 2, enviamos la alerta
      if (_signalCount == 2) {
        _sendAlert();
        _signalCount = 0;
        _isAlertSent = true;
      }
    }
}*/
    Future<void> _sendAlert() async {
      print("ENVIANDO ALERTA...");
      bool apiCallSuccess = (await externalApiService.sendAlertToExternalApi("https://200.10.147.201:5025/api/BotonPanic"));
      if (apiCallSuccess){  
         showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final alertDialog = AlertDialog(
                        title: Text('Alerta'),
                        content: Text('¡Alerta enviada! Something happened!'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cerrar'),
                          ),
                        ],
                      );

                      Timer(Duration(seconds: 5), () {
                        Navigator.of(context).pop();
                      });

                      return alertDialog;
                      },
        );
      }else{
        print('Failed to send alert to either Twilio or the external API.');
      }
  }
}
