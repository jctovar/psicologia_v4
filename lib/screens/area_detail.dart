import 'package:flutter/material.dart';
import 'package:suayed/models/area_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suayed/utils/html_styles.dart';
import 'package:suayed/widgets/avatar.dart';

import 'package:suayed/widgets/show_snack_bar.dart';

class AreaDetail extends StatefulWidget {
  const AreaDetail({super.key, required this.item});
  final AreaModel item;

  @override
  State createState() => _AreaDetailState();
}

class _AreaDetailState extends State<AreaDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.departmentName)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Hero(
              tag: widget.item.personalEmail,
              child: Avatar(
                picturePath: '',
                emailUser: widget.item.personalEmail,
                sizeAvatar: 128,
              ),
            ),
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
              child: _subtitle(widget.item.departmentEmail),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.mail, color: Colors.white),
        onPressed: () => _makeMailTo(widget.item.departmentEmail),
      ),
    );
  }

  Future<void> _makeMailTo(String email) async {
    try {
      final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
      if (!await launchUrl(emailLaunchUri)) {
        if (mounted) {
          showSnackBar(context, 'No se pudo abrir el cliente de correo.');
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error al intentar abrir el correo.');
      }
    }
  }

  Text _title(String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _subtitle(String subTitle) {
    return Text(
      subTitle,
      style: Theme.of(context).textTheme.titleSmall,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _footer(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lora(
        textStyle: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: -.3,
        ),
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  HtmlWidget _htmlWidget(String html) {
    final theme = Theme.of(context);
    return HtmlWidget(
      html,
      customStylesBuilder: (element) => buildHtmlStyles(context, element),
      onErrorBuilder: (context, element, error) =>
          Text('$element error: $error'),
      onLoadingBuilder: (context, element, loadingProgress) =>
          const CircularProgressIndicator(),
      textStyle: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 16.0,
      ),
    );
  }
}
