import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../utils/constants.dart';

class NewsApiService {
  final String _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> fetchTopHeadlines() async {
    return _fetchNews('$_baseUrl/top-headlines?country=us&apiKey=$apiKey');
  }

  Future<List<Article>> fetchNewsByCategory(String category) async {
    return _fetchNews('$_baseUrl/top-headlines?country=us&category=$category&apiKey=$apiKey');
  }
  
  Future<List<Article>> searchNews(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    return _fetchNews('$_baseUrl/everything?q=$encodedQuery&sortBy=publishedAt&apiKey=$apiKey');
  }

  Future<List<Article>> _fetchNews(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'NewsNow/1.0'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> articlesJson = json['articles'] ?? [];
        
        return articlesJson
            .map((json) => Article.fromJson(json))
            .where((article) => 
                article.title != '[Removed]' && 
                article.title.isNotEmpty &&
                article.url.isNotEmpty)
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }
}