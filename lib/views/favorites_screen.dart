import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../database/db_helper.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  List<Movie> _favorites = [];
  String _userName = '';
  String _profileId = 'default';
  int _avatarIndex = 0;
  bool _isLoading = true;

  final List<IconData> _avatarIcons = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.face_unlock_rounded,
    Icons.account_circle_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFavorites();
  }

  Future<void> _loadUserDataAndFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getString('activeProfileId') ?? 'default';
    final favorites = await DBHelper.instance.getFavoriteMovies(
      profileId: profileId,
    );

    setState(() {
      _userName = prefs.getString('userName') ?? 'Usuário';
      _profileId = profileId;
      _avatarIndex = prefs.getInt('userAvatarIndex') ?? 0;
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> reload() => _loadUserDataAndFavorites();

  void _removeFavorite(int id) async {
    await DBHelper.instance.removeFavorite(id, profileId: _profileId);
    _loadUserDataAndFavorites();
  }

  void _showMovieDetails(Movie movie) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151A22),
        title: Text(movie.title),
        content: SingleChildScrollView(
          child: Text(
            movie.overview.isEmpty ? 'Sinopse indisponível.' : movie.overview,
            style: const TextStyle(color: Color(0xFFD5DBE5), height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showRatingDialog(movie);
            },
            icon: const Icon(Icons.star_outline),
            label: const Text('Avaliar'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(Movie movie) {
    double currentRating = movie.rating;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F1F),
              title: Text(
                'Avaliar "${movie.title}"',
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  Slider(
                    value: currentRating,
                    min: 0.0,
                    max: 10.0,
                    divisions: 10,
                    activeColor: const Color(0xFFE50914),
                    onChanged: (val) =>
                        setDialogState(() => currentRating = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                  ),
                  onPressed: () async {
                    await DBHelper.instance.updateMovieRating(
                      movie.id,
                      currentRating,
                      profileId: _profileId,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _loadUserDataAndFavorites();
                  },
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00A8E1)),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF151A22),
                        child: Icon(
                          _avatarIcons[_avatarIndex < _avatarIcons.length
                              ? _avatarIndex
                              : 0],
                          color: const Color(0xFFE50914),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_favorites.length} títulos salvos',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _favorites.isEmpty
                      ? const Center(
                          child: Text(
                            'Sua lista está vazia.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: _favorites.length,
                          itemBuilder: (context, index) {
                            final movie = _favorites[index];
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF151A22),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: () => _showMovieDetails(movie),
                                      child: Image.network(
                                        movie.fullImageUrl,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          color: Colors.grey[900],
                                          child: const Icon(
                                            Icons.movie,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.8),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _removeFavorite(movie.id),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () => _showRatingDialog(movie),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                movie.rating.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const Spacer(),
                                              const Icon(
                                                Icons.edit,
                                                color: Colors.grey,
                                                size: 14,
                                              ),
                                            ],
                                          ),
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
    );
  }
}
