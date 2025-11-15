import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/custom_style.dart';

Future<NewsData> fetchNewsData() async {
  final response = await http.get(Uri.parse(
      'http://newsapi.org/v2/top-headlines?country=in&category=health&apiKey=1fbee980d10644bca6e4c3243034c10a'));

  if (response.statusCode == 200) {
    return NewsData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load NewsData');
  }
}

class NewsData {
  final String status;
  final int totalResults;
  final List<News> articles;

  const NewsData({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) {
    return NewsData(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      articles: (json['articles'] as List<dynamic>)
          .map((value) => News.fromJson(value))
          .toList(),
    );
  }
}

class News {
  final String? author;
  final String? title;
  final String? description;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  News({
    this.author,
    this.title,
    this.description,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      author: json['author'],
      title: json['title'],
      description: json['description'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      content: json['content'],
    );
  }
}

class MDNews extends StatefulWidget {
  final String? title;
  const MDNews({super.key, this.title});

  @override
  _MDNewsState createState() => _MDNewsState();
}

class _MDNewsState extends State<MDNews> {
  late final Future<NewsData> futureNews;

  @override
  void initState() {
    super.initState();
    futureNews = fetchNewsData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsData>(
      future: futureNews,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final articles = snapshot.data!.articles;
          return Expanded(
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) => _buildListItem(articles[index]),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}", style: cErrorText));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildListItem(News item) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title ?? '', style: cHeaderText),
            const SizedBox(height: 4),
            Text(item.description ?? '', style: cBodyText),
            if (item.urlToImage != null && item.urlToImage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(
                  item.urlToImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
            Text('Published at: ${item.publishedAt ?? ''}', style: cBodyText),
            Text('Author: ${item.author ?? 'Unknown'}', style: cBodyText),
          ],
        ),
      ),
    );
  }
}
