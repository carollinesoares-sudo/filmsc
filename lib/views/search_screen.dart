import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../database/db_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _results = [];
  final Set<int> _savedMovieIds = {};
  bool _isLoading = false;
  bool _isMovie = true;

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    final data = _isMovie
        ? await TmdbService.searchMovies(query)
        : await TmdbService.searchTVShows(query);

    setState(() {
      _results = data;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(Movie movie) async {
    try {
      await DBHelper.instance.addFavoriteMovie(movie);
      if (!mounted) return;
      setState(() => _savedMovieIds.add(movie.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${movie.title} adicionado à Minha Lista!'),
          backgroundColor: const Color(0xFFE50914),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar o filme: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CineFavorite')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Filmes'),
                  selected: _isMovie,
                  selectedColor: const Color(0xFFE50914),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _isMovie = true);
                      _performSearch();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Séries'),
                  selected: !_isMovie,
                  selectedColor: const Color(0xFFE50914),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _isMovie = false);
                      _performSearch();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Buscar por título...',
                filled: true,
                fillColor: const Color(0xFF151A22),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFF00A8E1),
                  ),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00A8E1),
                      ),
                    )
                  : _results.isEmpty
                  ? const Center(
                      child: Text(
                        'Pesquise seus títulos favoritos.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.58,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                          ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final movie = _results[index];
                        final isSaved = _savedMovieIds.contains(movie.id);
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF151A22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      movie.fullImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: const Color(0xFF252C38),
                                        child: const Icon(
                                          Icons.movie_outlined,
                                          color: Colors.grey,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Material(
                                        color: Colors.black.withValues(
                                          alpha: 0.65,
                                        ),
                                        shape: const CircleBorder(),
                                        child: IconButton(
                                          tooltip: isSaved
                                              ? 'Salvo na Minha Lista'
                                              : 'Adicionar à Minha Lista',
                                          icon: Icon(
                                            isSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_add_outlined,
                                            color: isSaved
                                                ? const Color(0xFF00A8E1)
                                                : Colors.white,
                                          ),
                                          onPressed: isSaved
                                              ? null
                                              : () => _toggleFavorite(movie),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  10,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(movie.rating.toStringAsFixed(1)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
