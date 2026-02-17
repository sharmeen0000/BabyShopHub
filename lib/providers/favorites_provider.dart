import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteItem {
  final String title;
  final String image;

  FavoriteItem({required this.title, required this.image});

  Map<String, dynamic> toMap() => {
        'title': title,
        'image': image,
      };

  factory FavoriteItem.fromMap(Map<String, dynamic> map) => FavoriteItem(
        title: map['title'],
        image: map['image'],
      );
}

class FavoritesProvider with ChangeNotifier {
  List<FavoriteItem> _favorites = [];

  List<FavoriteItem> get favorites => _favorites;

  FavoritesProvider() {
    loadFavorites();
  }

  void toggleFavorite(FavoriteItem item) {
    final index = _favorites.indexWhere((e) => e.title == item.title);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(item);
    }
    saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String title) {
    return _favorites.any((item) => item.title == title);
  }

  void saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = _favorites.map((f) => jsonEncode(f.toMap())).toList();
    prefs.setStringList("favorites", favList);
  }

  void loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList("favorites");
    if (favList != null) {
      _favorites = favList
          .map((e) => FavoriteItem.fromMap(jsonDecode(e)))
          .toList();
      notifyListeners();
    }
  }
}
