import 'package:flutter/foundation.dart';

import '../../data/models/favorite_entry.dart';
import '../storage/app_storage.dart';

/// Сервис избранного: единое состояние для всех экранов.
class FavoritesService extends ChangeNotifier {
  FavoritesService(this._storage);

  final AppStorage _storage;

  Set<String> get items => _storage.favorites;

  bool contains(FavoriteEntry entry) => items.contains(entry.encode());

  Future<void> toggle(FavoriteEntry entry) async {
    await _storage.toggleFavorite(entry.encode());
    notifyListeners();
  }

  Future<void> remove(String encoded) async {
    final current = items..remove(encoded);
    await _storage.setFavorites(current);
    notifyListeners();
  }

  List<FavoriteEntry> get entries =>
      items.map(FavoriteEntry.decode).whereType<FavoriteEntry>().toList();
}
