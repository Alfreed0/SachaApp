import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
    Twilio twilio = Twilio(
    accountSid: dotenv.env['TWILIO_accountSid']!,
    authToken: dotenv.env['TWILIO_authToken']!,
    twilioNumber: dotenv.env['TWILIO_twilioNumber']!,
  );
}

class Twilio {
  final String accountSid;
  final String authToken;
  final String twilioNumber;

  Twilio({
     required this.accountSid, 
     required this.authToken, 
     required this.twilioNumber,
  });
}