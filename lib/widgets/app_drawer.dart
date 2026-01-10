import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:suayed/providers/notification_provider.dart';
import 'package:suayed/providers/theme_provider.dart';
import 'package:suayed/routes/routes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
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
          _createHeader(),
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

          const Divider(),
          _createDrawerItem(
            icon: Icons.bookmark_outline_outlined,
            text: 'Marcadores',
            onTap: () =>
                Navigator.pushReplacementNamed(context, Routes.bookmarks),
          ),
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
          const Divider(),
          _createDrawerItem(
            icon: Icons.help_outline,
            text: 'Acerca de',
            onTap: () => Navigator.pushReplacementNamed(context, Routes.about),
          ),
          const Divider(),
          _createThemeToggle(context),
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

  Widget _createHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [
                const Color(0xFFd81b60).withValues(alpha: 0.8),
                const Color(0xFF7B1FA2).withValues(alpha: 0.9),
              ]
            : [
                const Color(0xFFd81b60),
                const Color(0xFF7B1FA2),
              ],
        ),
        // Superposición de imagen de fondo con blend
        image: const DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Stack(
        children: [
          // Logo central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Contenedor con sombra para el logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    boxShadow: [
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
                // Texto informativo
                Text(
                  'Psicología SUAyED',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
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

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    final theme = Theme.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == _getRouteForText(text);

    return Semantics(
      label: 'Navegar a $text',
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: ListTile(
          leading: Container(
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

  Widget _createDrawerItemWithBadge({
    required IconData icon,
    required String text,
    String? badge,
    required GestureTapCallback onTap,
  }) {
    final theme = Theme.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == _getRouteForText(text);
    final badgeText = badge != null && badge.isNotEmpty
        ? (badge.length > 2 ? '99+' : badge)
        : null;
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
          color: isActive
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: ListTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
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
              if (badge != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Semantics(
                    label: '$badge notificaciones no leídas',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
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

  Widget _createThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
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
              title: Text(
                'Tema oscuro',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              value: isDark,
              activeTrackColor: theme.colorScheme.primary,
              activeThumbColor: theme.colorScheme.onPrimary,
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
