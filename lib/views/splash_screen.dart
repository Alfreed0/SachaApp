import 'package:flutter/material.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadMainScreen();
  }

  _loadMainScreen() async {
    await Future.delayed(Duration(seconds: 3)); 
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => MyHomePage(), 
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF88C3FF),
      body: Center(
        child: Image.asset('assets/images/sacha-log.png'), 
      ),
    );
  }
}
