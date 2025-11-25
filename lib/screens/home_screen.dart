import 'package:flutter/material.dart';
import 'package:latres/models/amiibo_model.dart';
import 'package:latres/services/api_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key:key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1){
      Navigator.pushNamed(context, '/favorites');
    }
  }

  @override

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nitendo Amiibo List"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Amiibo>>(
        future: ApiService.fetchAmiiboList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator()
              );
          } else if (snapshot.hasError){
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty){
            return const Center(
              child: Text("No data"),
            );
          } else {
            final amiiboList = snapshot.data!;
            return ListView.builder(
              itemCount: amiiboList.length,
              itemBuilder: (context, index){
                final amiibo = amiiboList[index];
                return ListTile(
                  leading: Image.network(
                    amiibo.image,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(amiibo.name),
                  subtitle: Text("Game Series: ${amiibo.gameSeries}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${amiibo.name} telah ditambahkan ke favorit")),
                      );
                    },
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
          }
        }
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          )
        ],
      ),
    );
  }
}