import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:line_icons/line_icons.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:suayed/models/storage_post_model.dart';
import 'package:json_store/json_store.dart';

class BookmarkDetail extends StatefulWidget {
  const BookmarkDetail({Key? key, required this.item}) : super(key: key);
  final StoragePost item;

  @override
  _BookmarkDetailState createState() => _BookmarkDetailState();
}

class _BookmarkDetailState extends State<BookmarkDetail> {
  get jsonStore => null;
  static const String placeholderImg = 'assets/no_image.jpg';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
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
        textStyle: const TextStyle(fontSize: 24.0,
            fontWeight: FontWeight.w800,
            color: Colors.blue,
            letterSpacing: -.3),
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  _subtitle(subTitle) {
    return Text(
      subTitle,
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 14.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400),
      maxLines: 1,
    );
  }

  _footer(title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: const TextStyle(fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: Colors.pinkAccent,
            letterSpacing: -.3),
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
        onTapUrl: (url) {
          _openFeed(url);
          return true;
        },
        onErrorBuilder: (context, element, error) =>
            Text('$element error: $error'),
        onLoadingBuilder: (context, element,
            loadingProgress) => const CircularProgressIndicator(),
        textStyle: GoogleFonts.robotoSlab(
          textStyle: const TextStyle(fontSize: 16.0,
              fontWeight: FontWeight.w300,
              color: Colors.black87),
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
              _deleteBookmark(widget.item.id);
              break;
            case 2:
              _shareFeed(widget.item.link, widget.item.title);
              break;
          }
        },
        itemBuilder: (context) =>
        [
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(
                  LineIcons.alternateExternalLink,
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
                  LineIcons.trash,
                  color: Colors.pink,
                ),
                SizedBox(
                  width: 7,
                ),
                Text('Borrar')
              ],
            ),
            value: 1,
          ),
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(
                  LineIcons.share,
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

  Future<void> _deleteBookmark(int id) async {
    await JsonStore().deleteItem('post-$id');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Elemento eliminado de marcadores...')));
    //await _loadFromStorage();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.backgroundColor,
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
                    child: SizedBox(
                        width: double.infinity,
                        child: _subtitle(DateFormat.yMMMMd('es_MX').format(widget.item.date))
                    ),
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
}