import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/database_service.dart';
import '../../core/constants/supabase_config.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final DatabaseService _dbService = DatabaseService();

  WeatherModel? _weather;
  WeatherStatus _status = WeatherStatus.initial;
  String _errorMessage = '';
  String _currentCity = '';
  List<String> _searchHistory = [];
  List<WeatherRecord> _dbHistory = [];
  bool _dbHistoryLoading = false;

  WeatherModel? get weather => _weather;
  WeatherStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get currentCity => _currentCity;
  List<String> get searchHistory => _searchHistory;
  List<WeatherRecord> get dbHistory => _dbHistory;
  bool get dbHistoryLoading => _dbHistoryLoading;
  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasData => _status == WeatherStatus.success && _weather != null;

  Future<void> searchCity(String cityName) async {
    if (cityName.trim().isEmpty) return;

    _status = WeatherStatus.loading;
    _errorMessage = '';
    _currentCity = cityName.trim();
    notifyListeners();

    try {
      _weather = await _weatherService.fetchWeatherByCity(_currentCity);
      _status = WeatherStatus.success;
      _addToLocalHistory(_currentCity);

      // Salva no Supabase em background (não bloqueia a UI)
      if (SupabaseConfig.isConfigured) {
        _dbService.saveWeatherRecord(_weather!).then((_) {
          _loadDbHistory(); // Atualiza histórico após salvar
        });
      }
    } catch (e) {
      _errorMessage =
          'Não foi possível obter dados de "$_currentCity".\nVerifique o nome da cidade e tente novamente.';
      _status = WeatherStatus.error;
    }

    notifyListeners();
  }

  Future<void> refreshCurrent() async {
    if (_currentCity.isNotEmpty) {
      await searchCity(_currentCity);
    }
  }

  Future<void> loadInitialData() async {
    if (SupabaseConfig.isConfigured) {
      await _loadDbHistory();
    }
    await searchCity('São Paulo');
  }

  Future<void> _loadDbHistory() async {
    if (!SupabaseConfig.isConfigured) return;
    _dbHistoryLoading = true;
    notifyListeners();

    _dbHistory = await _dbService.getRecentSearches(limit: 10);
    _dbHistoryLoading = false;
    notifyListeners();
  }

  Future<List<WeatherRecord>> getCityHistory(String city) async {
    if (!SupabaseConfig.isConfigured) return [];
    return _dbService.getCityHistory(city);
  }

  void _addToLocalHistory(String city) {
    _searchHistory.remove(city);
    _searchHistory.insert(0, city);
    if (_searchHistory.length > 5) {
      _searchHistory = _searchHistory.sublist(0, 5);
    }
  }
}
