import 'package:lunchify/models/database.dart';

class DatabaseHelper {
  /// Singleton - internal constructor is meant to be private and not used from outside
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _db;

  /// Getter for the db - initializes the db if not already done
  static Database get db {
    if (DatabaseHelper._db == null) _instance.initDb();
    return DatabaseHelper._db!;
  }

  /// Initialize db
  initDb() {
    _db = Database();
  }

  /// ------------------------------------------------------
  /// ------------- DB-Calls Favoriten --------------------
  /// ------------------------------------------------------

  Future<List<Restaurant>> getAllRestaurants() async {
    return await db.getAllRestaurants();
  }

  Future<void> insertRestaurant(RestaurantsCompanion entry) async {
    await db.insertRestaurant(entry);
  }

  Future<void> toggleFavorite(int id, bool value) async {
    await db.toggleFavorite(id, value);
  }

  Stream<List<Restaurant>> watchFavorites() {
    return db.watchFavorites();
  }
}
