import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/translation_item.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  static const String _prefsKey = 'favorite_translations';
  final List<TranslationItem> _favorites = [];
  final BehaviorSubject<List<TranslationItem>> _favoritesStream =
  BehaviorSubject.seeded([]);

  Stream<List<TranslationItem>> get favoritesStream => _favoritesStream.stream;
  List<TranslationItem> get favorites => List.unmodifiable(_favorites);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    _favorites.clear();
    _favorites.addAll(jsonList.map((e) => TranslationItem.fromJson(jsonDecode(e))));
    _favoritesStream.add([..._favorites]);
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _favorites.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonList);
    _favoritesStream.add([..._favorites]);
  }

  Future<void> addFavorite(TranslationItem item) async {
    if (!_favorites.any((e) => e.id == item.id)) {
      _favorites.add(item);
      await _saveToPrefs();
    }
  }

  Future<void> removeFavorite(TranslationItem item) async {
    final existed = _favorites.any((e) => e.id == item.id);
    if (existed) {
      _favorites.removeWhere((e) => e.id == item.id);
      await _saveToPrefs();
    }
  }

  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await _saveToPrefs();
  }

  bool isFavorite(TranslationItem item) {
    return _favorites.any((e) => e.id == item.id);
  }

  void dispose() {
    _favoritesStream.close();
  }
}
