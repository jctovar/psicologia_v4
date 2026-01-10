import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:suayed/providers/notification_provider.dart';
import 'package:suayed/providers/theme_provider.dart';
import 'package:suayed/routes/routes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

/// Drawer lateral con navegación principal, selección de tema y información de la app.
///
/// Incluye:
/// - Header con logo y nombre de la app
/// - Items de navegación a diferentes secciones
/// - Toggle de tema oscuro/claro
/// - Badge de notificaciones no leídas
/// - Información de versión y build
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  /// Información de la aplicación (versión, build, etc.)
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  /// Carga la información de la aplicación desde el sistema
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header con logo y nombre de la app
          _createHeader(),

          // Sección de navegación principal
          _createDrawerItem(
            icon: Icons.home_outlined,
            text: 'Inicio',
            onTap: () => Navigator.pushReplacementNamed(context, Routes.home),
          ),

          _createDrawerItem(
            icon: LineIcons.graduationCap,
            text: 'Profesores',
            onTap: () =>
                Navigator.pushReplacementNamed(context, Routes.teachers),
          ),
          _createDrawerItem(
            icon: LineIcons.users,
            text: 'Coordinación',
            onTap: () => Navigator.pushReplacementNamed(context, Routes.areas),
          ),

          // Separador visual
          const Divider(),

          // Sección de marcadores y notificaciones
          _createDrawerItem(
            icon: Icons.bookmark_outline_outlined,
            text: 'Marcadores',
            onTap: () =>
                Navigator.pushReplacementNamed(context, Routes.bookmarks),
          ),

          // Notificaciones con badge de cantidad no leída
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              return _createDrawerItemWithBadge(
                icon: Icons.notifications_outlined,
                text: 'Notificaciones',
                badge: unreadCount > 0 ? unreadCount.toString() : null,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  Routes.notifications,
                ),
              );
            },
          ),

          // Separador visual
          const Divider(),

          // Sección de información y ajustes
          _createDrawerItem(
            icon: Icons.help_outline,
            text: 'Acerca de',
            onTap: () => Navigator.pushReplacementNamed(context, Routes.about),
          ),

          // Separador visual
          const Divider(),

          // Toggle para cambiar tema (claro/oscuro)
          _createThemeToggle(context),

          // Footer con información de versión y build
          ListTile(
            title: Text(
              'Version: ${_packageInfo.version} / Build: ${_packageInfo.buildNumber}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el encabezado del drawer con logo y nombre de la app.
  ///
  /// Características:
  /// - Gradiente de colores (rosa a púrpura)
  /// - Adapta opacidad en modo oscuro
  /// - Logo centrado con sombra
  /// - Textos con sombra para mayor legibilidad
  Widget _createHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        // Gradiente con colores de la institución, adaptado a modo oscuro
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [
                // En modo oscuro: reduce opacidad para evitar demasiado brillo
                const Color(0xFFd81b60).withValues(alpha: 0.8),
                const Color(0xFF7B1FA2).withValues(alpha: 0.9),
              ]
            : [
                // En modo claro: colores sin modificar
                const Color(0xFFd81b60),
                const Color(0xFF7B1FA2),
              ],
        ),
        // Imagen de fondo con baja opacidad para textura
        image: const DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Stack(
        children: [
          // Contenido centrado: logo + textos
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Contenedor circular con logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Fondo blanco translúcido para resaltar el logo
                    color: Colors.white.withValues(alpha: 0.15),
                    boxShadow: [
                      // Sombra para profundidad
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: SvgPicture.asset(
                      'assets/logo_iztacala_compacto.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      semanticsLabel: 'Iztacala Logo',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Título principal: nombre de la carrera
                Text(
                  'Psicología SUAyED',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    // Sombra para mayor legibilidad sobre el gradiente
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Subtítulo: nombre de la institución
                Text(
                  'FES Iztacala',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un item de navegación del drawer.
  ///
  /// Parámetros:
  /// - [icon]: IconData del icono a mostrar
  /// - [text]: Texto/etiqueta del item
  /// - [onTap]: Callback cuando se toca el item
  ///
  /// Características:
  /// - Resalta el item activo (ruta actual) con color primario
  /// - Icono dentro de un contenedor redondeado
  /// - Icono chevron_right en items activos
  /// - Accesibilidad mejorada con Semantics
  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    final theme = Theme.of(context);
    // Obtiene la ruta actual del navegador
    final currentRoute = ModalRoute.of(context)?.settings.name;
    // Verifica si este item corresponde a la ruta actual
    final isActive = currentRoute == _getRouteForText(text);

    return Semantics(
      label: 'Navegar a $text',
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Fondo destacado para items activos
          color: isActive
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: ListTile(
          // Icono dentro de un contenedor redondeado
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // Color diferente si el item está activo
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
              size: 22,
            ),
          ),
          // Texto del item con peso variable
          title: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyLarge?.color,
              letterSpacing: 0.2,
            ),
          ),
          // Icono chevron solo en items activos
          trailing: isActive
              ? Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary,
                  size: 20,
                )
              : null,
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Convierte el texto de un item del drawer a su ruta correspondiente.
  ///
  /// Utilizado para detectar si el item actual está activo (ruta actual).
  String _getRouteForText(String text) {
    switch (text) {
      case 'Inicio':
        return Routes.home;
      case 'Profesores':
        return Routes.teachers;
      case 'Coordinación':
        return Routes.areas;
      case 'Marcadores':
        return Routes.bookmarks;
      case 'Notificaciones':
        return Routes.notifications;
      case 'Acerca de':
        return Routes.about;
      default:
        return '';
    }
  }

  /// Construye un item de navegación con badge de notificaciones no leídas.
  ///
  /// Similar a [_createDrawerItem] pero incluye:
  /// - Badge rojo en la esquina superior derecha del icono
  /// - Muestra el conteo de notificaciones (máximo 99+)
  /// - Accesibilidad mejorada indicando cantidad de notificaciones no leídas
  ///
  /// Parámetros:
  /// - [icon]: IconData del icono a mostrar
  /// - [text]: Texto/etiqueta del item
  /// - [badge]: Texto del badge (conteo de notificaciones, ej: "5")
  /// - [onTap]: Callback cuando se toca el item
  Widget _createDrawerItemWithBadge({
    required IconData icon,
    required String text,
    String? badge,
    required GestureTapCallback onTap,
  }) {
    final theme = Theme.of(context);
    // Obtiene la ruta actual del navegador
    final currentRoute = ModalRoute.of(context)?.settings.name;
    // Verifica si este item corresponde a la ruta actual
    final isActive = currentRoute == _getRouteForText(text);

    // Formatea el badge: limita a "99+" si el número es muy grande
    final badgeText = badge != null && badge.isNotEmpty
        ? (badge.length > 2 ? '99+' : badge)
        : null;

    // Etiqueta de accesibilidad con información del badge si existe
    final semanticLabel = badgeText != null
        ? 'Navegar a $text. $badgeText notificaciones no leídas'
        : 'Navegar a $text';

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Fondo destacado para items activos
          color: isActive
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: ListTile(
          // Icono con badge superpuesto
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              // Icono dentro de un contenedor redondeado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isActive
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                child: Icon(
                  icon,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                  size: 22,
                ),
              ),

              // Badge de notificaciones (si existe)
              if (badge != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Semantics(
                    label: '$badge notificaciones no leídas',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        // Color rojo para indicar notificaciones no leídas
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                        // Sombra para destacar el badge
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.error.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        badgeText ?? '',
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Texto del item con peso variable
          title: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyLarge?.color,
              letterSpacing: 0.2,
            ),
          ),

          // Icono chevron solo en items activos
          trailing: isActive
              ? Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary,
                  size: 20,
                )
              : null,
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Construye el toggle para cambiar entre tema claro y oscuro.
  ///
  /// Características:
  /// - Usa Consumer para reactividad con ThemeProvider
  /// - Detecta modo sistema si está configurado
  /// - Switch visual con iconos (sol/luna)
  /// - Accesibilidad mejorada con Semantics
  Widget _createThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);

        // Determina si está actualmente en modo oscuro
        // Considera: modo manual oscuro O (modo sistema Y brillo del dispositivo es oscuro)
        final isDark =
            themeProvider.isDarkMode ||
            (themeProvider.isSystemMode &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Semantics(
          label: 'Cambiar tema. Tema actual: ${isDark ? 'oscuro' : 'claro'}',
          hint: isDark
              ? 'Toca para activar tema claro'
              : 'Toca para activar tema oscuro',
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              // Icono a la izquierda (sol/luna)
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),

              // Etiqueta del toggle
              title: Text(
                'Tema oscuro',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),

              // Estado del switch (true = tema oscuro, false = tema claro)
              value: isDark,

              // Colores del switch
              activeTrackColor: theme.colorScheme.primary,
              activeThumbColor: theme.colorScheme.onPrimary,

              // Callback cuando cambia el switch
              onChanged: (value) {
                themeProvider.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
