import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'favorites.g.dart';

class Restaurants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get backgroundColor => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Restaurants])
class Favorites extends _$AppDatabase {
  Favorites() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Restaurant>> getAllRestaurants() {
    return select(restaurants).get();
  }

  Stream<List<Restaurant>> watchFavorites() =>
      (select(restaurants)
        ..where((tbl) => tbl.isFavorite.equals(true))).watch();

  Future<void> insertRestaurant(RestaurantsCompanion entry) =>
      into(restaurants).insert(entry);

  Future<void> toggleFavorite(int id, bool value) async {
    await (update(restaurants)..where(
      (t) => t.id.equals(id),
    )).write(RestaurantsCompanion(isFavorite: Value(value)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
