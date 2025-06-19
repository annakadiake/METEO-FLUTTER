import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../widgets/progress_gauge.dart';
import '../widgets/loading_message.dart';
import '../widgets/weather_table.dart';
import 'city_detail_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const MainScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final WeatherService _weatherService = WeatherService();
  final List<WeatherModel> _weatherData = [];
  double _progress = 0.0;
  bool _isLoading = false;
  bool _isCompleted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startWeatherFetch();
  }

  Future<void> _startWeatherFetch() async {
    setState(() {
      _isLoading = true;
      _isCompleted = false;
      _progress = 0.0;
      _weatherData.clear();
      _errorMessage = null;
    });

    try {
      const cities = WeatherService.cities;
      for (int i = 0; i < cities.length; i++) {
        try {
          final weather = await _weatherService.getWeatherForCity(cities[i]);
          setState(() {
            _weatherData.add(weather);
            _progress = (i + 1) / cities.length;
          });

          if (i < cities.length - 1) {
            await Future.delayed(const Duration(seconds: 2));
          }
        } catch (e) {
          print('Erreur pour ${cities[i]}: $e');
        }
      }

      setState(() {
        _isLoading = false;
        _isCompleted = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des données météo: $e';
      });
    }
  }

  void _retry() {
    _startWeatherFetch();
  }

  void _restart() {
    _startWeatherFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo en Temps Réel'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: widget.onThemeToggle,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                widget.isDarkMode
                    ? [Colors.grey.shade900, Colors.black87]
                    : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Progress Gauge
                ProgressGauge(
                  progress: _progress,
                  isCompleted: _isCompleted,
                  onComplete: _restart,
                ),

                const SizedBox(height: 40),

                // Loading message or error
                if (_isLoading)
                  const LoadingMessage()
                else if (_errorMessage != null)
                  Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                // Weather data table
                if (_isCompleted && _weatherData.isNotEmpty)
                  Expanded(
                    child: WeatherTable(
                      weatherData: _weatherData,
                      onCityTap: (weather) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CityDetailScreen(
                                  weather: weather,
                                  isDarkMode: widget.isDarkMode,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
