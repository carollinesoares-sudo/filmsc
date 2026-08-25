import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cine_favorite.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        posterPath TEXT NOT NULL,
        rating REAL NOT NULL
      )
    ''');
  }

  // Salva o filme nos favoritos (Nome exigido pelo professor: addFavoriteMovie)
  Future<int> addFavoriteMovie(Movie movie) async {
    final db = await instance.database;
    return await db.insert(
      'favorites',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retorna a lista de favoritos (Nome exigido pelo professor: getFavoriteMovies)
  Future<List<Movie>> getFavoriteMovies() async {
    final db = await instance.database;
    final result = await db.query('favorites');
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // Atualiza a nota do filme (Nome exigido pelo professor: updateMovieRating)
  Future<int> updateMovieRating(int id, double rating) async {
    final db = await instance.database;
    return await db.update(
      'favorites',
      {'rating': rating},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Remove o favorito pelo ID
  Future<int> removeFavorite(int id) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}