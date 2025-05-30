import 'package:flutter/material.dart';
import '../managers/favorites_manager.dart';
import '../models/translation_item.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _favoritesManager.loadFavorites();
    setState(() {});
  }

  Future<void> _removeFavorite(TranslationItem item) async {
    await _favoritesManager.removeFavorite(item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoritesManager.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text(
          'No favorite translations yet.',
          style: TextStyle(
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              item.original,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6),
                Text(item.translated, style: TextStyle(fontSize: 15)),
                SizedBox(height: 8),
                Text(
                  'Language: ${item.fromLang.toUpperCase()} → ${item.toLang.toUpperCase()}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                SizedBox(height: 4),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () => _removeFavorite(item),
              tooltip: 'Delete from favorites',
            ),
          ),
        );
      },
    );
  }
}
