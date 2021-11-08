import 'package:google_fonts/google_fonts.dart';
import 'package:suayed/models/post_model.dart';
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
  static const String placeholderImg = 'assets/no_image.jpg';
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  late int _selectedIndex = 0;
  List<PostModel> _posts = List.empty();

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
        textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: -.3),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  _subtitle(subTitle) {
    return Text(
      subTitle,
      style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.w300),
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
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: _thumbnail(item.image)
                        ),
                      ),
                      ListTile(
                        title: _title(item.title),
                        subtitle: _subtitle(_datePub(item.date)),
                        contentPadding: const EdgeInsets.all(8.0),
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
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomeDetail(
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

  _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  _body() {
    switch(_selectedIndex) {
      case 0: {
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
      break;
      case 1: {
        //statements;
      }
      break;
      case 2: {
        //statements;
      }
      break;
      case 3: {
        //statements;
      }
      break;
    }


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
      body: _body(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Marcadores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Areas',
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
