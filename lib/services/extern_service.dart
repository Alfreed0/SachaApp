import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ExternalApiService {
  
  String token = "23dc8f89b9bc7d616ec410433a088385bf41b15cf0febf2fdbf83f1519f619b5";
  Future<bool> sendAlertToExternalApi(String apiUrl) async {
    String locationMessage = await _getCurrentLocation();
    String code = "Alerta!! Estoy en peligro, mi ubicación:";

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
        print('Alerta enviada éxitosamente a API externa.');
        return true; 
      } else {
        print('Error al enviar alerta a API externa. Status code: ${response.statusCode}');
        return false; 
      }
    } catch (e) {
      print('Error al enviar alerta a API externa: $e');
      return false; 
    }
  }
}