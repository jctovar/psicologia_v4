import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:suayed/models/notification_model.dart';
import 'package:suayed/services/logger_service.dart';

class NotificationProvider extends ChangeNotifier {
  final _db = Localstore.instance;
  List<NotificationModel> _notifications = [];
  bool _isInitialized = false;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Obtiene el número de notificaciones no leídas
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Obtiene solo las notificaciones no leídas
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Obtiene solo las notificaciones leídas
  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  NotificationProvider() {
    _init();
  }

  /// Inicializa el provider cargando las notificaciones desde storage.
  ///
  /// Este método se llama automáticamente en el constructor.
  /// Maneja el estado de carga y errores de manera segura.
  Future<void> _init() async {
    if (_isInitialized || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await fetchNotifications();
      _isInitialized = true;
      AppLogger.i('✅ NotificationProvider initialized successfully');
    } catch (e) {
      AppLogger.e('❌ Error initializing NotificationProvider', e);
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene todas las notificaciones guardadas desde el almacenamiento local.
  ///
  /// Las notificaciones se ordenan por fecha (más reciente primero).
  Future<void> fetchNotifications() async {
    try {
      AppLogger.d('📬 Fetching notifications from local storage');
      final result = await _db.collection('notifications').get();

      if (result != null && result.isNotEmpty) {
        final List<NotificationModel> parsedNotifications = [];

        for (final entry in result.entries) {
          try {
            final notification = NotificationModel.fromJson(entry.value);
            parsedNotifications.add(notification);
          } catch (e) {
            AppLogger.e('❌ Error parsing notification ${entry.key}', e);
          }
        }

        // Ordenar por fecha (más reciente primero)
        parsedNotifications.sort((a, b) => b.date.compareTo(a.date));

        _notifications = parsedNotifications;
        AppLogger.i(
            '✅ Successfully loaded ${_notifications.length} notifications ($unreadCount unread)');

        if (_isInitialized) {
          notifyListeners();
        }
      } else {
        AppLogger.d('📬 No notifications found in storage');
        _notifications = [];
      }
    } catch (e) {
      AppLogger.e('❌ Error fetching notifications', e);
      _notifications = [];
      rethrow;
    }
  }

  /// Agrega una nueva notificación
  Future<void> addNotification(NotificationModel notification) async {
    try {
      AppLogger.d('➕ Adding notification: ${notification.title}');
      final id = notification.id;
      await _db.collection('notifications').doc(id).set(notification.toJson());

      // Evitar duplicados
      _notifications.removeWhere((n) => n.id == notification.id);
      _notifications.insert(0, notification);

      AppLogger.i(
          '✅ Notification added successfully (ID: ${notification.id})');
      notifyListeners();
    } catch (e) {
      AppLogger.e('❌ Error adding notification', e);
      rethrow;
    }
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String id) async {
    try {
      AppLogger.d('✓ Marking notification as read (ID: $id)');

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index == -1) {
        AppLogger.w('⚠️ Notification not found (ID: $id)');
        return;
      }

      final notification = _notifications[index];
      if (notification.isRead) {
        AppLogger.d('📬 Notification already marked as read (ID: $id)');
        return;
      }

      final updatedNotification = notification.copyWith(isRead: true);
      await _db
          .collection('notifications')
          .doc(id)
          .set(updatedNotification.toJson());

      _notifications[index] = updatedNotification;
      AppLogger.i('✅ Notification marked as read (ID: $id)');
      notifyListeners();
    } catch (e) {
      AppLogger.e('❌ Error marking notification as read', e);
      rethrow;
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      AppLogger.d('✓ Marking all notifications as read');

      if (unreadCount == 0) {
        AppLogger.d('📬 No unread notifications to mark');
        return;
      }

      final unread = unreadNotifications;
      for (final notification in unread) {
        final updatedNotification = notification.copyWith(isRead: true);
        await _db
            .collection('notifications')
            .doc(notification.id)
            .set(updatedNotification.toJson());

        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = updatedNotification;
        }
      }

      AppLogger.i('✅ All notifications marked as read (${unread.length})');
      notifyListeners();
    } catch (e) {
      AppLogger.e('❌ Error marking all notifications as read', e);
      rethrow;
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(String id) async {
    try {
      AppLogger.d('🗑️ Deleting notification (ID: $id)');
      await _db.collection('notifications').doc(id).delete();
      _notifications.removeWhere((notification) => notification.id == id);
      AppLogger.i('✅ Notification deleted successfully (ID: $id)');
      notifyListeners();
    } catch (e) {
      AppLogger.e('❌ Error deleting notification', e);
      rethrow;
    }
  }

  /// Elimina todas las notificaciones
  Future<void> deleteAllNotifications() async {
    try {
      AppLogger.d('🗑️ Deleting all notifications');

      if (_notifications.isEmpty) {
        AppLogger.d('🗑️ No notifications to delete');
        return;
      }

      final count = _notifications.length;
      for (final notification in _notifications) {
        await _db.collection('notifications').doc(notification.id).delete();
      }

      _notifications.clear();
      AppLogger.i('✅ All notifications deleted ($count)');
      notifyListeners();
    } catch (e) {
      AppLogger.e('❌ Error deleting all notifications', e);
      rethrow;
    }
  }

  /// Elimina todas las notificaciones leídas
  Future<void> deleteReadNotifications() async {
    try {
      AppLogger.d('🗑️ Deleting read notifications');

      final read = readNotifications;
      if (read.isEmpty) {
        AppLogger.d('🗑️ No read notifications to delete');
        return;
      }

      for (final notification in read) {
        await _db.collection('notifications').doc(notification.id).delete();
        _notifications.removeWhere((n) => n.id == notification.id);
      }

      AppLogger.i('✅ Read notifications deleted (${read.length})');
      notifyListeners();
    } catch (e) {
      AppLogger.e('❌ Error deleting read notifications', e);
      rethrow;
    }
  }
}
