import 'package:flutter/material.dart';
import 'package:movie_hub/pages/search_screen.dart';

import 'home_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  List<Widget> pages = [const HomeScreen(), const SearchScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPage == 0 ? const HomeScreen() : const SearchScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.search),
          )
        ],
      ),
    );
  }
}
