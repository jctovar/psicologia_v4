import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrivacyNotice extends StatefulWidget {
  const PrivacyNotice({super.key});

  static const String routeName = 'privacity';

  @override
  State createState() => _PrivacyNoticeState();
}

class _PrivacyNoticeState extends State<PrivacyNotice> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aviso de privacidad")),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: rootBundle.loadString('assets/privacity.html'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String? html = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: HtmlWidget(html!),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()],
              ),
            );
          },
        ),
      ),
    );
  }
}
