import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'detailed_movie_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  Future<void> searchShows(String query) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://api.tvmaze.com/search/shows?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception("Failed to fetch search results");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search Movies...",
            hintStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                searchController.clear();
              },
            ),
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              searchShows(query);
            }
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            )
          : searchResults.isEmpty
              ? const Center(
                  child: Text(
                    "",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final show = searchResults[index]['show'];
                    final title = show['name'] ?? 'Unknown';
                    final imageUrl = show['image'] != null
                        ? show['image']['medium']
                        : 'https://via.placeholder.com/150';
                    final summary = show['summary'] ?? 'No summary available';
                    final genres = show['genres'] != null
                        ? List<String>.from(show['genres'])
                        : [];
                    final status = show['status'] ?? 'Unknown';
                    final releaseDate = show['premiered'] ?? 'Unknown';
                    final networkName = show['network'] != null
                        ? show['network']['name']
                        : 'Not provided';

                    return ListTile(
                      leading: Image.network(imageUrl, width: 50, height: 50),
                      title: Text(
                        title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Genres: ${genres.join(', ')}\nStatus: $status\nPremiered: $releaseDate",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailedMovieScreen(
                              title: title,
                              imageUrl: show['image']['original'],
                              summary: summary,
                              genres: genres,
                              releaseDate: releaseDate,
                              status: status,
                              runtime: show['runtime'] ?? 0,
                              rating: show['rating']['average'] ?? '-',
                              networkName: networkName,
                              scheduleTime:
                                  show['schedule']['time'] ?? 'Unknown',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
