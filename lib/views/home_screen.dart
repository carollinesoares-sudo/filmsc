import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<FavoritesScreenState> _favoritesKey =
      GlobalKey<FavoritesScreenState>();

  late final List<Widget> _screens = [
    const SearchScreen(),
    FavoritesScreen(key: _favoritesKey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) _favoritesKey.currentState?.reload();
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_rounded),
            label: 'Minha Lista',
          ),
        ],
      ),
    );
  }
}
