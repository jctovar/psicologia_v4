import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suayed/providers/bookmark_provider.dart';
import 'package:suayed/widgets/thumbnail_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:suayed/widgets/app_drawer.dart';
import 'bookmark_detail.dart';
import 'package:suayed/models/storage_post_model.dart';

class BookmarksPage extends StatelessWidget {
  static const String routeName = 'bookmarks';
  const BookmarksPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(title)),
      drawer: const AppDrawer(),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          if (bookmarkProvider.bookmarks.isEmpty) {
            return const Center(
              child: Image(image: AssetImage('assets/unam_clasico.png')),
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => BookmarkDetail(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final item = posts[index];
        return ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          leading: ThumbnailImage(imageUrl: item.image),
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
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(color: Colors.black12);
      },
    );
  }
}
