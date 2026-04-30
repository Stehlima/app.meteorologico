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
  
  // Novos campos para Etapa 11
  @JsonKey(defaultValue: 'Crescente')
  final String moonPhase;
  @JsonKey(defaultValue: 'Calmo')
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
    this.moonPhase = 'Crescente',
    this.surfCondition = 'Calmo',
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) => _$WeatherModelFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);

  /// Dados simulados para demonstração
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
      moonPhase: 'Crescente',
      surfCondition: 'Calmo - 1.2m',
      forecast: [
        ForecastDay(date: '29/04', weekday: 'Qua', max: 30, min: 19, description: 'Parcialmente nublado', condition: 'cloudly_day'),
        ForecastDay(date: '30/04', weekday: 'Qui', max: 32, min: 20, description: 'Ensolarado', condition: 'clear_day'),
        ForecastDay(date: '01/05', weekday: 'Sex', max: 28, min: 18, description: 'Chuva', condition: 'rain'),
        ForecastDay(date: '02/05', weekday: 'Sáb', max: 25, min: 17, description: 'Tempestade', condition: 'storm'),
        ForecastDay(date: '03/05', weekday: 'Dom', max: 27, min: 19, description: 'Nublado', condition: 'cloud'),
        ForecastDay(date: '04/05', weekday: 'Seg', max: 29, min: 20, description: 'Ensolarado', condition: 'clear_day'),
        ForecastDay(date: '05/05', weekday: 'Ter', max: 31, min: 21, description: 'Parcialmente nublado', condition: 'cloudly_day'),
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

// Implementação manual dos métodos gerados (já que não podemos rodar o build_runner aqui agora)
WeatherModel _$WeatherModelFromJson(Map<String, dynamic> json) {
  final results = json['results'] != null ? json['results'] as Map<String, dynamic> : json;
  return WeatherModel(
    temp: (results['temp'] as num).toInt(),
    date: results['date'] as String,
    time: results['time'] as String,
    description: results['description'] as String,
    city: results['city'] as String? ?? 'Desconhecida',
    humidity: (results['humidity'] as num).toInt(),
    windSpeedy: results['wind_speedy'] as String,
    sunrise: results['sunrise'] as String,
    sunset: results['sunset'] as String,
    conditionSlug: results['condition_slug'] as String? ?? '',
    currentlyCondition: results['currently'] as String? ?? 'dia',
    moonPhase: results['moon_phase'] as String? ?? 'Crescente',
    surfCondition: results['surf_condition'] as String? ?? 'Calmo',
    forecast: (results['forecast'] as List<dynamic>)
        .map((e) => ForecastDay.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$WeatherModelToJson(WeatherModel instance) => <String, dynamic>{
      'temp': instance.temp,
      'date': instance.date,
      'time': instance.time,
      'description': instance.description,
      'city': instance.city,
      'humidity': instance.humidity,
      'wind_speedy': instance.windSpeedy,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
      'condition_slug': instance.conditionSlug,
      'currently': instance.currentlyCondition,
      'forecast': instance.forecast,
      'moon_phase': instance.moonPhase,
      'surf_condition': instance.surfCondition,
    };

ForecastDay _$ForecastDayFromJson(Map<String, dynamic> json) => ForecastDay(
      date: json['date'] as String,
      weekday: json['weekday'] as String,
      max: (json['max'] as num).toInt(),
      min: (json['min'] as num).toInt(),
      description: json['description'] as String,
      condition: json['condition'] as String,
    );

Map<String, dynamic> _$ForecastDayToJson(ForecastDay instance) => <String, dynamic>{
      'date': instance.date,
      'weekday': instance.weekday,
      'max': instance.max,
      'min': instance.min,
      'description': instance.description,
      'condition': instance.condition,
    };
