import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    group('Constructor', () {
      test('crea instancia con todos los campos requeridos', () {
        final date = DateTime.now();
        final notification = NotificationModel(
          id: '123',
          title: 'Test Title',
          message: 'Test Message',
          date: date,
          isRead: false,
          type: NotificationType.general,
          data: {'key': 'value'},
        );

        expect(notification.id, '123');
        expect(notification.title, 'Test Title');
        expect(notification.message, 'Test Message');
        expect(notification.date, date);
        expect(notification.isRead, false);
        expect(notification.type, NotificationType.general);
        expect(notification.data, {'key': 'value'});
      });

      test('permite data como null', () {
        final notification = NotificationModel(
          id: '123',
          title: 'Test',
          message: 'Message',
          date: DateTime.now(),
          isRead: false,
          type: NotificationType.general,
          data: null,
        );

        expect(notification.data, isNull);
      });
    });

    group('fromJson', () {
      test('crea instancia valida desde JSON completo', () {
        final json = {
          'id': '456',
          'title': 'Notificación de prueba',
          'message': 'Este es el mensaje',
          'date': '2024-01-15T10:30:00.000',
          'isRead': true,
          'type': 'post',
          'data': {'post_id': '789'},
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.id, '456');
        expect(notification.title, 'Notificación de prueba');
        expect(notification.message, 'Este es el mensaje');
        expect(notification.date, DateTime.parse('2024-01-15T10:30:00.000'));
        expect(notification.isRead, true);
        expect(notification.type, NotificationType.post);
        expect(notification.data, {'post_id': '789'});
      });

      test('usa valores por defecto para campos null', () {
        final json = {
          'id': null,
          'title': null,
          'message': null,
          'date': null,
          'isRead': null,
          'type': null,
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.id, isNotEmpty); // Genera timestamp
        expect(notification.title, 'Sin título');
        expect(notification.message, '');
        expect(notification.date, isA<DateTime>());
        expect(notification.isRead, false);
        expect(notification.type, NotificationType.general);
        expect(notification.data, isNull);
      });

      test('lanza FormatException con JSON vacío', () {
        expect(
          () => NotificationModel.fromJson({}),
          throwsA(isA<FormatException>()),
        );
      });

      test('parsea id como int y lo convierte a String', () {
        final json = {
          'id': 12345,
          'title': 'Test',
          'message': 'Message',
          'date': '2024-01-15T10:30:00',
          'isRead': false,
          'type': 'general',
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.id, '12345');
      });

      test('parsea fecha como timestamp int', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch;
        final json = {
          'id': '1',
          'title': 'Test',
          'message': 'Message',
          'date': timestamp,
          'isRead': false,
          'type': 'general',
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.date.year, 2024);
        expect(notification.date.month, 1);
        expect(notification.date.day, 15);
      });

      test('parsea isRead desde string "true"', () {
        final json = {
          'id': '1',
          'title': 'Test',
          'message': 'Message',
          'date': '2024-01-15T10:30:00',
          'isRead': 'true',
          'type': 'general',
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.isRead, true);
      });

      test('parsea isRead desde string "1"', () {
        final json = {
          'id': '1',
          'title': 'Test',
          'message': 'Message',
          'date': '2024-01-15T10:30:00',
          'isRead': '1',
          'type': 'general',
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.isRead, true);
      });

      test('parsea isRead desde int 1', () {
        final json = {
          'id': '1',
          'title': 'Test',
          'message': 'Message',
          'date': '2024-01-15T10:30:00',
          'isRead': 1,
          'type': 'general',
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.isRead, true);
      });

      test('parsea todos los tipos de notificación', () {
        for (final type in NotificationType.values) {
          final json = {
            'id': '1',
            'title': 'Test',
            'message': 'Message',
            'date': '2024-01-15T10:30:00',
            'isRead': false,
            'type': type.toString().split('.').last,
          };

          final notification = NotificationModel.fromJson(json);
          expect(notification.type, type);
        }
      });

      test('ignora data si no es Map', () {
        final json = {
          'id': '1',
          'title': 'Test',
          'message': 'Message',
          'date': '2024-01-15T10:30:00',
          'isRead': false,
          'type': 'general',
          'data': 'not a map',
        };

        final notification = NotificationModel.fromJson(json);

        expect(notification.data, isNull);
      });
    });

    group('fromRemoteMessage', () {
      test('crea notificación desde mensaje de Firebase', () {
        final notification = NotificationModel.fromRemoteMessage(
          'msg_123',
          'Push Title',
          'Push Body',
          {'key': 'value'},
        );

        expect(notification.id, 'msg_123');
        expect(notification.title, 'Push Title');
        expect(notification.message, 'Push Body');
        expect(notification.isRead, false);
        expect(notification.type, NotificationType.general);
        expect(notification.data, {'key': 'value'});
      });

      test('usa valores por defecto si title y body son null', () {
        final notification = NotificationModel.fromRemoteMessage(
          'msg_456',
          null,
          null,
          {},
        );

        expect(notification.title, 'Notificación');
        expect(notification.message, '');
        expect(notification.data, isNull);
      });

      test('detecta tipo post si data contiene post_id', () {
        final notification = NotificationModel.fromRemoteMessage(
          'msg_789',
          'New Post',
          'Check it out',
          {'post_id': '123'},
        );

        expect(notification.type, NotificationType.post);
      });

      test('usa tipo de data si está especificado', () {
        final notification = NotificationModel.fromRemoteMessage(
          'msg_abc',
          'Event',
          'Upcoming event',
          {'type': 'event'},
        );

        expect(notification.type, NotificationType.event);
      });
    });

    group('toJson', () {
      test('serializa a JSON válido', () {
        final date = DateTime.parse('2024-01-15T10:30:00.000');
        final notification = NotificationModel(
          id: '123',
          title: 'Test Title',
          message: 'Test Message',
          date: date,
          isRead: true,
          type: NotificationType.alert,
          data: {'key': 'value'},
        );

        final json = notification.toJson();

        expect(json['id'], '123');
        expect(json['title'], 'Test Title');
        expect(json['message'], 'Test Message');
        expect(json['date'], '2024-01-15T10:30:00.000');
        expect(json['isRead'], true);
        expect(json['type'], 'alert');
        expect(json['data'], {'key': 'value'});
      });

      test('omite data si es null', () {
        final notification = NotificationModel(
          id: '123',
          title: 'Test',
          message: 'Message',
          date: DateTime.now(),
          isRead: false,
          type: NotificationType.general,
          data: null,
        );

        final json = notification.toJson();

        expect(json.containsKey('data'), false);
      });
    });

    group('fromJson y toJson reversibilidad', () {
      test('son reversibles para todos los tipos', () {
        for (final type in NotificationType.values) {
          final original = NotificationModel(
            id: 'test_${type.toString()}',
            title: 'Title for $type',
            message: 'Message for $type',
            date: DateTime.parse('2024-06-15T14:30:00.000'),
            isRead: true,
            type: type,
            data: {'type_test': type.toString()},
          );

          final json = original.toJson();
          final restored = NotificationModel.fromJson(json);

          expect(restored.id, original.id);
          expect(restored.title, original.title);
          expect(restored.message, original.message);
          expect(restored.date, original.date);
          expect(restored.isRead, original.isRead);
          expect(restored.type, original.type);
          expect(restored.data, original.data);
        }
      });
    });

    group('copyWith', () {
      test('crea copia con id modificado', () {
        final original = NotificationModel(
          id: '123',
          title: 'Test',
          message: 'Message',
          date: DateTime.now(),
          isRead: false,
          type: NotificationType.general,
        );

        final copy = original.copyWith(id: '456');

        expect(copy.id, '456');
        expect(copy.title, original.title);
        expect(copy.message, original.message);
      });

      test('crea copia con isRead modificado', () {
        final original = NotificationModel(
          id: '123',
          title: 'Test',
          message: 'Message',
          date: DateTime.now(),
          isRead: false,
          type: NotificationType.general,
        );

        final copy = original.copyWith(isRead: true);

        expect(copy.isRead, true);
        expect(copy.id, original.id);
      });

      test('crea copia con múltiples campos modificados', () {
        final original = NotificationModel(
          id: '123',
          title: 'Original Title',
          message: 'Original Message',
          date: DateTime(2024, 1, 1),
          isRead: false,
          type: NotificationType.general,
        );

        final newDate = DateTime(2024, 6, 15);
        final copy = original.copyWith(
          title: 'New Title',
          message: 'New Message',
          date: newDate,
          isRead: true,
          type: NotificationType.alert,
          data: {'new': 'data'},
        );

        expect(copy.id, original.id);
        expect(copy.title, 'New Title');
        expect(copy.message, 'New Message');
        expect(copy.date, newDate);
        expect(copy.isRead, true);
        expect(copy.type, NotificationType.alert);
        expect(copy.data, {'new': 'data'});
      });

      test('mantiene todos los valores si no se pasa ningún parámetro', () {
        final original = NotificationModel(
          id: '123',
          title: 'Test',
          message: 'Message',
          date: DateTime(2024, 1, 15),
          isRead: true,
          type: NotificationType.event,
          data: {'key': 'value'},
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.title, original.title);
        expect(copy.message, original.message);
        expect(copy.date, original.date);
        expect(copy.isRead, original.isRead);
        expect(copy.type, original.type);
        expect(copy.data, original.data);
      });
    });
  });

  group('NotificationType', () {
    test('tiene 4 valores', () {
      expect(NotificationType.values.length, 4);
    });

    test('contiene todos los tipos esperados', () {
      expect(NotificationType.values, contains(NotificationType.general));
      expect(NotificationType.values, contains(NotificationType.post));
      expect(NotificationType.values, contains(NotificationType.alert));
      expect(NotificationType.values, contains(NotificationType.event));
    });
  });
}
