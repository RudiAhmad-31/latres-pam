import 'package:flutter/material.dart';
import 'package:latres/models/amiibo_model.dart';
import 'package:latres/services/api_service.dart';
import 'detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushNamed(context, '/favorites');
    }
  }

  Future<bool> _isFavorite(String head) async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getStringList('favorites') ?? [];
    return favData.any((item) => json.decode(item)['head'] == head);
  }

  Future<void> _toggleFavorite(Amiibo amiibo, bool isFav) async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getStringList('favorites') ?? [];

    if (isFav) {
      favData.removeWhere((item) => json.decode(item)['head'] == amiibo.head);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${amiibo.name} removed from favorites")),
      );
    } else {
      favData.add(json.encode({
        'name': amiibo.name,
        'image': amiibo.image,
        'gameSeries': amiibo.gameSeries,
        'head': amiibo.head,
      }));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${amiibo.name} added to favorites")),
      );
    }

    await prefs.setStringList('favorites', favData);
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nitendo Amiibo List"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Amiibo>>(
        future: ApiService.fetchAmiiboList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data"));
          } else {
            final amiiboList = snapshot.data!;
            return ListView.builder(
              itemCount: amiiboList.length,
              itemBuilder: (context, index) {
                final amiibo = amiiboList[index];
                return FutureBuilder<bool>(
                  future: _isFavorite(amiibo.head),
                  builder: (context, favSnapshot) {
                    final isFav = favSnapshot.data ?? false;
                    return ListTile(
                      leading: Image.network(amiibo.image, width: 50, height: 50),
                      title: Text(amiibo.name),
                      subtitle: Text("Game Series: ${amiibo.gameSeries}"),
                      trailing: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavorite(amiibo, isFav),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(head: amiibo.head),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
        ],
      ),
    );
  }
}
