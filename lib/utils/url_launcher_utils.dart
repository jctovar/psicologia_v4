import 'package:flutter/material.dart';
import 'package:suayed/utils/url_validator.dart';
import 'package:suayed/widgets/show_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utilidad centralizada para lanzar URLs con validación y manejo de errores.
///
/// Proporciona métodos estáticos para lanzar diferentes tipos de URLs (web, teléfono, email)
/// con validación automática y feedback consistente al usuario.
class UrlLauncherUtils {
  /// Lanza una URL web (http/https) con validación y feedback al usuario.
  ///
  /// Verifica que la URL sea válida antes de intentar abrirla.
  /// Muestra mensajes de error apropiados al usuario si la operación falla.
  ///
  /// [context]: BuildContext necesario para mostrar mensajes
  /// [url]: URL web completa a lanzar
  /// [errorMessage]: Mensaje personalizado si la URL es inválida
  static Future<void> launchWebUrl(
    BuildContext context,
    String url, {
    String errorMessage = 'URL inválida.',
  }) async {
    if (!context.mounted) return;

    if (!UrlValidator.isValid(url)) {
      showSnackBar(context, errorMessage);
      return;
    }

    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);

      if (!canLaunch) {
        if (context.mounted) {
          showSnackBar(context, 'No se puede abrir el enlace.');
        }
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Error al abrir el enlace.');
      }
    }
  }

  /// Lanza una URL telefónica (tel:) con validación y feedback al usuario.
  ///
  /// Agrega automáticamente el prefijo 'tel:' al número proporcionado.
  /// Verifica que el número sea válido antes de intentar realizar la llamada.
  ///
  /// [context]: BuildContext necesario para mostrar mensajes
  /// [phoneNumber]: Número telefónico (sin prefijo 'tel:')
  /// [errorMessage]: Mensaje personalizado si el número es inválido
  static Future<void> launchPhoneUrl(
    BuildContext context,
    String phoneNumber, {
    String errorMessage = 'Número telefónico inválido.',
  }) async {
    if (!context.mounted) return;

    final url = 'tel:$phoneNumber';

    if (!UrlValidator.isValidPhone(url)) {
      showSnackBar(context, errorMessage);
      return;
    }

    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);

      if (!canLaunch) {
        if (context.mounted) {
          showSnackBar(context, 'No se puede realizar la llamada.');
        }
        return;
      }

      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Error al intentar llamar.');
      }
    }
  }

  /// Lanza una URL de email (mailto:) con validación y feedback al usuario.
  ///
  /// Agrega automáticamente el prefijo 'mailto:' al email proporcionado.
  /// Verifica que el email sea válido antes de intentar abrir el cliente de correo.
  ///
  /// [context]: BuildContext necesario para mostrar mensajes
  /// [email]: Dirección de email (sin prefijo 'mailto:')
  /// [errorMessage]: Mensaje personalizado si el email es inválido
  static Future<void> launchEmailUrl(
    BuildContext context,
    String email, {
    String errorMessage = 'Email inválido.',
  }) async {
    if (!context.mounted) return;

    final url = email;

    if (!UrlValidator.isValidEmail(url)) {
      showSnackBar(context, errorMessage);
      return;
    }

    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);

      if (!canLaunch) {
        if (context.mounted) {
          showSnackBar(context, 'No se puede abrir el cliente de email.');
        }
        return;
      }

      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Error al abrir el email.');
      }
    }
  }
}
