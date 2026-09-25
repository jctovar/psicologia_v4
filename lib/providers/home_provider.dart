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
  String? _loadMoreError;
  int _currentPage = 1;
  int _totalPages = 1;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  /// Error de la última carga de página adicional. Mientras no sea `null`,
  /// el scroll no reintenta automáticamente; la UI ofrece reintentar.
  String? get loadMoreError => _loadMoreError;

  /// Verifica si hay más posts disponibles considerando:
  /// 1. Páginas disponibles en el servidor
  /// 2. Límite de memoria (maxPostsInMemory)
  bool get hasMore =>
      _currentPage < _totalPages && _posts.length < maxPostsInMemory;

  Future<void> fetchPosts({bool refresh = false}) async {
    AppLogger.d('📰 Fetching posts (refresh: $refresh)');
    _isLoading = true;
    _errorMessage = null;
    _loadMoreError = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await HttpProvider.getPosts(
        page: 1,
        refreshCache: refresh,
      );
      _posts = response.posts;
      _totalPages = response.totalPages;
      AppLogger.i(
        '✅ Successfully fetched ${_posts.length} posts (page 1/$_totalPages)',
      );
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
      AppLogger.w(
        '⚠️ Límite de memoria alcanzado (${_posts.length}/$maxPostsInMemory posts)',
      );
      return;
    }

    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      AppLogger.d(
        '📰 Loading more posts (page: $nextPage, current: ${_posts.length}/$maxPostsInMemory)',
      );

      final response = await HttpProvider.getPosts(page: nextPage);

      // Si se publicó un post entre páginas, WordPress desplaza la paginación
      // y la nueva página repite posts ya cargados: descartarlos por id.
      final loadedIds = _posts.map((p) => p.id).toSet();
      final newPosts = response.posts
          .where((p) => loadedIds.add(p.id))
          .toList();
      _posts.addAll(newPosts);
      _currentPage = nextPage;
      _totalPages = response.totalPages;

      AppLogger.i(
        '✅ Loaded ${newPosts.length} more posts (page $nextPage/$_totalPages, total: ${_posts.length}, duplicates skipped: ${response.posts.length - newPosts.length})',
      );
    } catch (e) {
      _loadMoreError = e.toString();
      AppLogger.e('❌ Error loading more posts', e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
