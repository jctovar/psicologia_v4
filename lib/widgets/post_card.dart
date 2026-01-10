import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/providers/bookmark_provider.dart';
import 'package:suayed/widgets/show_snack_bar.dart';
import 'package:suayed/widgets/thumbnail_image.dart';
import 'package:suayed/screens/post_detail.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';

/// Widget de tarjeta para mostrar un post/noticia en el grid principal.
///
/// Muestra la imagen destacada, título y fecha de publicación del post.
/// Incluye animación Hero para transiciones suaves hacia [PostDetail].
/// Se adapta automáticamente a diferentes tamaños de pantalla.
class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.item});

  /// Modelo del post a mostrar
  final PostModel item;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Formatea la fecha de publicación en formato relativo (ej: "hace 2 días")
  String _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  /// Navega a la pantalla de detalle del post
  void _openFeed(BuildContext context, PostModel item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(
      builder: (context) => PostDetail(
        postModel: item,
        heroTag: 'post-image',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Semantics(
      label: 'Noticia: ${widget.item.title}. Publicada ${_datePub(widget.item.date)}',
      hint: 'Toca para leer la noticia completa',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Card(
              elevation: _isHovered ? 8 : 3,
              // Recorta el contenido para que la imagen llegue hasta los bordes
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                onTap: () => _openFeed(context, widget.item),
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
              // Imagen destacada - ocupa 60% de la altura (flex: 3)
              Expanded(
                flex: 3,
                child: Semantics(
                  label: 'Imagen de portada de ${widget.item.title}',
                  image: true,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'post-image-${widget.item.id}',
                        child: ThumbnailImage(
                          imageUrl: widget.item.image,
                          memCacheWidth: 800,
                        ),
                      ),
                      // Gradiente sutil en la parte inferior de la imagen
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Área de contenido - ocupa 40% de la altura (flex: 2)
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 16.0 : 14.0,
                  vertical: isWideScreen ? 12.0 : 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del post
                    Expanded(
                      child: Text(
                        widget.item.title.toUpperCase(),
                        maxLines: isWideScreen ? 2 : 3,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: isWideScreen ? 14.5 : 15.0,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              letterSpacing: 0.3,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Fecha de publicación con icono
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _datePub(widget.item.date),
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Botones de acción (compartir, guardar)
            PostActions(item: widget.item),
          ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget con los botones de acción para un post.
///
/// Incluye botones para compartir el enlace del post y
/// guardarlo en marcadores locales.
class PostActions extends StatelessWidget {
  const PostActions({super.key, required this.item});

  /// Modelo del post asociado a las acciones
  final PostModel item;

  /// Guarda el post en marcadores locales usando [BookmarkProvider]
  Future<void> _savePost(BuildContext context, PostModel item) async {
    try {
      await Provider.of<BookmarkProvider>(
        context,
        listen: false,
      ).addBookmark(item);
      if (context.mounted) {
        showSnackBar(context, 'Elemento guardado en marcadores...');
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Error al guardar el marcador.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final iconSize = isWideScreen ? 19.0 : 17.0;
    final padding = isWideScreen ? 16.0 : 12.0;

    return Container(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Botón para compartir el enlace del post
          Semantics(
            label: 'Compartir noticia',
            button: true,
            child: IconButton.filledTonal(
              onPressed: () {
                HapticFeedback.mediumImpact();
                try {
                  SharePlus.instance.share(
                    ShareParams(subject: item.link, uri: Uri.tryParse(item.link)),
                  );
                } catch (e) {
                  showSnackBar(context, 'Error al compartir.');
                }
              },
              icon: Icon(Icons.share_outlined, size: iconSize),
              tooltip: 'Compartir',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón para guardar en marcadores
          Semantics(
            label: 'Guardar en marcadores',
            button: true,
            child: IconButton.filledTonal(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _savePost(context, item);
              },
              icon: Icon(Icons.bookmark_outline, size: iconSize),
              tooltip: 'Guardar',
              style: IconButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
