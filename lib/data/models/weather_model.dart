class WeatherModel {
  final int temp;
  final String date;
  final String time;
  final String description;
  final String city;
  final int humidity;
  final String windSpeedy;
  final String sunrise;
  final String sunset;
  final String conditionSlug;
  final String currentlyCondition;
  final List<ForecastDay> forecast;

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
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>;
    final forecastList = (results['forecast'] as List)
        .map((item) => ForecastDay.fromJson(item as Map<String, dynamic>))
        .toList();

    return WeatherModel(
      temp: results['temp'] as int,
      date: results['date'] as String,
      time: results['time'] as String,
      description: results['description'] as String,
      city: results['city'] as String? ?? 'Desconhecida',
      humidity: results['humidity'] as int,
      windSpeedy: results['wind_speedy'] as String,
      sunrise: results['sunrise'] as String,
      sunset: results['sunset'] as String,
      conditionSlug: results['condition_slug'] as String? ?? '',
      currentlyCondition: results['currently'] as String? ?? 'dia',
      forecast: forecastList,
    );
  }

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

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'] as String,
      weekday: json['weekday'] as String,
      max: json['max'] as int,
      min: json['min'] as int,
      description: json['description'] as String,
      condition: json['condition'] as String,
    );
  }
}
