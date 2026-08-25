class Movie {
  final int id;
  final String title;
  final String posterPath;
  double rating;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    this.rating = 0.0,
  });

  // Converte o JSON da API do TMDB (Filmes 'title' e Séries 'name')
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Sem título',
      posterPath: json['poster_path'] ?? '',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0, // Corrigido: vote_average
    );
  }

  // Converte o registro lido do banco SQLite para o objeto Dart
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      posterPath: map['posterPath'],
      rating: (map['rating'] as num).toDouble(),
    );
  }

  // Mapeia o objeto para ser inserido nas colunas do SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'rating': rating,
    };
  }

  // Monta a URL completa para exibir o pôster
  String get fullImageUrl {
    if (posterPath.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=Sem+Poster';
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}