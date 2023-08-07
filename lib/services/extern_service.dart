import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ExternalApiService {
  
  String token = "23dc8f89b9bc7d616ec410433a088385bf41b15cf0febf2fdbf83f1519f619b5";
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
    return "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
  }

  Future<bool> _sendAlertToApi(String apiUrl, String message, String location) async {
    print("ENVIANDO ALERTA 2, ANTES DEL POST");
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'x-api-key': token,
          'Content-Type': 'application/json',
        },
        body: '{"mensaje": "$message", "ubicacion": "$location"}',
      );

      if (response.statusCode == 200) {
        print(response);
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