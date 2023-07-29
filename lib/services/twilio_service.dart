import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../env.dart';

class TwilioService {
  late Env env;
   late TwilioFlutter twilio;

  TwilioService() {
    env = Env();
    twilio = TwilioFlutter(
    accountSid: env.twilio.accountSid, 
    authToken: env.twilio.authToken, 
    twilioNumber: env.twilio.twilioNumber);
  }

Future<bool> sendAlert(String to) async {
    try {
    String locationMessage = await _getCurrentLocation();
    String code = "Alerta!! peligro de seguridad, mi ubicación $locationMessage";

    await twilio.sendSMS(toNumber: to, messageBody: code);
    return true;
  } catch (e) {
    print('Error sending alert: $e');
    return false;
  }
  }

   Future<String> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return "Lat: ${position.latitude}, Long: ${position.longitude}";
  }
}