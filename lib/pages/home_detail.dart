import 'package:flutter/material.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share/share.dart';
import 'package:json_store/json_store.dart';

class HomeDetail extends StatefulWidget {
  const HomeDetail({Key? key, required this.item}) : super(key: key);
  final PostModel item;

  @override
  _HomeDetailState createState() => _HomeDetailState();
}

class _HomeDetailState extends State<HomeDetail> {
  get jsonStore => null;
  static const String placeholderImg = 'assets/no_image.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        title: Text(widget.item.title),
        actions: [
          _popupMenuButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: _title(widget.item.title),
            ),
            _image(widget.item.image),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _subtitle(timeago.format(widget.item.date, locale: 'es')),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _htmlWidget(widget.item.content),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            _footer('UNAM'),
            const SizedBox(height: 20),
          ]
        )
      )
    );
  }

  _image(imageUrl) {
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(placeholderImg),
      imageUrl: imageUrl,
      alignment: Alignment.center,
      fit: BoxFit.fill,
    );
  }

  _title(title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: Constants.mainStyleTitle,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  _subtitle(subTitle) {
    return Text(
      subTitle,
      textAlign: TextAlign.right,
      style: Constants.mainStyleSubtitle,
      maxLines: 1,
    );
  }

  _footer(title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: Colors.pinkAccent, letterSpacing: -.3),
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  _htmlWidget(String html) {
    return HtmlWidget(html,
        customStylesBuilder: (element) {
          if (element.classes.contains('foo')) {
            return {'color': 'red'};
          }

          return null;
        },
        onTapUrl:(url) {
          _openFeed(url);
          return true;
        },
        onErrorBuilder: (context, element, error) => Text('$element error: $error'),
        onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
        textStyle: GoogleFonts.robotoSlab(
          textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300, color: Colors.black87),
        )
    );
  }

  PopupMenuButton _popupMenuButton() {
    return PopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 0:
              _openFeed(widget.item.link);
              break;
            case 1:
              _savePost(widget.item);
              break;
            case 2:
              _shareFeed(widget.item.link, widget.item.title);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(
                  Icons.open_in_browser,
                  color: Colors.pink,
                ),
                SizedBox(
                  width: 7,
                ),
                Text('Ir al sitio')
              ],
            ),
            value: 0,
          ),
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(
                  Icons.bookmark,
                  color: Colors.pink,
                ),
                SizedBox(
                  width: 7,
                ),
                Text('Guardar')
              ],
            ),
            value: 1,
          ),
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(
                  Icons.share,
                  color: Colors.pink,
                ),
                SizedBox(
                  width: 7,
                ),
                Text('Compartir')
              ],
            ),
            value: 2,
          )
        ]);
  }

  Future<void> _openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    }
  }

  Future<void> _shareFeed(String url, String title) async {
    Share.share(url, subject: title);
  }

  Future<void> _savePost(PostModel item) async {
    await JsonStore().setItem(
      'post-${item.id}',
      item.toJson()
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Elemento guardado en marcadores...')));
  }

}