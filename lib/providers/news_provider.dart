import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_api_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService = NewsApiService();
  
  List<Article> _articles = [];
  List<Article> _searchResults = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedCategory = 'general';
  String _searchQuery = '';
  
  List<Article> get articles => _articles;
  List<Article> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  
  final List<String> categories = [
    'general', 'business', 'entertainment', 'health', 
    'science', 'sports', 'technology'
  ];
  
  Future<void> fetchNews() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      if (_selectedCategory == 'general') {
        _articles = await _apiService.fetchTopHeadlines();
      } else {
        _articles = await _apiService.fetchNewsByCategory(_selectedCategory);
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _searchQuery = query;
    notifyListeners();
    
    try {
      _searchResults = await _apiService.searchNews(query);
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  void setCategory(String category) {
    _selectedCategory = category;
    fetchNews();
  }
  
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}