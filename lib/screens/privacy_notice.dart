import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:suayed/utils/html_styles.dart';
import 'package:suayed/widgets/app_drawer.dart';

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
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: rootBundle.loadString('assets/privacity.html'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String? html = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: SvgPicture.asset(
                          'assets/logo_iztacala_compacto.svg',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                          semanticsLabel: 'Iztacala Logo',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    HtmlWidget(
                      html!,
                      customStylesBuilder: (element) =>
                          buildHtmlStyles(context, element),
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
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
