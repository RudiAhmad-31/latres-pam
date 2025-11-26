import 'package:flutter/material.dart';
import 'package:latres/models/amiibo_model.dart';
import 'package:latres/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DetailScreen extends StatefulWidget {
  final String head;
  const DetailScreen({Key? key, required this.head}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  /// cek apakah item sudah ada di favorites
  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getStringList('favorites') ?? [];
    final exists = favData.any((item) => json.decode(item)['head'] == widget.head);
    setState(() {
      isFavorite = exists;
    });
  }

  /// toggle favorite add/remove
  Future<void> _toggleFavorite(Amiibo amiibo) async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getStringList('favorites') ?? [];

    if (isFavorite) {
      favData.removeWhere((item) => json.decode(item)['head'] == amiibo.head);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${amiibo.name} removed from favorites")),
      );
    } else {
      favData.add(json.encode({
        'name': amiibo.name,
        'amiiboSeries': amiibo.amiiboSeries,
        'character': amiibo.character,
        'gameSeries': amiibo.gameSeries,
        'head': amiibo.head,
        'tail': amiibo.tail,
        'type': amiibo.type,
        'image': amiibo.image,
        'release': amiibo.release,
      }));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${amiibo.name} added to favorites")),
      );
    }

    await prefs.setStringList('favorites', favData);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amiibo Details"),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () async {
              final amiibo = await ApiService.fetchAmiiboByHead(widget.head);
              _toggleFavorite(amiibo);
            },
          )
        ],
      ),
      body: FutureBuilder<Amiibo>(
        future: ApiService.fetchAmiiboByHead(widget.head),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data"));
          } else {
            final amiibo = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      amiibo.image,
                      width: 150,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Name: ${amiibo.name}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Amiibo Series: ${amiibo.amiiboSeries}"),
                  Text("Character: ${amiibo.character}"),
                  Text("Game Series: ${amiibo.gameSeries}"),
                  Text("Type: ${amiibo.type}"),
                  Text("Head: ${amiibo.head}"),
                  Text("Tail: ${amiibo.tail}"),
                  const SizedBox(height: 12),
                  const Text("Release Dates:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (amiibo.release != null) ...[
                    Text("Australia: ${amiibo.release?['au'] ?? '-'}"),
                    Text("Europe: ${amiibo.release?['eu'] ?? '-'}"),
                    Text("North America: ${amiibo.release?['na'] ?? '-'}"),
                    Text("Japan: ${amiibo.release?['jp'] ?? '-'}"),
                  ] else
                    const Text("No release dates available"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
