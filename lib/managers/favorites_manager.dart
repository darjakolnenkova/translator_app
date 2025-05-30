import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/translation_item.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  static const String _prefsKey = 'favorite_translations';

  final List<TranslationItem> _favorites = [];

  List<TranslationItem> get favorites => List.unmodifiable(_favorites);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    _favorites.clear();
    _favorites.addAll(jsonList.map((e) => TranslationItem.fromJson(jsonDecode(e))));
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _favorites.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonList);
  }

  Future<void> addFavorite(TranslationItem item) async {
    if (!_favorites.any((e) => e.original == item.original && e.translated == item.translated)) {
      _favorites.add(item);
      await saveFavorites();
    }
  }

  Future<void> removeFavorite(TranslationItem item) async {
    _favorites.removeWhere((e) => e.original == item.original && e.translated == item.translated);
    await saveFavorites();
  }

  bool isFavorite(TranslationItem item) {
    return _favorites.any((e) => e.original == item.original && e.translated == item.translated);
  }
}
