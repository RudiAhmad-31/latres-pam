// lib/screens/favorite_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latres/models/amiibo_model.dart';
import 'detail_screen.dart';
import 'dart:convert';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Amiibo> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getStringList('favorites') ?? [];
    setState(() {
      favorites = favData
          .map((item) => Amiibo.fromJson(json.decode(item)))
          .toList();
    });
  }

  Future<void> _removeFavorite(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getStringList('favorites') ?? [];

    final removedItem = favorites[index];
    favData.removeAt(index);
    await prefs.setStringList('favorites', favData);

    setState(() {
      favorites.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${removedItem.name} removed from favorites")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: favorites.isEmpty
          ? const Center(child: Text("No favorites yet"))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final amiibo = favorites[index];
                return Dismissible(
                  key: Key(amiibo.head),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    _removeFavorite(index);
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    leading: Image.network(amiibo.image, width: 50, height: 50),
                    title: Text(amiibo.name),
                    subtitle: Text("Head: ${amiibo.head}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(head: amiibo.head),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
