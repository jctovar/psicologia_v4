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
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.item});

  /// Modelo del post a mostrar
  final PostModel item;

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
      label: 'Noticia: ${item.title}. Publicada ${_datePub(item.date)}',
      hint: 'Toca para leer la noticia completa',
      button: true,
      child: Card(
        elevation: 2,
        // Recorta el contenido para que la imagen llegue hasta los bordes
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          onTap: () => _openFeed(context, item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Imagen destacada - ocupa 60% de la altura (flex: 3)
              Expanded(
                flex: 3,
                child: Semantics(
                  label: 'Imagen de portada de ${item.title}',
                  image: true,
                  child: Hero(
                    tag: 'post-image-${item.id}',
                    child: ThumbnailImage(
                      imageUrl: item.image,
                      memCacheWidth: 800,
                    ),
                  ),
                ),
              ),
            // Área de contenido - ocupa 40% de la altura (flex: 2)
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 16.0 : 12.0,
                  vertical: isWideScreen ? 10.0 : 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del post
                    Expanded(
                      child: Text(
                        item.title.toUpperCase(),
                        maxLines: isWideScreen ? 2 : 3,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: isWideScreen ? 15.0 : 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Fecha de publicación
                    Text(
                      _datePub(item.date),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Botones de acción (compartir, guardar)
            PostActions(item: item),
          ],
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
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final iconSize = isWideScreen ? 20.0 : 18.0;
    final padding = isWideScreen ? 16.0 : 14.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, padding, padding),
      child: OverflowBar(
        alignment: MainAxisAlignment.end,
        spacing: isWideScreen ? 8.0 : 4.0,
        children: <Widget>[
          // Botón para compartir el enlace del post
          Semantics(
            label: 'Compartir noticia',
            button: true,
            child: IconButton.outlined(
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
              icon: Icon(Icons.share, color: Theme.of(context).iconTheme.color),
              iconSize: iconSize,
              tooltip: 'Compartir',
            ),
          ),
          // Botón para guardar en marcadores
          Semantics(
            label: 'Guardar en marcadores',
            button: true,
            child: IconButton.outlined(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _savePost(context, item);
              },
              icon: Icon(Icons.bookmark, color: Theme.of(context).iconTheme.color),
              iconSize: iconSize,
              tooltip: 'Guardar',
            ),
          ),
        ],
      ),
    );
  }
}
