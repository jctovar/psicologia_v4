import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:suayed/providers/bookmark_provider.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/models/storage_post_model.dart';
import 'package:suayed/utils/url_launcher_utils.dart';
import 'package:suayed/widgets/show_snack_bar.dart';
import 'package:suayed/widgets/thumbnail_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

/// Pantalla de detalle de un post/noticia.
///
/// Muestra el contenido completo del post incluyendo imagen destacada,
/// título, fecha y contenido HTML renderizado. Incluye opciones para
/// compartir, guardar/borrar de marcadores y abrir en navegador.
///
/// Soporta tanto [PostModel] (posts de la API) como [StoragePost] (bookmarks).
class PostDetail extends StatefulWidget {
  const PostDetail({
    super.key,
    this.postModel,
    this.storagePost,
    this.heroTag = 'post-image',
  }) : assert(
         postModel != null || storagePost != null,
         'Debe proporcionar postModel o storagePost',
       );

  /// Post desde la API (opcional)
  final PostModel? postModel;

  /// Post desde storage/bookmarks (opcional)
  final StoragePost? storagePost;

  /// Tag para Hero animation
  final String heroTag;

  @override
  State createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  /// Ancho máximo del contenido para mejorar legibilidad en pantallas grandes
  static const double _maxContentWidth = 800.0;

  /// Obtiene el ID del post actual
  int get _postId => widget.postModel?.id ?? widget.storagePost!.id;

  /// Obtiene el título del post actual
  String get _title => widget.postModel?.title ?? widget.storagePost!.title;

  /// Obtiene la fecha del post actual
  DateTime get _date => widget.postModel?.date ?? widget.storagePost!.date;

  /// Obtiene el link del post actual
  String get _link => widget.postModel?.link ?? widget.storagePost!.link;

  /// Obtiene la imagen del post actual
  String get _image => widget.postModel?.image ?? widget.storagePost!.image;

  /// Obtiene el contenido del post actual
  String get _content =>
      widget.postModel?.content ?? widget.storagePost!.content;

  /// Verifica si el post está guardado en bookmarks
  bool _isBookmarked(BookmarkProvider provider) {
    return provider.bookmarks.any((bookmark) => bookmark.id == _postId);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  /// Abre una URL en el navegador del sistema
  Future<void> _launchUrl(String url) async {
    await UrlLauncherUtils.launchWebUrl(context, url);
  }

  /// Comparte el enlace del post usando el sistema nativo
  Future<void> _shareFeed() async {
    try {
      await SharePlus.instance.share(
        ShareParams(subject: _title, uri: Uri.tryParse(_link)),
      );
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error al compartir.');
      }
    }
  }

  /// Guarda el post en marcadores locales
  Future<void> _savePost() async {
    try {
      final bookmarkProvider = Provider.of<BookmarkProvider>(
        context,
        listen: false,
      );

      // Si el post está guardado, lo borramos
      if (_isBookmarked(bookmarkProvider)) {
        // Mostrar diálogo de confirmación antes de eliminar
        final confirmed = await _showDeleteConfirmationDialog();

        if (confirmed == true) {
          await bookmarkProvider.deleteBookmark(_postId);
          if (mounted) {
            showSnackBar(context, 'Marcador eliminado');
            // Si venimos de bookmarks, regresamos
            if (widget.storagePost != null) {
              Navigator.pop(context);
            }
          }
        }
      } else {
        // Si no está guardado, lo guardamos
        // Necesitamos crear un PostModel si solo tenemos StoragePost
        final postToSave =
            widget.postModel ??
            PostModel(
              id: _postId,
              date: _date,
              title: _title,
              link: _link,
              image: _image,
              content: _content,
            );

        await bookmarkProvider.addBookmark(postToSave);
        if (mounted) {
          showSnackBar(context, 'Elemento guardado en marcadores...');
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error al procesar el marcador.');
      }
    }
  }

  /// Muestra un diálogo de confirmación antes de eliminar el marcador
  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar marcador'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este marcador?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    // Calcula padding horizontal para centrar contenido en pantallas anchas
    final horizontalPadding = screenWidth > _maxContentWidth
        ? (screenWidth - _maxContentWidth) / 2
        : 16.0;

    return Scaffold(
      appBar: AppBar(title: Text(_title), actions: [_buildPopupMenu(theme)]),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Título del post
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isWideScreen ? 24.0 : 18.0,
                horizontalPadding,
                isWideScreen ? 24.0 : 18.0,
              ),
              child: Text(
                _title.toUpperCase(),
                style: theme.textTheme.titleLarge,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Imagen destacada con Hero animation
            Semantics(
              label: 'Imagen destacada de $_title',
              image: true,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: '${widget.heroTag}-$_postId',
                  child: ThumbnailImage(imageUrl: _image),
                ),
              ),
            ),

            // Fecha de publicación
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: Text(
                DateFormat.yMMMMd('es_MX').format(_date),
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.left,
              ),
            ),

            // Contenido HTML del post
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: HtmlWidget(
                _content,
                onTapUrl: (url) {
                  _launchUrl(url);
                  return true;
                },
                onErrorBuilder: (context, element, error) =>
                    Text('Error al cargar contenido: $error'),
                onLoadingBuilder: (context, element, loadingProgress) =>
                    const Center(child: CircularProgressIndicator()),
                textStyle: GoogleFonts.robotoSlab(
                  textStyle: TextStyle(
                    fontSize: isWideScreen ? 17.0 : 16.0,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                customStylesBuilder: (element) {
                  if (element.classes.contains('wp-block-image')) {
                    return {'border-radius': '12px'};
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Footer con logo UNAM
            Center(
              child: Text(
                'UNAM',
                style: GoogleFonts.lora(
                  textStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.secondary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Construye el menú popup con las acciones disponibles
  Widget _buildPopupMenu(ThemeData theme) {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        final isBookmarked = _isBookmarked(bookmarkProvider);

        return PopupMenuButton<int>(
          tooltip: 'Más opciones',
          onSelected: (value) {
            switch (value) {
              case 0:
                HapticFeedback.lightImpact();
                _launchUrl(_link);
              case 1:
                HapticFeedback.mediumImpact();
                _savePost();
              case 2:
                HapticFeedback.mediumImpact();
                _shareFeed();
            }
          },
          itemBuilder: (context) => [
            _buildPopupMenuItem(
              value: 0,
              icon: Icons.link,
              label: 'Ir al sitio',
              color: theme.colorScheme.primary,
            ),
            _buildPopupMenuItem(
              value: 1,
              icon: isBookmarked ? Icons.delete : Icons.bookmark,
              label: isBookmarked ? 'Borrar' : 'Guardar',
              color: theme.colorScheme.primary,
            ),
            _buildPopupMenuItem(
              value: 2,
              icon: Icons.share,
              label: 'Compartir',
              color: theme.colorScheme.primary,
            ),
          ],
        );
      },
    );
  }

  /// Construye un item del menú popup
  PopupMenuItem<int> _buildPopupMenuItem({
    required int value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
