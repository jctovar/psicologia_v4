import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:json_store/json_store.dart';
import 'package:suayed/widgets/drawer.dart';
import 'bookmark_detail.dart';
import 'package:suayed/models/storage_post_model.dart';

class BookmarksPage extends StatefulWidget {
  static const String routeName = 'bookmarks';
  const BookmarksPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  static const String placeholderImg = 'assets/no_image.jpg';
  List<StoragePost> _posts = [];
  Null get jsonStore => null;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    List<Map<String, dynamic>>? json = await JsonStore().getListLike('post-%');
    _posts = (json ?? []).map((messageJson) => StoragePost.fromJson(messageJson)).toList();
    setState(() {});
  }

  String _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  CachedNetworkImage _thumbnail(imageUrl) {
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(placeholderImg),
      imageUrl: imageUrl,
      alignment: Alignment.center,
      fit: BoxFit.fill,
    );
  }

  void _openFeed(StoragePost item) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookmarkDetail(
              item: item
          ),
        )
    ).then((value) {
      setState(() {
        _loadFromStorage();
      });
    });
  }

  Text _title(title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: Colors.blue, letterSpacing: -.3),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _subtitle(subTitle) {
    return Text(
      subTitle,
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
      maxLines: 1,
    );
  }

  dynamic _body() {
    return _posts.isEmpty
        ? Center(
          child: _nothing(),
    )
    : _listPosts();
  }

  Image _nothing() {
    return const Image(image: AssetImage('assets/unam_clasico.png'));
  }

  ListView _listPosts() {
    return ListView.separated(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final item = _posts[index];
          return ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              leading: _thumbnail(item.image),
              title: _title(item.title),
              subtitle: _subtitle(_datePub(item.date)),
              isThreeLine: true,
              onTap: () {
                _openFeed(item);
              }
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            color: Colors.black12,
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        drawer: const AppDrawer(),
        body: _body()
    );
  }
}

