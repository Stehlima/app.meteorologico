import 'package:flutter_test/flutter_test.dart';
import 'package:climabrasil/data/models/weather_model.dart';

void main() {
  group('WeatherModel Tests', () {
    test('Should create mock WeatherModel correctly', () {
      final model = WeatherModel.mock(cityName: 'São Paulo');
      
      expect(model.city, 'São Paulo');
      expect(model.temp, 28);
      expect(model.forecast.length, 7);
      expect(model.moonPhase, 'Crescente');
    });

    test('Should parse JSON correctly using manual factory', () {
      final json = {
        'results': {
          'temp': 25,
          'date': '30/04/2026',
          'time': '10:00',
          'description': 'Ensolarado',
          'city': 'Rio de Janeiro',
          'humidity': 60,
          'wind_speedy': '10 km/h',
          'sunrise': '06:00',
          'sunset': '18:00',
          'condition_slug': 'clear_day',
          'currently': 'dia',
          'forecast': [
            {
              'date': '30/04',
              'weekday': 'Qui',
              'max': 30,
              'min': 20,
              'description': 'Ensolarado',
              'condition': 'clear_day'
            }
          ]
        }
      };

      final model = WeatherModel.fromJson(json);

      expect(model.city, 'Rio de Janeiro');
      expect(model.temp, 25);
      expect(model.forecast[0].max, 30);
    });
  });
}
