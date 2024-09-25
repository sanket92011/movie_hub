import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_hub/pages/search_screen.dart';

import '../widgets/movie_card.dart';
import 'detailed_movie_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic data;

  Future<void> fetchData() async {
    try {
      final result = await http.get(
        Uri.parse("https://api.tvmaze.com/search/shows?q=all"),
      );
      if (result.statusCode == 200) {
        data = jsonDecode(result.body);
        return data;
      } else {
        throw "Error occurred!";
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final Size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Movie Hub",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 8),
                  const Text(
                    "An error occurred!",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: GestureDetector(
                      onTap: (() {
                        return setState(() {});
                      }),
                      child: const Text(
                        "Retry",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "No data found",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          "Search for movies...",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Trending Movies",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: Size.width >= 1024
                        ? const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.65,
                          )
                        : const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.65,
                          ),
                    itemBuilder: (context, index) {
                      final show = data[index]['show'] ?? 'not found';
                      final title = show['name'] ?? 'not found';
                      final summary = show['summary'] ?? 'not found';
                      final genres = show['genres'] != null
                          ? List<String>.from(show['genres'])
                          : [];
                      final status = show['status'] ?? 'not found';
                      final scheduleTime =
                          show['schedule']['time'] ?? 'not found';
                      final rating = show['rating']['average'] ?? '-';
                      final runtime = show['runtime'] ?? 1;
                      final releaseDate = show['premiered'] ?? 'not found';
                      final networkName = show['network'] != null
                          ? show['network']['name']
                          : 'Not provided';
                      final largeImageUrl = show['image'] != null
                          ? show['image']['original']
                          : "https://img.icons8.com/?size=256w&id=13066&format=png";
                      final imageUrl = show['image'] != null
                          ? show['image']['medium']
                          : "https://img.icons8.com/?size=256w&id=13066&format=png";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailedMovieScreen(
                                title: title,
                                imageUrl: largeImageUrl,
                                summary: summary,
                                genres: genres,
                                releaseDate: releaseDate,
                                status: status,
                                runtime: runtime,
                                rating: rating,
                                networkName: networkName,
                                scheduleTime: scheduleTime,
                              ),
                            ),
                          );
                        },
                        child: MovieCard(
                          movieName: title,
                          imageUrl: imageUrl,
                        ),
                      );
                    },
                    itemCount: data.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
