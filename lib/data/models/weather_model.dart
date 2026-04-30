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
