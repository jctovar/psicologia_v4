import 'package:flutter/material.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suayed/widgets/avatar.dart';
import 'package:suayed/models/teacher_model.dart';

class TeacherDetail extends StatefulWidget {
  const TeacherDetail({super.key, required this.item});
  final TeacherModel item;

  @override
  State createState() => _TeacherDetailState();
}

class _TeacherDetailState extends State<TeacherDetail> {
  Future<void>? _launched;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.item.grade} ${widget.item.firstname} ${widget.item.lastname}',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Avatar(
              picturePath: widget.item.picture,
              emailUser: widget.item.email,
              sizeAvatar: 128,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 16, 16, 16),
              child: _title(
                '${widget.item.grade} ${widget.item.firstname} ${widget.item.lastname}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _subtitle(widget.item.email),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _subtitle(widget.item.fields),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _htmlWidget(widget.item.cv),
            ),
            const Divider(),
            const SizedBox(height: 10),
            _footer('UNAM'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.mail, color: Colors.white),
        onPressed: () => setState(() {
          _launched = _makeMailTo('mailto:${widget.item.email}');
        }),
      ),
    );
  }

  Future<void> _makeMailTo(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
      style: GoogleFonts.lora(
        textStyle: const TextStyle(
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w300,
        ),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
      onErrorBuilder: (context, element, error) =>
          Text('$element error: $error'),
      onLoadingBuilder: (context, element, loadingProgress) =>
          const CircularProgressIndicator(),
      textStyle: GoogleFonts.robotoSlab(
        textStyle: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w300,
          color: Colors.black87,
        ),
      ),
    );
  }
}
