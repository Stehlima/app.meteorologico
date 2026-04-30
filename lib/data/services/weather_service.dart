import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _hgBrasilKey = '7f9c2d1b';

  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    try {
      final hgUri = Uri.parse(
          'https://api.hgbrasil.com/weather?key=$_hgBrasilKey&city_name=${Uri.encodeComponent(cityName)}&format=json-array');
      
      final response = await http.get(hgUri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['results'] != null) {
          // A HG Brasil já retorna lat/lon no campo results
          return WeatherModel.fromJson(data);
        }
      }
      return _fetchFromOpenMeteo(cityName);
    } catch (e) {
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
      final lat = cityData['latitude'] as double;
      final lon = cityData['longitude'] as double;
      final resolvedCityName = '${cityData['name']}, ${cityData['admin1'] ?? cityData['country']}';

      final weatherUri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto');
      final weatherResponse = await http.get(weatherUri).timeout(const Duration(seconds: 10));

      if (weatherResponse.statusCode != 200) throw Exception('Erro clima');

      return _mapOpenMeteoToWeatherModel(json.decode(weatherResponse.body), resolvedCityName, lat, lon);
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }

  WeatherModel _mapOpenMeteoToWeatherModel(Map<String, dynamic> data, String cityName, double lat, double lon) {
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
      lat: lat,
      lon: lon,
      forecast: forecast,
    );
  }

  String _getWeekday(int w) => ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'][w % 7];
  String _getDesc(int code) => code == 0 ? 'Tempo limpo' : (code < 4 ? 'Nublado' : 'Chuva');
  String _getSlug(int code) => code == 0 ? 'clear_day' : (code < 4 ? 'cloud' : 'rain');
}
