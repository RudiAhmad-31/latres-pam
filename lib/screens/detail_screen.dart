import 'package:flutter/material.dart';
import 'package:latres/models/amiibo_model.dart';
import 'package:latres/services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String head;
  const DetailScreen({Key? key, required this.head}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amiibo Details"),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFavorite 
                  ? "Ditambahkan ke Favorit"
                  : "Dihapus dari Favorit"),
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<Amiibo>(
        future: ApiService.fetchAmiiboByHead(widget.head),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}")
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text("No data"),
            );
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
                  Text("Name: ${amiibo.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 8),
                  Text("Amiibo Series: ${amiibo.amiiboSeries}"),
                  Text("Character: ${amiibo.character}"),
                  Text("Game Series: ${amiibo.gameSeries}"),
                  Text("Type: ${amiibo.type}"),
                  Text("Head: ${amiibo.head}"),
                  Text("Tail: ${amiibo.tail}"),
                  const SizedBox(height: 12),
                  const Text("Release Dates:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (amiibo.release != null) ...[
                    Text("Australia: ${amiibo.release?['au'] ?? '-'}"),
                    Text("Europe: ${amiibo.release?['eu'] ?? '-'}"),
                    Text("North America: ${amiibo.release?['na'] ?? '-'}"),
                    Text("Japan: ${amiibo.release?['jp'] ?? '-'}"),
                  ] else const Text("No release dates available"),
                ],
              ),
            );
          }
        }
      ),
    );
  }
}