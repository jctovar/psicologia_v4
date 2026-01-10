import 'package:flutter/material.dart';
import 'package:suayed/providers/bookmark_provider.dart';
import 'package:suayed/widgets/thumbnail_image.dart';
import 'package:suayed/widgets/empty_state.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:suayed/widgets/app_drawer.dart';
import 'post_detail.dart';
import 'package:suayed/models/storage_post_model.dart';
import 'home_screen.dart';

class BookmarksScreen extends StatelessWidget {
  static const String routeName = 'bookmarks';
  const BookmarksScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(title)),
      drawer: const AppDrawer(),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          if (bookmarkProvider.bookmarks.isEmpty) {
            return EmptyState(
              icon: Icons.bookmark_border,
              title: 'Sin marcadores',
              message: 'Aún no has guardado ninguna noticia.\nExplora el contenido y marca tus favoritas para leerlas más tarde.',
              actionLabel: 'Explorar noticias',
              onActionPressed: () {
                Navigator.pushNamed(context, HomeScreen.routeName);
              },
            );
          }
          return BookmarkList(posts: bookmarkProvider.bookmarks);
        },
      ),
    );
  }
}

class BookmarkList extends StatelessWidget {
  const BookmarkList({super.key, required this.posts});

  final List<StoragePost> posts;

  String _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  void _openFeed(BuildContext context, StoragePost item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(
      builder: (context) => PostDetail(
        storagePost: item,
        heroTag: 'bookmark-image',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final item = posts[index];
        return Semantics(
          label: 'Marcador: ${item.title}. Publicado ${_datePub(item.date)}',
          hint: 'Toca para ver detalles. Desliza hacia la izquierda para eliminar',
          button: true,
          child: Dismissible(
            key: Key(item.id.toString()),
            background: Container(
              color: Theme.of(context).colorScheme.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar marcador'),
                  content: const Text(
                    '¿Deseas eliminar este marcador? Esta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              Provider.of<BookmarkProvider>(context, listen: false)
                  .deleteBookmark(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Marcador eliminado'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              leading: Semantics(
                label: 'Imagen de ${item.title}',
                image: true,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Hero(
                    tag: 'bookmark-image-${item.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ThumbnailImage(imageUrl: item.image),
                    ),
                  ),
                ),
              ),
              title: Text(
                item.title.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _datePub(item.date),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
              ),
              isThreeLine: true,
              onTap: () {
                _openFeed(context, item);
              },
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Theme.of(context).dividerColor);
      },
    );
  }
}
