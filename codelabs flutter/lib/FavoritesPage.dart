// ...


import 'package:flutter/material.dart';
import 'package:my_first_project/AppfavoriteState.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<FavoriteState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return

      SafeArea(
          child: Column(
            children: [
              Text('Favorites', style: Theme.of(context).textTheme.headlineLarge),
              Expanded(child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var pair in appState.favorites)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.favorite),
                          Text(pair),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                ],
              ))
            ],
          )
      );

  }
}