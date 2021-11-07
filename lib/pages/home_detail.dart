import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDetail extends StatefulWidget {
  const HomeDetail({Key? key, required this.title, required this.item}) : super(key: key);
  final String title;
  final item;

  @override
  _HomeDetailState createState() => _HomeDetailState();
}

class _HomeDetailState extends State<HomeDetail> {

  static const String placeholderImg = 'assets/no_image.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffbfbfb),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          _popupMenuButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _title(widget.item['title']['rendered']),
            ),
            _image(widget.item['jetpack_featured_media_url']),
            _subtitle(widget.item['date']),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _htmlWidget(widget.item['content']['rendered']),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              '- UNAM -',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
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
        textStyle: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: -.3),
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  _subtitle(subTitle) {
    return Text(
      subTitle,
      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w200),
      maxLines: 1,
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
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300));
  }

  PopupMenuButton _popupMenuButton() {
    return PopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 0:
              _openFeed(widget.item['link']);
              break;
            case 1:

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

}