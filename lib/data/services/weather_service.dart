import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.hgbrasil.com/weather';
  // Coloque sua chave da HG Brasil aqui. Obtenha em: https://hgbrasil.com/status/weather
  static const String _apiKey = 'SUA_CHAVE_AQUI';

  /// Verifica se a API key foi configurada
  bool get hasApiKey => _apiKey != 'SUA_CHAVE_AQUI' && _apiKey.isNotEmpty;

  /// Busca dados climáticos por nome da cidade
  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    if (!hasApiKey) {
      // Retorna dados simulados caso a chave não esteja configurada
      return WeatherModel.mock(cityName: cityName);
    }

    try {
      final uri = Uri.parse('$_baseUrl?key=$_apiKey&city_name=$cityName');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (jsonData['results'] != null) {
          return WeatherModel.fromJson(jsonData);
        }
        throw Exception('Dados inválidos recebidos da API.');
      } else {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na conexão com a API: $e');
    }
  }

  /// Busca dados climáticos por coordenadas geográficas
  Future<WeatherModel> fetchWeatherByCoordinates(double lat, double lon) async {
    if (!hasApiKey) {
      return WeatherModel.mock(cityName: 'Localização Atual');
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl?key=$_apiKey&lat=$lat&lon=$lon&user_ip=remote',
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao obter clima por localização: $e');
    }
  }
}
