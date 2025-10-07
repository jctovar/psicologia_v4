import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:line_icons/line_icons.dart';
import 'package:localstore/localstore.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:suayed/widgets/show_snack_bar.dart';
import 'package:suayed/widgets/thumbnail_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:suayed/models/storage_post_model.dart';

class BookmarkDetail extends StatefulWidget {
  const BookmarkDetail({super.key, required this.item});
  final StoragePost item;

  @override
  State createState() => _BookmarkDetailState();
}

class _BookmarkDetailState extends State<BookmarkDetail> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  Text _title(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w800,
          color: Colors.blue,
          letterSpacing: -.3,
        ),
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _subtitle(String subTitle) {
    return Text(
      subTitle,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 14.0,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
      ),
      maxLines: 1,
    );
  }

  Text _footer(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
          color: Colors.pinkAccent,
          letterSpacing: -.3,
        ),
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  HtmlWidget _htmlWidget(String html) {
    return HtmlWidget(
      html,
      customStylesBuilder: (element) {
        if (element.classes.contains('foo')) {
          return {'color': 'red'};
        }

        return null;
      },
      onTapUrl: (url) {
        _launchUrl(url);
        return true;
      },
      onErrorBuilder: (context, element, error) =>
          Text('$element error: $error'),
      onLoadingBuilder: (context, element, loadingProgress) =>
          const CircularProgressIndicator(),
      textStyle: GoogleFonts.robotoSlab(
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
          color: Colors.black87,
        ),
      ),
    );
  }

  PopupMenuButton _popupMenuButton() {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case 0:
            _launchUrl(widget.item.link);
            break;
          case 1:
            _deleteBookmark(widget.item.id);
            break;
          case 2:
            _shareFeed(widget.item.link, widget.item.title);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: const [
              Icon(LineIcons.alternateExternalLink, color: Colors.pink),
              SizedBox(width: 7),
              Text('Ir al sitio'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: const [
              Icon(LineIcons.trash, color: Colors.pink),
              SizedBox(width: 7),
              Text('Borrar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: const [
              Icon(LineIcons.share, color: Colors.pink),
              SizedBox(width: 7),
              Text('Compartir'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _shareFeed(String url, String title) async {
    SharePlus.instance.share(
      ShareParams(subject: title, uri: Uri.tryParse(url)),
    );
  }

  Future<void> _deleteBookmark(int id) async {
    final db = Localstore.instance;
    await db.collection('bookmarks').doc(id.toString()).delete();

    if (mounted) {
      showSnackBar(context, 'Elemento guardado en marcadores...');
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.item.title),
        actions: [_popupMenuButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: _title(widget.item.title),
            ),
            ThumbnailImage(imageUrl: widget.item.image),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: _subtitle(
                  DateFormat.yMMMMd('es_MX').format(widget.item.date),
                ),
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
          ],
        ),
      ),
    );
  }
}
