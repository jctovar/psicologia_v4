import 'package:flutter/material.dart';
import '../../widgets/drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);
  static const String routeName = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acerca de la aplicación"),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView (
          child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(8),
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: Column(
                  children: [
                    ListTile(
                      leading: Image.asset("assets/icon.png", height: 96, width: 96),
                      title: const Text('Optometría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Expediente Medico de Optometría',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                    Image.asset('assets/about.jpg'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 10, 24),
                      child: Text(
                        'Aplicación desarrollada por la Facultad de Estudios Superiores Iztacala, UNAM. '
                            'Hecho en México, Universidad Nacional Autónoma de México (UNAM), '
                            'todos los derechos reservados 2021.',
                        style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                  ]
              )
          )
      ),
    );
  }
}