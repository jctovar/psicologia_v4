import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:suayed/services/suayed_service.dart';
import 'package:share/share.dart';
import 'home_detail.dart';

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
  late int _selectedIndex = 0;

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

  _openFeed(var item) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomeDetail(
              title: item['title']['rendered'],
              item: item
          ),
        )
    );
  }

  _updateFeed(feed) {
    setState(() {
      _feed = feed;
    });
  }

  _title(title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: -.3),
      ),
      maxLines: 3,
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
                onTap: () => _openFeed(item),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      _thumbnail(item['jetpack_featured_media_url']),
                      ListTile(
                        title: _title(item['title']['rendered']),
                        subtitle: _subtitle(_datePub(item['date'])),
                        contentPadding: const EdgeInsets.all(10.0),
                      ),
                      _buttonBar(item)
                ])));
      },
    );
  }

  _buttonBar(var item) {
    return ButtonBar(
      children: <Widget>[
        IconButton(
          onPressed: () {
            // You enter here what you want the button to do once the user interacts with it
            Share.share(item['link'], subject: item['title']['rendered']);
          },
          icon: const Icon(
            Icons.share,
            color: Colors.black54,
          ),
          iconSize: 24.0,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomeDetail(
                title: item['title']['rendered'],
                item: item
              ),
            ),
          ),
          icon: const Icon(
            Icons.bookmark,
            color: Colors.black54,
          ),
          iconSize: 24.0,
        ),
      ],
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
        centerTitle: true,
        title: Text(widget.title,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w800)),
      ),
      body: _body(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Areas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Tramites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink[400],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
