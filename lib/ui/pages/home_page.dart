import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/weather_model.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_chart.dart';
import '../widgets/forecast_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                              _buildActionButtons(provider.weather!),
                              const SizedBox(height: 20),
                              ForecastChart(forecast: provider.weather!.forecast),
                              const SizedBox(height: 20),
                              ForecastList(forecast: provider.weather!.forecast),
                              const SizedBox(height: 20),
                              _buildSatelliteCard(),
                              const SizedBox(height: 20),
                              _buildMapCard(provider.weather!),
                              const SizedBox(height: 20),
                              _buildExtraWidgets(),
                              const SizedBox(height: 40),
                              _buildFooter(),
                              const SizedBox(height: 10),
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
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppTheme.white),
                onPressed: _showSettingsModal,
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
          leading: const Icon(Icons.location_city_rounded, color: AppTheme.midOcean, size: 18),
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

  Widget _buildActionButtons(WeatherModel weather) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.share_rounded,
            label: 'Compartilhar',
            onTap: () {
              Share.share(
                'Confira o clima em ${weather.city}: ${weather.temp}°C, ${weather.description}. Baixe o ClimaBrasil!',
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.notifications_active_outlined,
            label: 'Alertas',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificações de alertas configuradas!')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSatelliteCard() {
    return _sectionCard(
      title: 'Radar Meteorológico',
      icon: Icons.radar_rounded,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            image: const DecorationImage(
              image: NetworkImage('https://www.inmet.gov.br/portal/images/radar/radar_br.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Text(
              'Radar Nacional (INMET)',
              style: TextStyle(color: AppTheme.white.withValues(alpha: 0.5), fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapCard(WeatherModel weather) {
    return _sectionCard(
      title: 'Mapa de Localização',
      icon: Icons.map_rounded,
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          key: ValueKey('${weather.lat}-${weather.lon}'),
          options: MapOptions(
            initialCenter: LatLng(weather.lat, weather.lon),
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(weather.lat, weather.lon),
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          height: 1,
          width: 100,
          color: AppTheme.white.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 20),
        const Text(
          'Desenvolvido por',
          style: TextStyle(color: AppTheme.textLight, fontSize: 10),
        ),
        const SizedBox(height: 4),
        const Text(
          'Stephany Lima de Mattos',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildExtraWidgets() {
    return Row(
      children: [
        Expanded(
          child: _smallInfoCard(
            title: 'Fase da Lua',
            value: 'Crescente',
            icon: FontAwesomeIcons.moon,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _smallInfoCard(
            title: 'Ondas (Litoral)',
            value: '1.2m - Calmo',
            icon: FontAwesomeIcons.water,
          ),
        ),
      ],
    );
  }

  Widget _smallInfoCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          FaIcon(icon, color: AppTheme.white, size: 24),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: AppTheme.white.withValues(alpha: 0.6), fontSize: 10)),
          Text(value, style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child, double? height}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.white, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }

  void _showSettingsModal() {
    double tempUnit = 0; // 0 para Celsius, 1 para Fahrenheit (Slider demo)
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.deepOcean,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configurações',
                style: TextStyle(color: AppTheme.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const Text(
                'Unidade de Medida (Celsius vs Fahrenheit)',
                style: TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('°C', style: TextStyle(color: AppTheme.white)),
                  Expanded(
                    child: Slider(
                      value: tempUnit,
                      min: 0,
                      max: 1,
                      divisions: 1,
                      activeColor: AppTheme.lightLilac,
                      onChanged: (v) {
                        setModalState(() => tempUnit = v);
                      },
                    ),
                  ),
                  const Text('°F', style: TextStyle(color: AppTheme.white)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.oceanBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Salvar Preferências'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
