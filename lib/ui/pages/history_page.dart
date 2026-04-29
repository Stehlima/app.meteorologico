import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/database_service.dart';
import '../../data/providers/weather_provider.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico de Buscas',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Dados salvos no Supabase',
                          style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Consumer<WeatherProvider>(
                  builder: (context, provider, _) {
                    if (provider.dbHistoryLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2),
                      );
                    }

                    if (provider.dbHistory.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded,
                                color: AppTheme.white.withValues(alpha: 0.3), size: 72),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum registro no banco de dados ainda.\nBusque uma cidade para começar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.white.withValues(alpha: 0.6),
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      itemCount: provider.dbHistory.length,
                      itemBuilder: (context, index) {
                        final record = provider.dbHistory[index];
                        return _buildHistoryCard(record, context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(WeatherRecord record, BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(record.queriedAt.toLocal());

    return GestureDetector(
      onTap: () {
        context.read<WeatherProvider>().searchCity(record.city);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            // Temperatura
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: Center(
                child: Text(
                  '${record.temp}°',
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.city,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.description,
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.water_drop_outlined,
                          size: 11, color: AppTheme.white.withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(
                        '${record.humidity}%',
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.air_rounded,
                          size: 11, color: AppTheme.white.withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(
                        record.windSpeedy,
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Data
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.chevron_right_rounded,
                    color: AppTheme.white.withValues(alpha: 0.4), size: 20),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
