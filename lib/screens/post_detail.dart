import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:suayed/providers/bookmark_provider.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/widgets/show_snack_bar.dart';
import 'package:suayed/widgets/thumbnail_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({super.key, required this.item});
  final PostModel item;

  @override
  State createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  Text _title(String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleLarge,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _subtitle(String subTitle) {
    return Text(
      subTitle,
      style: Theme.of(context).textTheme.titleSmall,
      textAlign: TextAlign.left,
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
            _savePost(widget.item);
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
              Icon(LineIcons.bookmark, color: Colors.pink),
              SizedBox(width: 7),
              Text('Guardar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: const [
              Icon(LineIcons.alternateShare, color: Colors.pink),
              SizedBox(width: 7),
              Text('Compartir'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (!await launchUrl(Uri.parse(url))) {
        if (mounted) {
          showSnackBar(context, 'No se pudo abrir el enlace.');
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error al intentar abrir el enlace.');
      }
    }
  }

  Future<void> _shareFeed(String url, String title) async {
    try {
      await SharePlus.instance.share(
        ShareParams(subject: title, uri: Uri.tryParse(url)),
      );
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error al compartir.');
      }
    }
  }

  Future<void> _savePost(PostModel item) async {
    try {
      await Provider.of<BookmarkProvider>(
        context,
        listen: false,
      ).addBookmark(item);
      if (mounted) {
        showSnackBar(context, 'Elemento guardado en marcadores...');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error al guardar el marcador.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        actions: [_popupMenuButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 18, 8, 18),
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
