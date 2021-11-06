import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:suayed/services/suayed_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _feed = List.empty();
  static const String placeholderImg = 'assets/no_image.jpg';
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    }
  }

  Future load() async {
    SuayedServices.getWP().then((result) {
      if (result.toString().isEmpty) {
        return;
      }
      _updateFeed(result);
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshKey;
    load();
  }

  _updateFeed(feed) {
    setState(() {
      _feed = feed;
    });
  }

  _title(title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  _subtitle(subTitle) {
    return Text(
      subTitle,
      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  _thumbnail(imageUrl) {
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(placeholderImg),
      imageUrl: imageUrl,
      alignment: Alignment.center,
      fit: BoxFit.fill,
    );
  }

  _listPosts() {
    return ListView.builder(
      itemCount: _feed.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _feed[index];
        return Card(
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () => openFeed(item['link'] ?? ''),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      _thumbnail(item['jetpack_featured_media_url']),
                      ListTile(
                        title: _title(item['title']['rendered']),
                        subtitle: _subtitle(_datePub(item['date'])),
                        contentPadding: const EdgeInsets.all(10.0),
                      )
                ])));
      },
    );
  }

  _datePub(String date) {
    DateTime dt = DateTime.parse(date);

    return timeago.format(dt, locale: 'es');
  }

  _body() {
    return _feed.isEmpty
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            key: _refreshKey,
            child: _listPosts(),
            onRefresh: () => load(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _body(),
    );
  }
}
