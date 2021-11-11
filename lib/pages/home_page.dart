import 'package:google_fonts/google_fonts.dart';
import 'package:json_store/json_store.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/widgets/drawer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:suayed/services/suayed_service.dart';
import 'package:share/share.dart';
import 'home_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  static const String routeName = 'home';
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String placeholderImg = 'assets/no_image.jpg';
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  List<PostModel> _posts = List.empty();
  get jsonStore => null;

  Future _load() async {
    SuayedServices.getPosts().then((result) {
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
    _load();
  }

  _openFeed(PostModel item) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomeDetail(
              item: item
          ),
        )
    );
  }

  _updateFeed(feed) {
    setState(() {
      _posts = feed;
    });
  }

  _title(title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: Colors.blue, letterSpacing: -.3),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  _subtitle(subTitle) {
    return Text(
      subTitle,
      style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
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
      itemCount: _posts.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _posts[index];
        return Card(
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () => _openFeed(item),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: _thumbnail(item.image)
                        ),
                      ),
                      ListTile(
                        title: _title(item.title),
                        subtitle: _subtitle(_datePub(item.date)),
                      ),
                      _buttonBar(item)
                ])));
      },
    );
  }

  _buttonBar(PostModel item) {
    return ButtonBar(
      children: <Widget>[
        IconButton(
          onPressed: () {
            // You enter here what you want the button to do once the user interacts with it
            Share.share(item.link, subject: item.title);
          },
          icon: const Icon(
            Icons.share,
            color: Colors.black54,
          ),
          iconSize: 24.0,
        ),
        IconButton(
          onPressed: () => _savePost(item),
          icon: const Icon(
            Icons.bookmark,
            color: Colors.black54,
          ),
          iconSize: 24.0,
        ),
      ],
    );
  }

  _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  _body() {
    return _posts.isEmpty
      ? const Center(
        child: CircularProgressIndicator(),
      )
      : RefreshIndicator(
        key: _refreshKey,
        child: _listPosts(),
        onRefresh: () => _load(),
      );
  }

  Future<void> _savePost(PostModel item) async {
    var start = DateTime.now().millisecondsSinceEpoch;
    await JsonStore().setItem(
      'post-${item.id}',
      item.toJson(),
      encrypt: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post guardado en marcadores')));
    var end = DateTime.now().millisecondsSinceEpoch;
    print('time taken to store post: ${end - start}ms');
    setState(() {});
  }

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
      body: _body(),
    );
  }
}
