import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/weather_model.dart';

class WeatherRecord {
  final int? id;
  final String city;
  final int temp;
  final String description;
  final int humidity;
  final String windSpeedy;
  final String condition;
  final DateTime queriedAt;

  WeatherRecord({
    this.id,
    required this.city,
    required this.temp,
    required this.description,
    required this.humidity,
    required this.windSpeedy,
    required this.condition,
    required this.queriedAt,
  });

  factory WeatherRecord.fromJson(Map<String, dynamic> json) {
    return WeatherRecord(
      id: json['id'] as int?,
      city: json['city'] as String,
      temp: json['temp'] as int,
      description: json['description'] as String,
      humidity: json['humidity'] as int,
      windSpeedy: json['wind_speedy'] as String,
      condition: json['condition'] as String? ?? '',
      queriedAt: DateTime.parse(json['queried_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'city': city,
        'temp': temp,
        'description': description,
        'humidity': humidity,
        'wind_speedy': windSpeedy,
        'condition': condition,
        'queried_at': queriedAt.toIso8601String(),
      };

  factory WeatherRecord.fromWeatherModel(WeatherModel model) {
    return WeatherRecord(
      city: model.city,
      temp: model.temp,
      description: model.description,
      humidity: model.humidity,
      windSpeedy: model.windSpeedy,
      condition: model.conditionSlug,
      queriedAt: DateTime.now(),
    );
  }
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  SupabaseClient get _client => Supabase.instance.client;
  static const String _table = 'weather_history';

  /// Salva um registro climático evitando redundância:
  /// Se a mesma cidade foi consultada nos últimos 10 minutos,
  /// atualiza em vez de inserir.
  Future<void> saveWeatherRecord(WeatherModel model) async {
    try {
      final tenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 10));

      // Verifica registro recente da mesma cidade
      final existing = await _client
          .from(_table)
          .select('id')
          .eq('city', model.city)
          .gte('queried_at', tenMinutesAgo.toIso8601String())
          .maybeSingle();

      if (existing != null) {
        // Atualiza registro existente (evita redundância)
        await _client
            .from(_table)
            .update(WeatherRecord.fromWeatherModel(model).toJson())
            .eq('id', existing['id']);
      } else {
        // Insere novo registro
        await _client
            .from(_table)
            .insert(WeatherRecord.fromWeatherModel(model).toJson());
      }
    } catch (e) {
      // Falha silenciosa - não interrompe o fluxo principal do app
      print('[DatabaseService] Erro ao salvar: $e');
    }
  }

  /// Retorna as últimas 10 buscas (ordenadas por data desc)
  Future<List<WeatherRecord>> getRecentSearches({int limit = 10}) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .order('queried_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => WeatherRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[DatabaseService] Erro ao buscar histórico: $e');
      return [];
    }
  }

  /// Retorna histórico de uma cidade específica
  Future<List<WeatherRecord>> getCityHistory(String city, {int limit = 20}) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('city', city)
          .order('queried_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => WeatherRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[DatabaseService] Erro ao buscar histórico da cidade: $e');
      return [];
    }
  }

  /// Retorna última consulta salva de cada cidade (sem repetição)
  Future<List<WeatherRecord>> getLatestPerCity() async {
    try {
      final response = await _client
          .from('latest_weather_per_city')
          .select()
          .order('queried_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((item) => WeatherRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[DatabaseService] Erro ao buscar cidades: $e');
      return [];
    }
  }

  /// Deleta registros mais antigos que X dias (limpeza opcional)
  Future<void> cleanOldRecords({int daysToKeep = 30}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: daysToKeep));
      await _client
          .from(_table)
          .delete()
          .lt('queried_at', cutoff.toIso8601String());
    } catch (e) {
      print('[DatabaseService] Erro na limpeza: $e');
    }
  }
}
