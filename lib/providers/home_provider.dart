import 'package:flutter/material.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/services/logger_service.dart';
import 'package:suayed/services/posts_service.dart';

class HomeProvider extends ChangeNotifier {
  /// Límite máximo de posts en memoria para prevenir memory leaks
  static const int maxPostsInMemory = 200;

  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  /// Verifica si hay más posts disponibles considerando:
  /// 1. Páginas disponibles en el servidor
  /// 2. Límite de memoria (maxPostsInMemory)
  bool get hasMore => _currentPage < _totalPages && _posts.length < maxPostsInMemory;

  Future<void> fetchPosts({bool refresh = false}) async {
    AppLogger.d('📰 Fetching posts (refresh: $refresh)');
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await HttpProvider.getPosts(
        page: 1,
        refreshCache: refresh,
      );
      _posts = response.posts;
      _totalPages = response.totalPages;
      AppLogger.i('✅ Successfully fetched ${_posts.length} posts (page 1/$_totalPages)');
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e('❌ Error fetching posts', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;

    // Verificar límite de memoria antes de cargar más
    if (_posts.length >= maxPostsInMemory) {
      AppLogger.w('⚠️ Límite de memoria alcanzado ($_posts.length/$maxPostsInMemory posts)');
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      AppLogger.d('📰 Loading more posts (page: $nextPage, current: ${_posts.length}/$maxPostsInMemory)');

      final response = await HttpProvider.getPosts(page: nextPage);
      _posts.addAll(response.posts);
      _currentPage = nextPage;
      _totalPages = response.totalPages;

      AppLogger.i('✅ Loaded ${response.posts.length} more posts (page $nextPage/$_totalPages, total: ${_posts.length})');
    } catch (e) {
      AppLogger.e('❌ Error loading more posts', e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
