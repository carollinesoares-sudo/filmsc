import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TmdbService {
  // Sua Chave da API (v3 auth)
  static const String _apiKey = '6fc35e6ebec2f24232893cdb00697b3e';

  static Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https('api.themoviedb.org', '/3/search/movie', {
      'api_key': _apiKey,
      'query': query,
      'language': 'pt-BR',
    });
    return _fetchData(url);
  }

  static Future<List<Movie>> searchTVShows(String query) async {
    final url = Uri.https('api.themoviedb.org', '/3/search/tv', {
      'api_key': _apiKey,
      'query': query,
      'language': 'pt-BR',
    });
    return _fetchData(url);
  }

  static Future<List<Movie>> _fetchData(Uri url) async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((item) => Movie.fromJson(item)).toList();
      }
      debugPrint(
        'TMDB retornou status ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      debugPrint('Erro de conexão com a API: $e');
    }
    return [];
  }
}
