import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ExternalApiService {

  Future<bool> sendAlertToExternalApi(String apiUrl) async {
    String locationMessage = await _getCurrentLocation();
    String code = "Alerta!! Peligro de seguridad, mi ubicación:";

    return await _sendAlertToApi(apiUrl, code, locationMessage); 
  }

  Future<String> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    //return "Lat: ${position.latitude}, Long: ${position.longitude}";
    return "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}"
  }

  Future<bool> _sendAlertToApi(String apiUrl, String message, String location) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: '{"message": "$message", "location": "$location"}',
      );

      if (response.statusCode == 200) {
        print('Alert sent to external API successfully.');
        return true; 
      } else {
        print('Error sending alert to external API. Status code: ${response.statusCode}');
        return false; 
      }
    } catch (e) {
      print('Error sending alert to external API: $e');
      return false; 
    }
  }
}