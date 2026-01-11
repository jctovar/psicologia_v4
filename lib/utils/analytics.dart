import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:suayed/services/logger_service.dart';

/// Servicio centralizado para rastrear eventos y navegación con Firebase Analytics
class Analytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  /// Rastrear un evento personalizado
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      AppLogger.d('📊 Analytics event: $name ${parameters != null ? '- $parameters' : ''}');
    } catch (e) {
      AppLogger.w('⚠️ Analytics event failed: $e');
    }
  }

  /// Rastrear navegación (el observer lo hace automáticamente, pero esto es para eventos custom)
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      AppLogger.d('📊 Analytics screen: $screenName');
    } catch (e) {
      AppLogger.w('⚠️ Analytics screen view failed: $e');
    }
  }

  /// Rastrear búsqueda
  static Future<void> logSearch({required String searchTerm}) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
      AppLogger.d('📊 Analytics search: $searchTerm');
    } catch (e) {
      AppLogger.w('⚠️ Analytics search failed: $e');
    }
  }

  /// Rastrear visualización de contenido
  static Future<void> logViewContent({
    required String contentType,
    required String itemId,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: contentType,
          ),
        ],
        parameters: parameters,
      );
      AppLogger.d('📊 Analytics view content: $contentType (ID: $itemId)');
    } catch (e) {
      AppLogger.w('⚠️ Analytics view content failed: $e');
    }
  }

  /// Rastrear bookmark agregado
  static Future<void> logBookmarkAdded({required String postId}) async {
    try {
      await logEvent(
        name: 'bookmark_added',
        parameters: {'post_id': postId},
      );
    } catch (e) {
      AppLogger.w('⚠️ Analytics bookmark failed: $e');
    }
  }

  /// Rastrear notificación abierta
  static Future<void> logNotificationOpened({required String notificationId}) async {
    try {
      await logEvent(
        name: 'notification_opened',
        parameters: {'notification_id': notificationId},
      );
    } catch (e) {
      AppLogger.w('⚠️ Analytics notification failed: $e');
    }
  }

  /// Rastrear compartir contenido
  static Future<void> logShare({
    required String contentType,
    required String itemId,
  }) async {
    try {
      await logEvent(
        name: 'share_content',
        parameters: {
          'content_type': contentType,
          'item_id': itemId,
        },
      );
    } catch (e) {
      AppLogger.w('⚠️ Analytics share failed: $e');
    }
  }

  /// Rastrear error de la app
  static Future<void> logAppError({
    required String errorType,
    required String errorMessage,
  }) async {
    try {
      await logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
        },
      );
    } catch (e) {
      AppLogger.w('⚠️ Analytics error logging failed: $e');
    }
  }
}
