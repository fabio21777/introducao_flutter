
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AppfavoriteState.dart';
import 'main.dart';

class Addfavorite extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<FavoriteState>();
    var favorites = appState.favorites;
    // Controlador para o campo de texto
    final TextEditingController controller = TextEditingController();



    return SafeArea(child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'digite o nome do favorito',
            ),
          ),
        ),

        ElevatedButton(
          onPressed: () {
            var favoriteName = controller.text; // Obtenha o texto digitado
            print('teste -->$favoriteName');
            if(favoriteName.isNotEmpty){
              appState.favorites.add(favoriteName); // Adicione o favorito
              print(favorites);
              //limpar o campo de texto
              controller.clear();
            }
            // Add Favorite
          },
          child: Text('Adicionar Favorito'),
        ),

      ],
    ));
  }
}