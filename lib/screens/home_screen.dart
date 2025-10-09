import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/providers/bookmark_provider.dart';
import 'package:suayed/providers/home_provider.dart';
import 'package:suayed/widgets/app_drawer.dart';
import 'package:suayed/widgets/show_snack_bar.dart';
import 'package:suayed/widgets/thumbnail_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'post_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});
  static const String routeName = 'home';
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w800),
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isLoading && homeProvider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeProvider.errorMessage != null) {
            return Center(
              child: Text(homeProvider.errorMessage!),
            );
          }

          return RefreshIndicator(
            onRefresh: () => homeProvider.fetchPosts(refresh: true),
            child: ListView.builder(
              itemCount: homeProvider.posts.length,
              itemBuilder: (BuildContext context, int index) {
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

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.item});

  final PostModel item;

  String _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  void _openFeed(BuildContext context, PostModel item) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PostDetail(item: item)));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.pink.withAlpha(60),
        onTap: () => _openFeed(context, item),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: ThumbnailImage(imageUrl: item.image),
              ),
            ),
            ListTile(
              title: Text(item.title.toUpperCase(), maxLines: 3, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis),
              subtitle: Text(_datePub(item.date), maxLines: 1, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
            ),
            PostActions(item: item),
          ],
        ),
      ),
    );
  }
}

class PostActions extends StatelessWidget {
  const PostActions({super.key, required this.item});

  final PostModel item;

  Future<void> _savePost(BuildContext context, PostModel item) async {
    try {
      await Provider.of<BookmarkProvider>(context, listen: false).addBookmark(item);
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
    return OverflowBar(
      children: <Widget>[
        IconButton(
          onPressed: () {
            try {
              SharePlus.instance.share(
                ShareParams(subject: item.link, uri: Uri.tryParse(item.link)),
              );
            } catch (e) {
              showSnackBar(context, 'Error al compartir.');
            }
          },
          icon: const Icon(LineIcons.share, color: Colors.black54),
          iconSize: 24.0,
        ),
        IconButton(
          onPressed: () => _savePost(context, item),
          icon: const Icon(LineIcons.bookmark, color: Colors.black54),
          iconSize: 24.0,
        ),
      ],
    );
  }
}
