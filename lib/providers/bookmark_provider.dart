import 'package:flutter/foundation.dart';
import '../models/article.dart';

class BookmarkProvider extends ChangeNotifier {
  final List<Article> _bookmarks = [];
  
  List<Article> get bookmarks => List.unmodifiable(_bookmarks);
  
  bool isBookmarked(Article article) {
    return _bookmarks.any((bookmark) => bookmark.url == article.url);
  }
  
  void toggleBookmark(Article article) {
    if (isBookmarked(article)) {
      _bookmarks.removeWhere((bookmark) => bookmark.url == article.url);
    } else {
      _bookmarks.add(article);
    }
    notifyListeners();
  }
  
  void removeBookmark(Article article) {
    _bookmarks.removeWhere((bookmark) => bookmark.url == article.url);
    notifyListeners();
  }
  
  void clearBookmarks() {
    _bookmarks.clear();
    notifyListeners();
  }
}

// lib/models/article.dart
class Article {
  final String title;
  final String? description;
  final String? urlToImage;
  final String url;
  final String? author;
  final DateTime? publishedAt;
  final String? sourceName;

  Article({
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    this.author,
    this.publishedAt,
    this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'],
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      author: json['author'],
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : null,
      sourceName: json['source']?['name'],
    );
  }
  
  String get timeAgo {
    if (publishedAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(publishedAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}