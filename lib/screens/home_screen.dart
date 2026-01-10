import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suayed/providers/home_provider.dart';
import 'package:suayed/widgets/app_drawer.dart';
import 'package:suayed/widgets/post_card.dart';
import 'package:suayed/widgets/shimmer_placeholder.dart';
import 'package:suayed/widgets/empty_state.dart';

/// Pantalla principal de la aplicación.
///
/// Muestra un grid responsivo de noticias/posts obtenidos desde la API
/// de WordPress. Implementa paginación infinita (lazy loading) y
/// pull-to-refresh para actualizar el contenido.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  /// Nombre de ruta para navegación
  static const String routeName = 'home';

  /// Título mostrado en el AppBar
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Controlador para detectar el scroll y cargar más contenido
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Detecta cuando el usuario se acerca al final de la lista
  /// para cargar más posts automáticamente (paginación infinita)
  void _onScroll() {
    // Umbral de 200px antes del final para iniciar la carga
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (homeProvider.hasMore && !homeProvider.isLoadingMore) {
        homeProvider.loadMore();
      }
    }
  }

  /// Calcula el número de columnas del grid según el ancho de pantalla.
  ///
  /// - Desktop (>=1200px): 4 columnas
  /// - Tablet horizontal (>=900px): 3 columnas
  /// - Tablet vertical (>=600px): 2 columnas
  /// - Móvil (<600px): 1 columna
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  /// Calcula la proporción de aspecto de las tarjetas según el dispositivo.
  ///
  /// Valores más altos = tarjetas más bajas (compactas)
  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 0.95; // Desktop
    if (width >= 900) return 0.9; // Tablet horizontal
    if (width >= 600) return 1.0; // Tablet vertical
    return 1.05; // Móvil
  }

  /// Calcula el padding horizontal para centrar el contenido
  /// dentro de un ancho máximo de 1400px
  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 1400.0;
    final basePadding = screenWidth > 600 ? 16.0 : 4.0;

    if (screenWidth > maxContentWidth) {
      // Centra el contenido en pantallas anchas
      return (screenWidth - maxContentWidth) / 2 + basePadding;
    }
    return basePadding;
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = _getHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w800),
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          // Estado de carga inicial - muestra placeholders shimmer
          if (homeProvider.isLoading && homeProvider.posts.isEmpty) {
            return GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isWideScreen ? 8.0 : 4.0,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: _getChildAspectRatio(context),
                crossAxisSpacing: isWideScreen ? 12.0 : 8.0,
                mainAxisSpacing: isWideScreen ? 12.0 : 8.0,
              ),
              // Muestra 6 placeholders mientras carga
              itemCount: 6,
              itemBuilder: (context, index) {
                return PostCardShimmer(isWideScreen: isWideScreen);
              },
            );
          }

          // Estado de error - muestra mensaje al usuario
          if (homeProvider.errorMessage != null) {
            return ErrorState(
              message: homeProvider.errorMessage!,
              onRetry: () => homeProvider.fetchPosts(refresh: true),
            );
          }

          // Calcula items totales incluyendo indicador de carga al final
          final itemCount =
              homeProvider.posts.length +
              (homeProvider.hasMore || homeProvider.isLoadingMore ? 1 : 0);

          // Grid principal con pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => homeProvider.fetchPosts(refresh: true),
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isWideScreen ? 8.0 : 4.0,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: _getChildAspectRatio(context),
                crossAxisSpacing: isWideScreen ? 12.0 : 8.0,
                mainAxisSpacing: isWideScreen ? 12.0 : 8.0,
              ),
              itemCount: itemCount,
              itemBuilder: (BuildContext context, int index) {
                // Indicador de carga al final de la lista
                if (index >= homeProvider.posts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                // Tarjeta del post
                final item = homeProvider.posts[index];
                return PostCard(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}
