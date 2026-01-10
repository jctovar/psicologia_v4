import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/models/notification_model.dart';
import 'package:suayed/providers/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationProvider', () {
    late NotificationProvider notificationProvider;

    setUp(() async {
      // Crear provider y esperar a que se inicialice
      notificationProvider = NotificationProvider();
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() async {
      // Limpiar todas las notificaciones después de cada test
      try {
        await notificationProvider.deleteAllNotifications();
      } catch (e) {
        // Ignorar errores en cleanup
      }
    });

    test('estado inicial está vacío', () {
      expect(notificationProvider.notifications, isEmpty);
      expect(notificationProvider.unreadCount, 0);
      expect(notificationProvider.isInitialized, true);
    });

    test('addNotification agrega una notificación', () async {
      // Arrange
      final notification = NotificationModel(
        id: 'test-1',
        title: 'Test Notification',
        message: 'Test Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );

      // Act
      await notificationProvider.addNotification(notification);

      // Assert
      expect(notificationProvider.notifications.length, 1);
      expect(notificationProvider.notifications.first.id, 'test-1');
      expect(notificationProvider.notifications.first.title, 'Test Notification');
      expect(notificationProvider.unreadCount, 1);
    });

    test('addNotification evita duplicados', () async {
      // Arrange
      final notification = NotificationModel(
        id: 'test-duplicate',
        title: 'Duplicate Test',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );

      // Act
      await notificationProvider.addNotification(notification);
      await notificationProvider.addNotification(notification);

      // Assert
      expect(notificationProvider.notifications.length, 1);
      expect(notificationProvider.notifications.first.id, 'test-duplicate');
    });

    test('markAsRead marca notificación como leída', () async {
      // Arrange
      final notification = NotificationModel(
        id: 'test-read',
        title: 'Test Read',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      await notificationProvider.addNotification(notification);

      // Act
      await notificationProvider.markAsRead('test-read');

      // Assert
      expect(notificationProvider.notifications.first.isRead, true);
      expect(notificationProvider.unreadCount, 0);
    });

    test('markAsRead no hace nada si notificación no existe', () async {
      // Act & Assert - No debería lanzar excepción
      await notificationProvider.markAsRead('non-existent-id');
      expect(notificationProvider.notifications, isEmpty);
    });

    test('markAsRead no hace nada si ya está marcada como leída', () async {
      // Arrange
      final notification = NotificationModel(
        id: 'test-already-read',
        title: 'Already Read',
        message: 'Message',
        date: DateTime.now(),
        isRead: true,
        type: NotificationType.general,
      );
      await notificationProvider.addNotification(notification);

      int notificationCount = 0;
      notificationProvider.addListener(() {
        notificationCount++;
      });

      // Act
      await notificationProvider.markAsRead('test-already-read');

      // Assert - No debería notificar porque no hubo cambio
      expect(notificationCount, 0);
    });

    test('markAllAsRead marca todas las notificaciones', () async {
      // Arrange
      final notification1 = NotificationModel(
        id: 'test-all-1',
        title: 'Test 1',
        message: 'Message 1',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      final notification2 = NotificationModel(
        id: 'test-all-2',
        title: 'Test 2',
        message: 'Message 2',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.post,
      );
      await notificationProvider.addNotification(notification1);
      await notificationProvider.addNotification(notification2);

      // Act
      await notificationProvider.markAllAsRead();

      // Assert
      expect(notificationProvider.unreadCount, 0);
      expect(notificationProvider.readNotifications.length, 2);
    });

    test('markAllAsRead no hace nada si no hay no leídas', () async {
      // Arrange - Sin notificaciones

      // Act & Assert
      await notificationProvider.markAllAsRead();
      expect(notificationProvider.notifications, isEmpty);
    });

    test('deleteNotification elimina una notificación', () async {
      // Arrange
      final notification = NotificationModel(
        id: 'test-delete',
        title: 'Test Delete',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      await notificationProvider.addNotification(notification);

      // Act
      await notificationProvider.deleteNotification('test-delete');

      // Assert
      expect(notificationProvider.notifications, isEmpty);
    });

    test('deleteAllNotifications elimina todas', () async {
      // Arrange
      final notification1 = NotificationModel(
        id: 'test-delete-all-1',
        title: 'Test 1',
        message: 'Message 1',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      final notification2 = NotificationModel(
        id: 'test-delete-all-2',
        title: 'Test 2',
        message: 'Message 2',
        date: DateTime.now(),
        isRead: true,
        type: NotificationType.alert,
      );
      await notificationProvider.addNotification(notification1);
      await notificationProvider.addNotification(notification2);

      // Act
      await notificationProvider.deleteAllNotifications();

      // Assert
      expect(notificationProvider.notifications, isEmpty);
      expect(notificationProvider.unreadCount, 0);
    });

    test('deleteAllNotifications no hace nada si está vacío', () async {
      // Act & Assert
      await notificationProvider.deleteAllNotifications();
      expect(notificationProvider.notifications, isEmpty);
    });

    test('deleteReadNotifications solo elimina las leídas', () async {
      // Arrange
      final unread = NotificationModel(
        id: 'test-unread',
        title: 'Unread',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      final read1 = NotificationModel(
        id: 'test-read-1',
        title: 'Read 1',
        message: 'Message',
        date: DateTime.now(),
        isRead: true,
        type: NotificationType.post,
      );
      final read2 = NotificationModel(
        id: 'test-read-2',
        title: 'Read 2',
        message: 'Message',
        date: DateTime.now(),
        isRead: true,
        type: NotificationType.alert,
      );

      await notificationProvider.addNotification(unread);
      await notificationProvider.addNotification(read1);
      await notificationProvider.addNotification(read2);

      // Act
      await notificationProvider.deleteReadNotifications();

      // Assert
      expect(notificationProvider.notifications.length, 1);
      expect(notificationProvider.notifications.first.id, 'test-unread');
      expect(notificationProvider.unreadCount, 1);
    });

    test('deleteReadNotifications no hace nada si no hay leídas', () async {
      // Arrange
      final notification = NotificationModel(
        id: 'test-only-unread',
        title: 'Unread',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      await notificationProvider.addNotification(notification);

      // Act
      await notificationProvider.deleteReadNotifications();

      // Assert
      expect(notificationProvider.notifications.length, 1);
    });

    test('unreadNotifications retorna solo no leídas', () async {
      // Arrange
      final unread = NotificationModel(
        id: 'test-unread-filter',
        title: 'Unread',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      final read = NotificationModel(
        id: 'test-read-filter',
        title: 'Read',
        message: 'Message',
        date: DateTime.now(),
        isRead: true,
        type: NotificationType.post,
      );

      await notificationProvider.addNotification(unread);
      await notificationProvider.addNotification(read);

      // Assert
      expect(notificationProvider.unreadNotifications.length, 1);
      expect(notificationProvider.unreadNotifications.first.id, 'test-unread-filter');
    });

    test('readNotifications retorna solo leídas', () async {
      // Arrange
      final unread = NotificationModel(
        id: 'test-unread-filter-2',
        title: 'Unread',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      final read = NotificationModel(
        id: 'test-read-filter-2',
        title: 'Read',
        message: 'Message',
        date: DateTime.now(),
        isRead: true,
        type: NotificationType.post,
      );

      await notificationProvider.addNotification(unread);
      await notificationProvider.addNotification(read);

      // Assert
      expect(notificationProvider.readNotifications.length, 1);
      expect(notificationProvider.readNotifications.first.id, 'test-read-filter-2');
    });

    test('notifica a listeners en cambios', () async {
      // Arrange
      int notificationCount = 0;
      notificationProvider.addListener(() {
        notificationCount++;
      });

      final notification = NotificationModel(
        id: 'test-listener',
        title: 'Listener Test',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );

      // Act
      await notificationProvider.addNotification(notification);

      // Assert
      expect(notificationCount, greaterThanOrEqualTo(1));
    });

    test('fetchNotifications persiste y carga correctamente', () async {
      // Arrange
      final notification = NotificationModel(
        id: 'test-persist',
        title: 'Persist Test',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      await notificationProvider.addNotification(notification);

      // Act - Crear nuevo provider (debería cargar desde storage)
      final newProvider = NotificationProvider();
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(newProvider.notifications.length, 1);
      expect(newProvider.notifications.first.id, 'test-persist');

      // Cleanup
      await newProvider.deleteAllNotifications();
    });

    test('notificaciones se ordenan por fecha (más reciente primero)', () async {
      // Arrange
      final old = NotificationModel(
        id: 'test-old',
        title: 'Old',
        message: 'Message',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: NotificationType.general,
      );
      final recent = NotificationModel(
        id: 'test-recent',
        title: 'Recent',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.post,
      );

      // Act - Agregar en orden inverso
      await notificationProvider.addNotification(old);
      await notificationProvider.addNotification(recent);

      // Assert - Debería estar ordenado con el más reciente primero
      expect(notificationProvider.notifications.first.id, 'test-recent');
      expect(notificationProvider.notifications.last.id, 'test-old');
    });

    test('múltiples tipos de notificaciones son soportados', () async {
      // Arrange
      final general = NotificationModel(
        id: 'test-general',
        title: 'General',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.general,
      );
      final post = NotificationModel(
        id: 'test-post',
        title: 'Post',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.post,
      );
      final alert = NotificationModel(
        id: 'test-alert',
        title: 'Alert',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.alert,
      );
      final event = NotificationModel(
        id: 'test-event',
        title: 'Event',
        message: 'Message',
        date: DateTime.now(),
        isRead: false,
        type: NotificationType.event,
      );

      // Act
      await notificationProvider.addNotification(general);
      await notificationProvider.addNotification(post);
      await notificationProvider.addNotification(alert);
      await notificationProvider.addNotification(event);

      // Assert
      expect(notificationProvider.notifications.length, 4);
      expect(notificationProvider.notifications.any((n) => n.type == NotificationType.general), true);
      expect(notificationProvider.notifications.any((n) => n.type == NotificationType.post), true);
      expect(notificationProvider.notifications.any((n) => n.type == NotificationType.alert), true);
      expect(notificationProvider.notifications.any((n) => n.type == NotificationType.event), true);
    });
  });
}
