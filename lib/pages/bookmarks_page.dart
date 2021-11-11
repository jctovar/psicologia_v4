import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  get jsonStore => null;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  _loadFromStorage() async {
    List<Map<String, dynamic>>? json = await JsonStore().getListLike('post-%');

    if(json == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todavia no hay elementos guardados...')));
    }

    _posts = json != null
        ? json.map((messageJson) => StoragePost.fromJson(messageJson)).toList()
        : [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      drawer: const AppDrawer(),
      body: _body()
    );
  }

  _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  _thumbnail(imageUrl) {
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(placeholderImg),
      imageUrl: imageUrl,
      alignment: Alignment.center,
      fit: BoxFit.fill,
    );
  }

  _openFeed(StoragePost item) {
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

  _title(title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: Colors.blue, letterSpacing: -.3),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  _subtitle(subTitle) {
    return Text(
      subTitle,
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
      maxLines: 1,
    );
  }

  _body() {
    return _posts.isEmpty
        ? Center(
          child: _nothing(),
    )
    : _listPosts();
  }

  _nothing() {
    return const Image(image: AssetImage('assets/unam_clasico.png'));
  }

  _listPosts() {
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
}

