import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar estados vacíos de manera amigable.
///
/// Muestra un icono, título, mensaje descriptivo y opcionalmente un botón
/// de acción para guiar al usuario sobre qué hacer.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.iconSize = 80.0,
  });

  /// Icono a mostrar (ej: Icons.bookmark_border)
  final IconData icon;

  /// Título principal del estado vacío
  final String title;

  /// Mensaje descriptivo que explica la situación
  final String message;

  /// Texto del botón de acción (opcional)
  final String? actionLabel;

  /// Callback cuando se presiona el botón de acción
  final VoidCallback? onActionPressed;

  /// Tamaño del icono
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Semantics(
      label: '$title. $message',
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isWideScreen ? 48.0 : 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono con círculo de fondo suave
              Semantics(
                label: 'Icono de estado vacío',
                image: true,
                child: Container(
                  width: iconSize + 40,
                  height: iconSize + 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  ),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ),

            SizedBox(height: isWideScreen ? 32.0 : 24.0),

            // Título
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isWideScreen ? 24.0 : 20.0,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12.0),

            // Mensaje descriptivo
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Botón de acción (si se proporciona)
            if (actionLabel != null && onActionPressed != null) ...[
              SizedBox(height: isWideScreen ? 32.0 : 24.0),
              Semantics(
                label: actionLabel,
                hint: 'Botón de acción',
                button: true,
                child: FilledButton.icon(
                  onPressed: onActionPressed,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(actionLabel!),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}

/// Widget para mostrar estado de error con opción de reintentar.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  /// Mensaje de error a mostrar
  final String message;

  /// Callback cuando se presiona el botón de reintentar
  final VoidCallback? onRetry;

  /// Texto del botón de reintentar
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Semantics(
      label: 'Error: $message',
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isWideScreen ? 48.0 : 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de error
              Semantics(
                label: 'Icono de error',
                image: true,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 80,
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                  ),
                ),
              ),

            SizedBox(height: isWideScreen ? 32.0 : 24.0),

            // Título
            Text(
              'Algo salió mal',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isWideScreen ? 24.0 : 20.0,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12.0),

            // Mensaje de error
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Botón de reintentar (si se proporciona)
            if (onRetry != null) ...[
              SizedBox(height: isWideScreen ? 32.0 : 24.0),
              Semantics(
                label: retryLabel,
                hint: 'Reintentar la operación',
                button: true,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryLabel),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}
