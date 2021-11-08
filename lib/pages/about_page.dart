import 'package:flutter/material.dart';
import '../../widgets/drawer.dart';
import 'package:google_fonts/google_fonts.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);
  static const String routeName = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      appBar: AppBar(
        title: const Text("Acerca de la aplicación"),
      ),
      drawer: const AppDrawer(),
      body: Center(
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: const [
                Image(image: AssetImage('assets/about.png')),
                SizedBox(height: 30),
                Text(
                    'Aplicación desarrollada por la Facultad de Estudios Superiores Iztacala, UNAM. '
                        'Hecho en México, Universidad Nacional Autónoma de México (UNAM), '
                        'todos los derechos reservados 2021.',
                    textAlign: TextAlign.center,

                    style: TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          )
      )
    );
  }

  // Image(image: AssetImage('assets/about.png')),
}