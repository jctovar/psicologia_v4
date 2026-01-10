import 'package:flutter/material.dart';

/// Ejemplos prácticos de uso de tipografía en la aplicación.
///
/// Este archivo contiene ejemplos de código que muestran cómo usar
/// correctamente el sistema tipográfico en diferentes contextos.
///
/// NO es un widget ejecutable, sino una referencia de código.

// ignore_for_file: unused_element

/// Ejemplo 1: Tarjeta de Noticia
class _ExampleNewsCard extends StatelessWidget {
  const _ExampleNewsCard({
    required this.title,
    required this.description,
    required this.date,
    required this.author,
  });

  final String title;
  final String description;
  final String date;
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la noticia - titleMedium (más usado)
            Text(
              title,
              style: theme.textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Descripción - bodyMedium
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Metadatos - bodySmall
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(date, style: theme.textTheme.bodySmall),
                const SizedBox(width: 16),
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(author, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ejemplo 2: Encabezado de Sección
class _ExampleSectionHeader extends StatelessWidget {
  const _ExampleSectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección - headlineMedium
        Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),

        // Subtítulo - bodyLarge
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

/// Ejemplo 3: Lista de Profesores
class _ExampleTeacherList extends StatelessWidget {
  const _ExampleTeacherList({required this.teachers});

  final List<Map<String, String>> teachers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          // Nombre - titleMedium
          title: Text(
            teacher['name'] ?? '',
            style: theme.textTheme.titleMedium,
          ),
          // Especialidad - bodyMedium
          subtitle: Text(
            teacher['specialty'] ?? '',
            style: theme.textTheme.bodyMedium,
          ),
          // Email - bodySmall
          trailing: Text(
            teacher['email'] ?? '',
            style: theme.textTheme.bodySmall,
          ),
        );
      },
    );
  }
}

/// Ejemplo 4: Pantalla de Detalle de Artículo
class _ExampleArticleDetail extends StatelessWidget {
  const _ExampleArticleDetail({
    required this.title,
    required this.content,
    required this.author,
    required this.date,
  });

  final String title;
  final String content;
  final String author;
  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del artículo - headlineMedium
          Text(
            title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),

          // Metadatos - bodySmall
          Row(
            children: [
              Text('Por ', style: theme.textTheme.bodySmall),
              Text(
                author,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text('• ', style: theme.textTheme.bodySmall),
              const SizedBox(width: 8),
              Text(date, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 24),

          // Contenido del artículo - bodyLarge (óptimo para lectura)
          Text(
            content,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Ejemplo 5: Diálogo de Confirmación
class _ExampleDialog extends StatelessWidget {
  const _ExampleDialog({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      // Título del diálogo - titleLarge
      title: Text(
        title,
        style: theme.textTheme.titleLarge,
      ),
      // Mensaje - bodyMedium
      content: Text(
        message,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        // Botón cancelar - labelLarge (heredado del tema)
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        // Botón confirmar - labelLarge (heredado del tema)
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

/// Ejemplo 6: Chips y Filtros
class _ExampleFilters extends StatelessWidget {
  const _ExampleFilters({required this.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: categories.map((category) {
        return FilterChip(
          // labelMedium (heredado del tema de chip)
          label: Text(category),
          onSelected: (selected) {
            // Handle selection
          },
        );
      }).toList(),
    );
  }
}

/// Ejemplo 7: Badge con Notificaciones
class _ExampleBadge extends StatelessWidget {
  const _ExampleBadge({
    required this.count,
    required this.child,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              // Número de notificaciones - labelSmall
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Ejemplo 8: Pantalla de Bienvenida
class _ExampleWelcomeScreen extends StatelessWidget {
  const _ExampleWelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo u imagen
            const Icon(Icons.psychology, size: 100),
            const SizedBox(height: 32),

            // Título principal - displayMedium
            Text(
              'Psicología SUAyED',
              style: theme.textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Subtítulo - headlineSmall
            Text(
              'FES Iztacala UNAM',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Descripción - bodyLarge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Tu fuente de información sobre noticias, eventos y recursos académicos.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ejemplo 9: Modificar Estilos del Tema
class _ExampleCustomStyles extends StatelessWidget {
  const _ExampleCustomStyles();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Usar estilo base y modificar color
        Text(
          'Título con color personalizado',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),

        // Usar estilo base y modificar peso
        Text(
          'Texto con énfasis extra',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        // Usar estilo base y modificar decoración
        Text(
          'Enlace subrayado',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),

        // Combinar múltiples modificaciones
        Text(
          'Texto especial',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

/// Ejemplo 10: Estados de Carga y Error
class _ExampleStates extends StatelessWidget {
  const _ExampleStates();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Estado de carga
        Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            // Mensaje de carga - bodyMedium
            Text(
              'Cargando contenido...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 48),

        // Estado de error
        Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            // Título de error - titleLarge
            Text(
              'Error al cargar',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            // Mensaje de error - bodyMedium
            Text(
              'No se pudo conectar al servidor. Verifica tu conexión.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),

        const SizedBox(height: 48),

        // Estado vacío
        Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.iconTheme.color,
            ),
            const SizedBox(height: 16),
            // Título - titleLarge
            Text(
              'No hay resultados',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // Mensaje - bodyMedium
            Text(
              'No se encontraron elementos para mostrar.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
