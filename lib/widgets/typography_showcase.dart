import 'package:flutter/material.dart';

/// Widget de demostración de la jerarquía tipográfica de la aplicación.
///
/// Muestra todos los estilos de texto disponibles en el tema con ejemplos
/// de uso y descripciones. Útil para:
/// - Documentación visual del sistema de diseño
/// - Testing de legibilidad en diferentes dispositivos
/// - Referencia rápida para desarrolladores
///
/// Para ver esta pantalla en acción, agrégala temporalmente a las rutas
/// o muéstrala desde un botón de debug.
class TypographyShowcase extends StatelessWidget {
  const TypographyShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipografía de la App'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header informativo
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistema Tipográfico',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta pantalla muestra todos los estilos de texto disponibles '
                  'siguiendo Material Design 3. Usa estos estilos del tema '
                  'en lugar de definir fuentes manualmente.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // DISPLAY STYLES
          _buildSection(
            context,
            title: 'Display',
            description: 'Para títulos muy grandes en pantallas de bienvenida',
            children: [
              _buildTextExample(
                context,
                style: theme.textTheme.displayLarge,
                text: 'Display Large',
                usage: 'displayLarge • 57px • Poppins Bold',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.displayMedium,
                text: 'Display Medium',
                usage: 'displayMedium • 45px • Poppins Bold',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.displaySmall,
                text: 'Display Small',
                usage: 'displaySmall • 36px • Poppins SemiBold',
              ),
            ],
          ),

          const Divider(height: 32),

          // HEADLINE STYLES
          _buildSection(
            context,
            title: 'Headline',
            description: 'Para encabezados principales de página y sección',
            children: [
              _buildTextExample(
                context,
                style: theme.textTheme.headlineLarge,
                text: 'Headline Large',
                usage: 'headlineLarge • 32px • Poppins SemiBold',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.headlineMedium,
                text: 'Headline Medium',
                usage: 'headlineMedium • 28px • Poppins SemiBold',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.headlineSmall,
                text: 'Headline Small',
                usage: 'headlineSmall • 24px • Poppins SemiBold',
              ),
            ],
          ),

          const Divider(height: 32),

          // TITLE STYLES
          _buildSection(
            context,
            title: 'Title',
            description: 'Para títulos de tarjetas, diálogos y listas',
            children: [
              _buildTextExample(
                context,
                style: theme.textTheme.titleLarge,
                text: 'Title Large - Título de Diálogo',
                usage: 'titleLarge • 22px • Montserrat Bold',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.titleMedium,
                text: 'Title Medium - Título de Tarjeta (MÁS USADO)',
                usage: 'titleMedium • 16px • Montserrat SemiBold',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.titleSmall,
                text: 'Title Small - Subtítulo',
                usage: 'titleSmall • 14px • Montserrat SemiBold',
              ),
            ],
          ),

          const Divider(height: 32),

          // BODY STYLES
          _buildSection(
            context,
            title: 'Body',
            description: 'Para contenido principal y descripciones',
            children: [
              _buildTextExample(
                context,
                style: theme.textTheme.bodyLarge,
                text: 'Body Large - Este es el estilo recomendado para párrafos '
                    'y contenido principal. Tiene un tamaño de 16px con altura '
                    'de línea optimizada (1.5) para lectura extendida.',
                usage: 'bodyLarge • 16px • Montserrat Regular',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.bodyMedium,
                text: 'Body Medium - Para texto secundario o información '
                    'complementaria. 14px con altura de línea de 1.43.',
                usage: 'bodyMedium • 14px • Montserrat Regular',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.bodySmall,
                text: 'Body Small - Para metadatos, fechas, disclaimers. 12px.',
                usage: 'bodySmall • 12px • Montserrat Regular',
              ),
            ],
          ),

          const Divider(height: 32),

          // LABEL STYLES
          _buildSection(
            context,
            title: 'Label',
            description: 'Para botones, chips, tabs y badges',
            children: [
              _buildTextExample(
                context,
                style: theme.textTheme.labelLarge,
                text: 'Label Large - Botones Grandes',
                usage: 'labelLarge • 14px • Montserrat SemiBold',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.labelMedium,
                text: 'Label Medium - Chips y Tabs',
                usage: 'labelMedium • 12px • Montserrat SemiBold',
              ),
              _buildTextExample(
                context,
                style: theme.textTheme.labelSmall,
                text: 'Label Small - Badges',
                usage: 'labelSmall • 11px • Montserrat Medium',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Ejemplo de uso en contexto
          _buildContextExample(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextExample(
    BuildContext context, {
    required TextStyle? style,
    required String text,
    required String usage,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: style),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              usage,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextExample(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejemplo en Contexto',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Así se vería una tarjeta de noticia típica:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Simulación de tarjeta de noticia
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Investigación',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título
                  Text(
                    'Nuevo Estudio sobre Psicología Cognitiva',
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    'Investigadores de la FES Iztacala publican hallazgos '
                    'importantes sobre procesos de memoria y aprendizaje en '
                    'estudiantes universitarios.',
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Metadatos
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hace 2 días',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dr. García',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botón
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Leer Más',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
