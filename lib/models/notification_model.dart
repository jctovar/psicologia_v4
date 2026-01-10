class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
    required this.type,
    this.data,
  });

  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? data;

  /// Crea una instancia de NotificationModel desde JSON con validación null-safe.
  ///
  /// Proporciona valores por defecto seguros si algún campo es null o inválido:
  /// - id: timestamp generado si es null
  /// - title: 'Sin título' si es null
  /// - message: '' si es null
  /// - date: DateTime.now() si es null o inválido
  /// - isRead: false si es null
  /// - type: NotificationType.general si es null o inválido
  /// - data: null si es null
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      if (json.isEmpty) {
        throw FormatException('JSON vacío al parsear NotificationModel');
      }

      final String id = _parseString(json['id']) ??
          DateTime.now().millisecondsSinceEpoch.toString();

      final String title = _parseString(json['title']) ?? 'Sin título';

      final String message = _parseString(json['message']) ?? '';

      final DateTime date = _parseDate(json['date']) ?? DateTime.now();

      final bool isRead = _parseBool(json['isRead']) ?? false;

      final NotificationType type = _parseNotificationType(json['type']) ??
          NotificationType.general;

      final Map<String, dynamic>? data = json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null;

      return NotificationModel(
        id: id,
        title: title,
        message: message,
        date: date,
        isRead: isRead,
        type: type,
        data: data,
      );
    } catch (e) {
      throw FormatException('Error al parsear NotificationModel: $e');
    }
  }

  /// Crea una instancia desde RemoteMessage de Firebase
  factory NotificationModel.fromRemoteMessage(
    String messageId,
    String? title,
    String? body,
    Map<String, dynamic> data,
  ) {
    // Determinar el tipo basado en los datos del mensaje
    NotificationType type = NotificationType.general;
    if (data.containsKey('type')) {
      type = _parseNotificationType(data['type']) ?? NotificationType.general;
    } else if (data.containsKey('post_id')) {
      type = NotificationType.post;
    }

    return NotificationModel(
      id: messageId,
      title: title ?? 'Notificación',
      message: body ?? '',
      date: DateTime.now(),
      isRead: false,
      type: type,
      data: data.isNotEmpty ? data : null,
    );
  }

  /// Parsea un string de manera segura
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Parsea una fecha de manera segura
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Parsea un bool de manera segura
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) return value != 0;
    return null;
  }

  /// Parsea el tipo de notificación
  static NotificationType? _parseNotificationType(dynamic value) {
    if (value == null) return null;
    if (value is NotificationType) return value;
    if (value is String) {
      try {
        return NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "message": message,
    "date": date.toIso8601String(),
    "isRead": isRead,
    "type": type.toString().split('.').last,
    if (data != null) "data": data,
  };

  /// Crea una copia de la notificación con los campos especificados modificados
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? date,
    bool? isRead,
    NotificationType? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}

/// Tipos de notificación soportados
enum NotificationType {
  general,  // Notificación general
  post,     // Notificación relacionada con un post
  alert,    // Alerta importante
  event,    // Evento o actividad
}
