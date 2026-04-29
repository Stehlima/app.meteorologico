import 'package:flutter/material.dart';
import '../../data/models/weather_model.dart';
import '../../core/theme/app_theme.dart';

class ForecastList extends StatelessWidget {
  final List<ForecastDay> forecast;

  const ForecastList({super.key, required this.forecast});

  IconData _getIcon(String condition) {
    switch (condition) {
      case 'clear_day': return Icons.wb_sunny_rounded;
      case 'clear_night': return Icons.nightlight_round;
      case 'rain': return Icons.water_drop_rounded;
      case 'storm': return Icons.thunderstorm_rounded;
      case 'snow': return Icons.ac_unit_rounded;
      case 'fog': return Icons.foggy;
      default: return Icons.wb_cloudy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalhes da Previsão',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          ...forecast.map((day) => _buildDayRow(day)),
        ],
      ),
    );
  }

  Widget _buildDayRow(ForecastDay day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              day.weekday,
              style: const TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Icon(_getIcon(day.condition), color: AppTheme.lightLilac, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              day.description,
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${day.min}°',
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.55),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [AppTheme.lightLilac, AppTheme.white],
              ),
            ),
          ),
          Text(
            '${day.max}°',
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
