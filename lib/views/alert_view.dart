import 'package:flutter/material.dart';

class AlertView extends StatelessWidget {
  const AlertView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Alertas dispositivo Sacha",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}