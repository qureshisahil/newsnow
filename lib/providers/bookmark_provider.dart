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