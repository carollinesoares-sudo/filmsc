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
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        posterPath TEXT NOT NULL,
        rating REAL NOT NULL,
        overview TEXT NOT NULL DEFAULT '',
        profileId TEXT NOT NULL DEFAULT 'default',
        backdropPath TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE favorites ADD COLUMN overview TEXT NOT NULL DEFAULT ''",
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE favorites ADD COLUMN profileId TEXT NOT NULL DEFAULT 'default'",
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE favorites ADD COLUMN backdropPath TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  // Salva o filme nos favoritos (Nome exigido pelo professor: addFavoriteMovie)
  Future<int> addFavoriteMovie(
    Movie movie, {
    String profileId = 'default',
  }) async {
    final db = await instance.database;
    final values = {...movie.toMap(), 'profileId': profileId};
    return await db.insert(
      'favorites',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retorna a lista de favoritos (Nome exigido pelo professor: getFavoriteMovies)
  Future<List<Movie>> getFavoriteMovies({String profileId = 'default'}) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'profileId = ?',
      whereArgs: [profileId],
      orderBy: 'title COLLATE NOCASE',
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // Atualiza a nota do filme (Nome exigido pelo professor: updateMovieRating)
  Future<int> updateMovieRating(
    int id,
    double rating, {
    String profileId = 'default',
  }) async {
    final db = await instance.database;
    return await db.update(
      'favorites',
      {'rating': rating},
      where: 'id = ? AND profileId = ?',
      whereArgs: [id, profileId],
    );
  }

  // Remove o favorito pelo ID
  Future<int> removeFavorite(int id, {String profileId = 'default'}) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'id = ? AND profileId = ?',
      whereArgs: [id, profileId],
    );
  }
}
