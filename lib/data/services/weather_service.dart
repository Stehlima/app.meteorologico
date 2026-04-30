import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class WeatherService {
  // Chave de exemplo (em um app real, o usuário forneceria a sua ou seria via backend)
  static const String _hgBrasilKey = '7f9c2d1b'; // Exemplo de chave

  /// Busca dados climáticos de uma fonte nacional (HG Brasil) ou internacional (Open-Meteo)
  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    try {
      // Prioridade: API Nacional HG Brasil (Etapa 2)
      final hgUri = Uri.parse(
          'https://api.hgbrasil.com/weather?key=$_hgBrasilKey&city_name=${Uri.encodeComponent(cityName)}&format=json-array');
      
      final response = await http.get(hgUri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['results'] != null) {
          return WeatherModel.fromJson(data);
        }
      }
      
      // Fallback para Open-Meteo se a API nacional falhar ou a chave expirar
      return _fetchFromOpenMeteo(cityName);
    } catch (e) {
      // Se falhar tudo, tenta o fallback
      return _fetchFromOpenMeteo(cityName);
    }
  }

  Future<WeatherModel> _fetchFromOpenMeteo(String cityName) async {
    try {
      final geoUri = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cityName)}&count=1&language=pt&format=json');
      final geoResponse = await http.get(geoUri).timeout(const Duration(seconds: 10));

      if (geoResponse.statusCode != 200) throw Exception('Erro na busca');

      final geoData = json.decode(geoResponse.body);
      final results = geoData['results'] as List?;
      if (results == null || results.isEmpty) throw Exception('Cidade não encontrada');

      final cityData = results[0];
      final lat = cityData['latitude'];
      final lon = cityData['longitude'];
      final resolvedCityName = '${cityData['name']}, ${cityData['admin1'] ?? cityData['country']}';

      final weatherUri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto');
      final weatherResponse = await http.get(weatherUri).timeout(const Duration(seconds: 10));

      if (weatherResponse.statusCode != 200) throw Exception('Erro clima');

      return _mapOpenMeteoToWeatherModel(json.decode(weatherResponse.body), resolvedCityName);
    } catch (e) {
      throw Exception('Falha na conexão com as APIs: $e');
    }
  }

  Future<WeatherModel> fetchWeatherByCoordinates(double lat, double lon) async {
    try {
      final weatherUri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto');
      final response = await http.get(weatherUri).timeout(const Duration(seconds: 10));
      return _mapOpenMeteoToWeatherModel(json.decode(response.body), 'Localização Atual');
    } catch (e) {
      throw Exception('Falha ao obter clima por localização: $e');
    }
  }

  WeatherModel _mapOpenMeteoToWeatherModel(Map<String, dynamic> data, String cityName) {
    final current = data['current'];
    final daily = data['daily'];
    final now = DateTime.now();
    
    List<ForecastDay> forecast = [];
    for (int i = 0; i < (daily['time'] as List).length; i++) {
      forecast.add(ForecastDay(
        date: daily['time'][i].toString().split('-').reversed.join('/'),
        weekday: _getWeekday(DateTime.parse(daily['time'][i]).weekday),
        max: (daily['temperature_2m_max'][i] as num).round(),
        min: (daily['temperature_2m_min'][i] as num).round(),
        description: _getDesc(daily['weather_code'][i]),
        condition: _getSlug(daily['weather_code'][i]),
      ));
    }

    return WeatherModel(
      temp: (current['temperature_2m'] as num).round(),
      date: DateFormat('dd/MM/yyyy').format(now),
      time: DateFormat('HH:mm').format(now),
      description: _getDesc(current['weather_code']),
      city: cityName,
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeedy: '${current['wind_speed_10m']} km/h',
      sunrise: daily['sunrise'][0].toString().split('T').last,
      sunset: daily['sunset'][0].toString().split('T').last,
      conditionSlug: _getSlug(current['weather_code']),
      currentlyCondition: now.hour > 6 && now.hour < 18 ? 'dia' : 'noite',
      forecast: forecast,
    );
  }

  String _getWeekday(int w) {
    return ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'][w % 7];
  }

  String _getDesc(int code) {
    if (code == 0) return 'Tempo limpo';
    if (code < 4) return 'Parcialmente nublado';
    if (code < 50) return 'Neblina';
    if (code < 70) return 'Chuva';
    return 'Nublado';
  }

  String _getSlug(int code) {
    if (code == 0) return 'clear_day';
    if (code < 4) return 'cloudly_day';
    if (code < 70) return 'rain';
    return 'cloud';
  }
}
