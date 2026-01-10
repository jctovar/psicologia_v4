import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/models/storage_post_model.dart';
import 'package:suayed/services/logger_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final _db = Localstore.instance;
  List<StoragePost> _bookmarks = [];
  bool _isInitialized = false;
  bool _isLoading = false;

  List<StoragePost> get bookmarks => _bookmarks;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  BookmarkProvider() {
    // Llamar a _init() sin await para no bloquear el constructor
    // pero con manejo adecuado de estados
    _init();
  }

  /// Inicializa el provider cargando los bookmarks desde storage.
  ///
  /// Este método se llama automáticamente en el constructor.
  /// Maneja el estado de carga y errores de manera segura.
  Future<void> _init() async {
    if (_isInitialized || _isLoading) return;

    _isLoading = true;
    // Notificamos que estamos cargando (opcional, si la UI necesita saberlo)
    notifyListeners();

    try {
      await fetchBookmarks();
      _isInitialized = true;
    } catch (e) {
      AppLogger.e('❌ Error initializing BookmarkProvider', e);
      // Aún así marcamos como inicializado para evitar reintentos infinitos
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene todos los bookmarks guardados desde el almacenamiento local.
  ///
  /// Este método puede ser llamado manualmente para refrescar la lista,
  /// pero también se llama automáticamente durante la inicialización.
  Future<void> fetchBookmarks() async {
    try {
      AppLogger.d('📑 Fetching bookmarks from local storage');
      final result = await _db.collection('bookmarks').get();

      if (result != null && result.isNotEmpty) {
        // Parsear cada bookmark con manejo de errores individual
        final List<StoragePost> parsedBookmarks = [];

        for (final entry in result.entries) {
          try {
            final bookmark = StoragePost.fromJson(entry.value);
            parsedBookmarks.add(bookmark);
          } catch (e) {
            // Log el error pero continúa con los demás bookmarks
            AppLogger.e('❌ Error parsing bookmark ${entry.key}', e);
          }
        }

        _bookmarks = parsedBookmarks;
        AppLogger.i('✅ Successfully loaded ${_bookmarks.length} bookmarks');

        // Solo notificar si ya estamos inicializados
        // (para evitar notificaciones durante la inicialización)
        if (_isInitialized) {
          notifyListeners();
        }
      } else {
        AppLogger.d('📑 No bookmarks found in storage');
        _bookmarks = [];
      }
    } catch (e) {
      AppLogger.e('❌ Error fetching bookmarks', e);
      // En caso de error, mantener la lista vacía pero no fallar
      _bookmarks = [];
      rethrow;
    }
  }

  Future<void> addBookmark(PostModel post) async {
    try {
      AppLogger.d('➕ Adding bookmark: ${post.title}');
      final id = post.id.toString();
      await _db.collection('bookmarks').doc(id).set(post.toJson());
      // Después de agregar, creamos un StoragePost para añadir a la lista local
      // para evitar volver a obtener desde la base de datos.
      final newBookmark = StoragePost(
        id: post.id,
        date: post.date,
        title: post.title,
        link: post.link,
        image: post.image,
        content: post.content,
      );
      // Evitar duplicados
      _bookmarks.removeWhere((b) => b.id == newBookmark.id);
      _bookmarks.insert(0, newBookmark);
      AppLogger.i('✅ Bookmark added successfully (ID: ${post.id})');
      notifyListeners();
    } catch (e) {
      AppLogger.e('❌ Error adding bookmark', e);
      rethrow;
    }
  }

  Future<void> deleteBookmark(int id) async {
    try {
      AppLogger.d('🗑️ Deleting bookmark (ID: $id)');
      await _db.collection('bookmarks').doc(id.toString()).delete();
      _bookmarks.removeWhere((bookmark) => bookmark.id == id);
      AppLogger.i('✅ Bookmark deleted successfully (ID: $id)');
      notifyListeners();
    } catch (e) {
      AppLogger.e('❌ Error deleting bookmark', e);
      rethrow;
    }
  }
}