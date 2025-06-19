import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = '8a1c46f11a70f7392672531d5bf94b4f';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  static const List<String> cities = [
    'Dakar',
    'Fatick',
    'Kaolack',
    'Saint-Louis',
    'Tambacounda',
  ];

  Future<WeatherModel> getWeatherForCity(String cityName) async {
    try {
      final url = '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric&lang=fr';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Erreur lors de la récupération des données météo');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<WeatherModel>> getAllWeatherData() async {
    List<WeatherModel> weatherList = [];

    for (String city in cities) {
      try {
        final weather = await getWeatherForCity(city);
        weatherList.add(weather);
        // Attendre un peu entre chaque appel pour l'effet visuel
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        // En cas d'erreur, on continue avec les autres villes
        print('Erreur pour $city: $e');
      }
    }

    return weatherList;
  }
}
