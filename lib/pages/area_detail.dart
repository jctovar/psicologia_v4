import 'package:flutter/material.dart';
import 'package:suayed/models/area_model.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suayed/widgets/avatar.dart';

class AreaDetail extends StatefulWidget {
  const AreaDetail({Key? key, required this.item}): super(key: key);
  final AreaModel item;

  @override
  _AreaDetailState createState() => _AreaDetailState();
}

class _AreaDetailState extends State<AreaDetail> {
  Future<void>? _launched;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.backgroundColor,
        appBar: AppBar(
          title: Text(widget.item.department_name),
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Avatar(picturePath: '', emailUser: widget.item.personal_email, sizeAvatar: 128),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 16, 16, 16),
                    child: _title(widget.item.agent),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(widget.item.title),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _subtitle(widget.item.department_email),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _htmlWidget(widget.item.detail),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  _footer('UNAM'),
                  const SizedBox(height: 20),
                ]
            )
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.mail, color: Colors.white,),
          onPressed: () => setState(() {
            _launched = _makeMailTo('mailto:${widget.item.department_email}');
          }
          ),
        )
    );
  }

  Future<void> _makeMailTo(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Container _lineText(String myText) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 6, 10, 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              myText, overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: false,
            ),
          )
        ],
      ),
    );
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
      style: GoogleFonts.lora(
        textStyle: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
        onErrorBuilder: (context, element, error) => Text('$element error: $error'),
        onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
        textStyle: GoogleFonts.robotoSlab(
          textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300, color: Colors.black87),
        )
    );
  }
}