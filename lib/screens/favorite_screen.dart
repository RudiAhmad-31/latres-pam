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
  int _selectedIndex = 1; // halaman Favorites aktif

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Decode JSON aman: return null kalau formatnya tidak valid
  Map<String, dynamic>? _safeDecode(String s) {
    try {
      final decoded = json.decode(s);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getStringList('favorites') ?? [];
    final list = <Amiibo>[];

    for (final item in favData) {
        try {
          final decoded = json.decode(item);
          if (decoded is Map<String, dynamic>) {
            list.add(Amiibo.fromJson(decoded));
          } else {
            debugPrint("Skipped non-map item: $item");
          }
        } catch (e) {
          debugPrint("Invalid JSON in favorites: $item");
        }
      }
      if (!mounted) return;
      setState(() {
        favorites = list;
      });
  }

  Future<void> _removeFavoriteByHead(String head) async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getStringList('favorites') ?? [];

    // Pisahkan item yang akan dihapus
    Map<String, dynamic>? removedMap;
    final updated = <String>[];

    for (final item in favData) {
      final map = _safeDecode(item);
      if (map == null) {
        // item rusak → jangan dipakai, tidak dimasukkan ke updated
        continue;
      }
      if (map['head'] == head) {
        removedMap = map; // ini yang dihapus
        continue;
      }
      updated.add(item);
    }

    await prefs.setStringList('favorites', updated);

    // Muat ulang dari storage agar sinkron
    await _loadFavorites();

    final name = removedMap?['name'] ?? 'Item';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$name removed from favorites")),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pop(context); // kembali ke HomeScreen
    }
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
                  key: Key(amiibo.head), // gunakan head sebagai key unik
                  direction: DismissDirection.horizontal,
                  onDismissed: (_) => _removeFavoriteByHead(amiibo.head),
                  background: Container(color: Colors.red),
                  child: ListTile(
                    leading: amiibo.image != null && amiibo.image!.isNotEmpty
                        ? Image.network(amiibo.image!, width: 50, height: 50)
                        : const Icon(Icons.image_not_supported),
                    title: Text(amiibo.name),
                    subtitle: Text("Game Series: ${amiibo.gameSeries}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFavoriteByHead(amiibo.head),
                    ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }
}
