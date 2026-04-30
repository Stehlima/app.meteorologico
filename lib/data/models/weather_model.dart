import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherModel {
  final int temp;
  final String date;
  final String time;
  final String description;
  final String city;
  final int humidity;
  
  @JsonKey(name: 'wind_speedy')
  final String windSpeedy;
  
  final String sunrise;
  final String sunset;
  
  @JsonKey(name: 'condition_slug')
  final String conditionSlug;
  
  @JsonKey(name: 'currently')
  final String currentlyCondition;
  
  final List<ForecastDay> forecast;
  
  // Coordenadas para o Mapa (HG Brasil usa latitude/longitude)
  @JsonKey(name: 'latitude', defaultValue: -23.5505)
  final double lat;
  @JsonKey(name: 'longitude', defaultValue: -46.6333)
  final double lon;
  
  @JsonKey(name: 'moon_phase', defaultValue: 'Crescente')
  final String moonPhase;
  @JsonKey(name: 'surf_condition', defaultValue: 'Calmo')
  final String surfCondition;

  WeatherModel({
    required this.temp,
    required this.date,
    required this.time,
    required this.description,
    required this.city,
    required this.humidity,
    required this.windSpeedy,
    required this.sunrise,
    required this.sunset,
    required this.conditionSlug,
    required this.currentlyCondition,
    required this.forecast,
    required this.lat,
    required this.lon,
    required this.moonPhase,
    required this.surfCondition,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // A HG Brasil envelopa os resultados em um campo 'results'
    final data = json['results'] != null ? json['results'] as Map<String, dynamic> : json;
    return _$WeatherModelFromJson(data);
  }
  
  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);

  factory WeatherModel.mock({String cityName = 'São Paulo'}) {
    return WeatherModel(
      temp: 28,
      date: '29/04/2026',
      time: '12:45',
      description: 'Parcialmente nublado',
      city: cityName,
      humidity: 65,
      windSpeedy: '12 km/h',
      sunrise: '06:15',
      sunset: '17:42',
      conditionSlug: 'cloudly_day',
      currentlyCondition: 'dia',
      lat: -23.5505,
      lon: -46.6333,
      moonPhase: 'Crescente',
      surfCondition: 'Calmo - 1.2m',
      forecast: [
        ForecastDay(date: '29/04', weekday: 'Qua', max: 30, min: 19, description: 'Parcialmente nublado', condition: 'cloudly_day'),
        ForecastDay(date: '30/04', weekday: 'Qui', max: 32, min: 20, description: 'Ensolarado', condition: 'clear_day'),
        ForecastDay(date: '01/05', weekday: 'Sex', max: 28, min: 18, description: 'Chuva', condition: 'rain'),
      ],
    );
  }
}

@JsonSerializable()
class ForecastDay {
  final String date;
  final String weekday;
  final int max;
  final int min;
  final String description;
  final String condition;

  ForecastDay({
    required this.date,
    required this.weekday,
    required this.max,
    required this.min,
    required this.description,
    required this.condition,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) => _$ForecastDayFromJson(json);
  Map<String, dynamic> toJson() => _$ForecastDayToJson(this);
}
