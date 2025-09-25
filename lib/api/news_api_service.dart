// lib/api/news_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsnow/models/article.dart';
import 'package:newsnow/utils/constants.dart';

class NewsApiService {
  final String _baseUrl = 'https://newsapi.org/v2';

  // Fetches general top headlines
  Future<List<Article>> fetchTopHeadlines() async {
    return _fetchNews('$_baseUrl/top-headlines?country=us&apiKey=$apiKey');
  }

  // NEW: Fetches news for a specific category
  Future<List<Article>> fetchNewsByCategory(String category) async {
    return _fetchNews('$_baseUrl/top-headlines?country=us&category=$category&apiKey=$apiKey');
  }

  // Helper function to reduce code duplication
  Future<List<Article>> _fetchNews(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> articlesJson = json['articles'];
      // Filter out articles that have removed content
      return articlesJson
          .map((json) => Article.fromJson(json))
          .where((article) => article.title != '[Removed]')
          .toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}