import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstore/localstore.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/services/suayed_service.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:suayed/widgets/drawer.dart';
import 'package:suayed/widgets/show_snack_bar.dart';
import 'package:suayed/widgets/thumbnail_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'post_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  static const String routeName = 'home';
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  List<PostModel> _posts = List.empty();

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

  void _openFeed(PostModel item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => PostDetail(item: item)));
  }

  void _updateFeed(List<PostModel> result) {
    setState(() {
      _posts = result;
    });
  }

  Text _title(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(textStyle: Constants.mainStyleTitle),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _subtitle(String subTitle) {
    return Text(
      subTitle,
      style: Constants.mainStyleSubtitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  ListView _listPosts() {
    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _posts[index];
        return Card(
          child: InkWell(
            splashColor: Colors.pink.withAlpha(60),
            onTap: () => _openFeed(item),
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
                  title: _title(item.title),
                  subtitle: _subtitle(_datePub(item.date)),
                ),
                _buttonBar(item),
              ],
            ),
          ),
        );
      },
    );
  }

  OverflowBar _buttonBar(PostModel item) {
    return OverflowBar(
      children: <Widget>[
        IconButton(
          onPressed: () {
            SharePlus.instance.share(
              ShareParams(subject: item.link, uri: Uri.tryParse(item.link)),
            );
          },
          icon: const Icon(LineIcons.share, color: Colors.black54),
          iconSize: 24.0,
        ),
        IconButton(
          onPressed: () => _savePost(item),
          icon: const Icon(LineIcons.bookmark, color: Colors.black54),
          iconSize: 24.0,
        ),
      ],
    );
  }

  String _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  Widget _body() {
    return _posts.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            key: _refreshKey,
            child: _listPosts(),
            onRefresh: () => _loadData(true),
          );
  }

  Future<void> _savePost(PostModel item) async {
    final db = Localstore.instance;
    final id = item.id.toString();
    await db.collection('bookmarks').doc(id).set(item.toJson());

    if (mounted) {
      showSnackBar(context, 'Elemento guardado en marcadores...');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w800),
        ),
      ),
      drawer: const AppDrawer(),
      body: _body(),
    );
  }
}
