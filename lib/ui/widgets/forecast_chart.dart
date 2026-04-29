import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/weather_model.dart';
import '../../core/theme/app_theme.dart';

class ForecastChart extends StatelessWidget {
  final List<ForecastDay> forecast;

  const ForecastChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final maxTemp = forecast.map((f) => f.max).reduce((a, b) => a > b ? a : b).toDouble();
    final minTemp = forecast.map((f) => f.min).reduce((a, b) => a < b ? a : b).toDouble();
    final padding = 5.0;

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
            'Previsão para os Próximos Dias',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minTemp - padding,
                maxY: maxTemp + padding,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.glassBorder,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= forecast.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            forecast[idx].weekday,
                            style: TextStyle(
                              color: AppTheme.white.withValues(alpha: 0.65),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}°',
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.55),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.oceanBlue,
                    getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                      final isMax = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${spot.y.toInt()}°C\n',
                        const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 13),
                        children: [
                          TextSpan(
                            text: isMax ? 'máx' : 'mín',
                            style: TextStyle(
                              color: AppTheme.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  // Linha máximas
                  LineChartBarData(
                    spots: forecast.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.max.toDouble()))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.white,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.white,
                        strokeColor: AppTheme.oceanBlue,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.white.withValues(alpha: 0.15),
                          AppTheme.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // Linha mínimas
                  LineChartBarData(
                    spots: forecast.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.min.toDouble()))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.iceBlue.withValues(alpha: 0.7),
                    barWidth: 2,
                    dashArray: [6, 4],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 3,
                        color: AppTheme.iceBlue,
                        strokeColor: AppTheme.oceanBlue,
                        strokeWidth: 1.5,
                      ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(AppTheme.white, '— Máxima'),
              const SizedBox(width: 24),
              _legendItem(AppTheme.iceBlue.withValues(alpha: 0.85), '- - Mínima'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.65),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
