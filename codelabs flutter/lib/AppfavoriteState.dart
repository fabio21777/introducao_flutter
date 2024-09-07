import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';

class FavoriteState extends ChangeNotifier {
  var current = WordPair.random().toString();
  void getNext() {
    current = WordPair.random().toString();
    notifyListeners();
  }

  var favorites = <String>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    print(favorites);
    notifyListeners();
  }

}