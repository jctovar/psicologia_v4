import 'package:flutter/material.dart';
import 'package:suayed/widgets/show_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suayed/utils/html_styles.dart';
import 'package:suayed/widgets/avatar.dart';
import 'package:suayed/models/teacher_model.dart';

class TeacherDetail extends StatefulWidget {
  const TeacherDetail({super.key, required this.item});
  final TeacherModel item;

  @override
  State createState() => _TeacherDetailState();
}

class _TeacherDetailState extends State<TeacherDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Hero(
              tag: widget.item.email,
              child: Avatar(
                picturePath: widget.item.picture,
                emailUser: widget.item.email,
                sizeAvatar: 128,
              ),
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
          _makeMailTo(widget.item.email);
        }),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return HtmlWidget(
      html,
      onErrorBuilder: (context, element, error) =>
          Text('Error al cargar contenido: $error'),
      onLoadingBuilder: (context, element, loadingProgress) =>
          const Center(child: CircularProgressIndicator()),
      textStyle: theme.textTheme.bodyLarge?.copyWith(
        fontSize: isWideScreen ? 17.0 : 16.0,
        height: 1.6,
      ),
      customStylesBuilder: (element) => buildHtmlStyles(context, element),
    );
  }
}
