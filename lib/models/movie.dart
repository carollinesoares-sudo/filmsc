class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String overview;
  double rating;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    this.backdropPath = '',
    this.overview = '',
    this.rating = 0.0,
  });

  // Converte o JSON da API do TMDB (Filmes 'title' e Séries 'name')
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Sem título',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      overview: json['overview'] ?? '',
      rating:
          (json['vote_average'] as num?)?.toDouble() ??
          0.0, // Corrigido: vote_average
    );
  }

  // Converte o registro lido do banco SQLite para o objeto Dart
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      posterPath: map['posterPath'],
      backdropPath: map['backdropPath'] ?? '',
      overview: map['overview'] ?? '',
      rating: (map['rating'] as num).toDouble(),
    );
  }

  // Mapeia o objeto para ser inserido nas colunas do SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'overview': overview,
      'rating': rating,
    };
  }

  // Monta a URL completa para exibir o pôster
  String get fullImageUrl {
    final imagePath = posterPath.isNotEmpty ? posterPath : backdropPath;
    if (imagePath.isEmpty) {
      return 'https://placehold.co/500x750/151A22/FFFFFF?text=Sem+imagem';
    }
    return 'https://image.tmdb.org/t/p/w500$imagePath';
  }
}
