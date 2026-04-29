import 'package:flutter/material.dart';
import '../../data/models/weather_model.dart';
import '../../core/theme/app_theme.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'clear_day':
        return Icons.wb_sunny_rounded;
      case 'clear_night':
        return Icons.nightlight_round;
      case 'cloud':
      case 'cloudly_day':
      case 'cloudly_night':
        return Icons.wb_cloudy_rounded;
      case 'rain':
        return Icons.water_drop_rounded;
      case 'storm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.glassBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cidade + data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.city,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weather.date}  •  ${weather.time}',
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Icon(
                  _getWeatherIcon(weather.conditionSlug),
                  color: AppTheme.white,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Temperatura principal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temp}',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 88,
                  fontWeight: FontWeight.w200,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  '°C',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            weather.description.toUpperCase(),
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.8),
              fontSize: 14,
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            color: AppTheme.glassBorder,
          ),

          const SizedBox(height: 20),

          // Linha info: nascer/pôr do sol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoItem(Icons.wb_twilight_rounded, weather.sunrise, 'Nascer'),
              _verticalDivider(),
              _infoItem(Icons.nights_stay_rounded, weather.sunset, 'Pôr do sol'),
              _verticalDivider(),
              _infoItem(Icons.water_drop_outlined, '${weather.humidity}%', 'Umidade'),
              _verticalDivider(),
              _infoItem(Icons.air_rounded, weather.windSpeedy, 'Vento'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.white.withValues(alpha: 0.7), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.55),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.glassBorder,
    );
  }
}
