import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:my_first_project/AddFavorite.dart';
import 'package:provider/provider.dart';

import 'AppfavoriteState.dart';
import 'FavoritesPage.dart';
import 'GeneratorPage.dart';
import 'NetworkingPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context) => FavoriteState()),
      ],
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();

        break;
      case 1:
        page = FavoritesPage();
        break;

      case 2:
        page = NetworkingPage();
        break;

      case 3:
        page = Addfavorite();
        break;


      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Builder(
      builder: (context) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: false,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                        icon: Icon(Icons.network_check),
                        label: Text('Network')),
                    NavigationRailDestination(
                      icon: Icon(Icons.add),
                      label: Text('Adicionar favorito')
                    )
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child:
                Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
