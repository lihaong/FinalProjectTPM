import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimePage extends StatefulWidget {
  @override
  _AnimePageState createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  List<dynamic> animeData = [];

  @override
  void initState() {
    super.initState();
    fetchAnimeData().then((data) {
      setState(() {
        animeData = data;
      });
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Page'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: animeData.length,
          itemBuilder: (context, index) {
            final anime = animeData[index];
            return _buildAnimeCard(anime);
          },
        ),
      ),
    );
  }
}

Future<List<dynamic>> fetchAnimeData() async {
  final url = Uri.https(
    'anime-db.p.rapidapi.com',
    '/anime',
    {
      'page': '1',
      'size': '10',
      'genres': 'Fantasy,Drama',
      'sortBy': 'ranking',
      'sortOrder': 'asc',
    },
  );

  final headers = {
    'X-RapidAPI-Key': 'd9a90fe7edmsha38a206f698e96cp11203djsn6cb7b5339d6e',
    'X-RapidAPI-Host': 'anime-db.p.rapidapi.com',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'] as List<dynamic>;
    return data;
  } else {
    throw Exception('Failed to load anime data');
  }
}

Card _buildAnimeCard(Map<String, dynamic> animeData) {
  final title = animeData['title'] as String;
  final ranking = animeData['ranking'] as int;
  final genres = animeData['genres'] as List<dynamic>;
  final image = animeData['image'] as String;
  final synopsis = animeData['synopsis'] as String;
  final link = animeData['link'] as String;
  bool isExpanded = false;

  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: image,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.yellow[700],
                    ),
                    SizedBox(width: 4),
                    Text(
                      ranking.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        // if (await canLaunch(link)) {
                        // await launch(link);
                        // } else {
                        // throw 'Could not launch $link';
                        // }
                      },
                      icon: Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  genres.join(', '),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                ExpansionTile(
                  initiallyExpanded: false,
                  // onExpansionChanged: (value) {
                  // setState(() {
                  // isExpanded = value;
                  // });
                  // },
                  title: Text(
                    'Synopsis',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: Text(
                        synopsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    if (await canLaunch(link)) {
                      await launch(link);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                  child: Text('Read More'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
