import 'package:flutter/material.dart';
import 'package:latres/screens/home_screen.dart';
import 'package:latres/screens/favorite_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // buka box untuk favorites
  await Hive.openBox('favorites');

  runApp(const AmiboApp());
}

class AmiboApp extends StatelessWidget {
  const AmiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Nitendo Amiibo App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/favorites': (context) => const FavoriteScreen(),
      },
    );
  }
}

