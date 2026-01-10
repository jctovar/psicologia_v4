/// Utilidad para validación de URLs
///
/// Proporciona métodos estáticos para validar diferentes tipos de URLs
/// antes de lanzarlas con url_launcher.
class UrlValidator {
  /// Valida si una URL tiene un esquema HTTP o HTTPS válido
  ///
  /// Retorna `true` si la URL es válida y usa http o https,
  /// `false` en caso contrario.
  ///
  /// Ejemplo:
  /// ```dart
  /// UrlValidator.isValid('https://example.com'); // true
  /// UrlValidator.isValid('http://example.com'); // true
  /// UrlValidator.isValid('invalid-url'); // false
  /// ```
  static bool isValid(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https' || uri.scheme == 'http';
    } catch (_) {
      return false;
    }
  }

  /// Valida si una URL telefónica tiene el esquema 'tel:' válido
  ///
  /// Retorna `true` si la URL es válida para números telefónicos,
  /// `false` en caso contrario.
  ///
  /// Ejemplo:
  /// ```dart
  /// UrlValidator.isValidPhone('tel:+525512345678'); // true
  /// UrlValidator.isValidPhone('invalid'); // false
  /// ```
  static bool isValidPhone(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'tel' && uri.path.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Valida si una URL de correo tiene el esquema 'mailto:' válido
  ///
  /// Retorna `true` si la URL es válida para correos electrónicos,
  /// `false` en caso contrario.
  ///
  /// Ejemplo:
  /// ```dart
  /// UrlValidator.isValidEmail('mailto:example@domain.com'); // true
  /// UrlValidator.isValidEmail('invalid'); // false
  /// ```
  static bool isValidEmail(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'mailto' && uri.path.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Valida si una URL tiene algún esquema soportado
  ///
  /// Soporta: http, https, tel, mailto
  ///
  /// Retorna `true` si la URL tiene un esquema válido y soportado,
  /// `false` en caso contrario.
  static bool isValidAny(String url) {
    return isValid(url) || isValidPhone(url) || isValidEmail(url);
  }
}
