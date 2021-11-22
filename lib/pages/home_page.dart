import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_store/json_store.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/widgets/drawer.dart';
import 'package:timeago/timeago.dart' as timeago;
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
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  List<PostModel> _posts = List.empty();
  get jsonStore => null;

  Future _loadData(bool refreshData) async {
    SuayedServices.getPosts(refreshData).then((result) {
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
    _loadData(false);
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

  _updateFeed(result) {
    setState(() {
      _posts = result;
    });
  }

  _title(title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: Constants.mainStyleTitle,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  _subtitle(subTitle) {
    return Text(
      subTitle,
      style: Constants.mainStyleSubtitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  _thumbnail(imageUrl) {
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(Constants.placeholderImg),
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
                splashColor: Colors.pink.withAlpha(60),
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
      buttonPadding: const EdgeInsets.all(2.0),
      children: <Widget>[
        IconButton(
          onPressed: () {
            // You enter here what you want the button to do once the user interacts with it
            Share.share(item.link, subject: item.title);
          },
          icon: const Icon(
            LineIcons.share,
            color: Colors.black54,
          ),
          iconSize: 24.0,
        ),
        IconButton(
          onPressed: () => _savePost(item),
          icon: const Icon(
            LineIcons.bookmark,
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
        onRefresh: () => _loadData(true),
      );
  }

  Future<void> _savePost(PostModel item) async {
    await JsonStore().setItem(
      'post-${item.id}',
      item.toJson()
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Elemento guardado en marcadores...')));
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
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
