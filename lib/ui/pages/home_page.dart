import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_chart.dart';
import '../widgets/forecast_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _showSuggestions = false;

  final List<String> _popularCities = [
    'São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador',
    'Fortaleza', 'Belo Horizonte', 'Manaus', 'Curitiba',
    'Recife', 'Porto Alegre', 'Belém', 'Florianópolis',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().searchCity('São Paulo');
    });
    _searchFocus.addListener(() {
      setState(() => _showSuggestions = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _search(String city) {
    _searchFocus.unfocus();
    _searchController.clear();
    setState(() => _showSuggestions = false);
    context.read<WeatherProvider>().searchCity(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _searchFocus.unfocus();
                    setState(() => _showSuggestions = false);
                  },
                  child: Consumer<WeatherProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2),
                              SizedBox(height: 16),
                              Text(
                                'Buscando dados climáticos...',
                                style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.status.name == 'error') {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_off_rounded, color: AppTheme.white.withValues(alpha: 0.5), size: 64),
                                const SizedBox(height: 16),
                                Text(
                                  provider.errorMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: provider.refreshCurrent,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Tentar novamente'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.glassWhite,
                                    foregroundColor: AppTheme.white,
                                    side: const BorderSide(color: AppTheme.glassBorder),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!provider.hasData) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: provider.refreshCurrent,
                        color: AppTheme.white,
                        backgroundColor: AppTheme.oceanBlue,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                          child: Column(
                            children: [
                              WeatherCard(weather: provider.weather!),
                              const SizedBox(height: 20),
                              ForecastChart(forecast: provider.weather!.forecast),
                              const SizedBox(height: 20),
                              ForecastList(forecast: provider.weather!.forecast),
                              const SizedBox(height: 20),
                              _buildDemoNotice(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          // Logo + título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: const Icon(Icons.cloud_done_rounded, color: AppTheme.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ClimaBrasil',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Monitoramento Meteorológico Nacional',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Campo de busca
          Stack(
            children: [
              TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: const TextStyle(color: AppTheme.white),
                decoration: InputDecoration(
                  hintText: 'Buscar cidade brasileira...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.white),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppTheme.white),
                          onPressed: () => _search(_searchController.text),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (v) {
                  if (v.isNotEmpty) _search(v);
                },
              ),
              if (_showSuggestions)
                Positioned(
                  top: 56,
                  left: 0,
                  right: 0,
                  child: _buildSuggestions(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final query = _searchController.text.toLowerCase();
    final filtered = query.isEmpty
        ? _popularCities
        : _popularCities.where((c) => c.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) return const SizedBox();

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: AppTheme.deepOcean.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => Divider(
          color: AppTheme.glassBorder,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.location_city_rounded, color: AppTheme.skyBlue, size: 18),
          title: Text(
            filtered[i],
            style: const TextStyle(color: AppTheme.white, fontSize: 14),
          ),
          dense: true,
          onTap: () => _search(filtered[i]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore_rounded, color: AppTheme.white.withValues(alpha: 0.4), size: 80),
          const SizedBox(height: 16),
          Text(
            'Pesquise uma cidade brasileira',
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.iceBlue, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo demonstração ativo. Configure sua chave HG Brasil em weather_service.dart para dados reais.',
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.65),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
