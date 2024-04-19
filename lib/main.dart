import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixabay Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final String apiKey = '43436269-ab76f10f8a63ee109b3f720c9';
  List<dynamic> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl =
        'https://pixabay.com/api/?key=$apiKey&per_page=50&image_type=photo';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        _images = json.decode(response.body)['hits'];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pixabay Gallery'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : StaggeredGridView.countBuilder(
        crossAxisCount: _calculateCrossAxisCount(context),
        itemCount: _images.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _openFullScreenImage(context, index),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: _images[index]['webformatURL'],
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Likes: ${_images[index]['likes']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Views: ${_images[index]['views']}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        staggeredTileBuilder: (index) => StaggeredTile.fit(1),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth ~/ 150; // Adjust this value according to your preference
  }

  void _openFullScreenImage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: _images[index]['largeImageURL'],
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
