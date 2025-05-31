import 'package:flutter/material.dart';
import '../managers/favorites_manager.dart';
import '../models/translation_item.dart';
import 'dart:async';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesManager _favoritesManager = FavoritesManager();
  late StreamSubscription<List<TranslationItem>> _subscription;
  List<TranslationItem> _favorites = [];

  @override
  void initState() {
    super.initState();
    _favoritesManager.loadFavorites();
    _subscription = _favoritesManager.favoritesStream.listen((updatedFavorites) {
      setState(() {
        _favorites = updatedFavorites;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _removeFavorite(TranslationItem item) async {
    await _favoritesManager.removeFavorite(item);
  }

  Future<void> _clearAllFavorites() async {
    await _favoritesManager.clearAllFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _favorites.isEmpty
                  ? Center(
                child: Text(
                  'No favorite translations yet.',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final item = _favorites[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: Text(
                        item.original,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(item.translated, style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 8),
                          Text(
                            'Language: ${item.fromLang.toUpperCase()} → ${item.toLang.toUpperCase()}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
                        onPressed: () => _removeFavorite(item),
                        tooltip: 'Delete from favorites',
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_favorites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delete all favorites',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: const Color(0xFFEF5350),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete all favorites?'),
                            content: const Text(
                                'Are you sure you want to delete all favorites? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _clearAllFavorites();
                                },
                                child: const Text(
                                  'Delete All',
                                  style: TextStyle(color: Color(0xFFEF5350)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Icon(Icons.delete_forever, color: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
