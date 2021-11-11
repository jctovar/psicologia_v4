import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:json_store/json_store.dart';
import 'package:suayed/widgets/drawer.dart';
import 'area_detail.dart';

class BookmarksPage extends StatefulWidget {
  static const String routeName = 'bookmarks';
  const BookmarksPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<StoragePost> _posts = [];
  get jsonStore => null;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  _loadFromStorage() async {
    List<Map<String, dynamic>>? json = await JsonStore().getListLike('post-%');

    _posts = json != null
        ? json.map((messageJson) => StoragePost.fromJson(messageJson)).toList()
        : [];
    setState(() {});
  }

  /*_deleteFromStorage() async {
    await JsonStore().deleteLike('post-%');
    await _loadFromStorage();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w800)),
      ),
      drawer: const AppDrawer(),
      body: ListView.separated(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final item = _posts[index];
          return ListTile(
              title: Text(item.title.toUpperCase(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              subtitle: Text(_datePub(item.date),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              isThreeLine: true,
              onTap: () {

              }
          );

        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            color: Colors.black12,
          );
        }
      )
    );
  }

  _datePub(DateTime date) {
    return timeago.format(date, locale: 'es_short');
  }
}

class StoragePost {
  StoragePost({
    required this.id,
    required this.date,
    required this.title,
    required this.link,
    required this.excerpt,
    required this.image,
    required this.content,
  });

  final int id;
  final DateTime date;
  final String title;
  final String link;
  final String image;
  final String excerpt;
  final String content;

  factory StoragePost.fromJson(Map<String, dynamic> json) {
    return StoragePost(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      link: json['link'].toString(),
      image: json['image'],
      excerpt: json['excerpt'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toString(),
    "title": title,
    "link": link,
    "image": image,
    "excerpt": excerpt,
    "content": content,
  };
}