import 'package:flutter/material.dart';
import '../../widgets/drawer.dart';
import 'credits_screen.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const String routeName = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      appBar: AppBar(title: const Text("Acerca de la aplicación")),
      drawer: const AppDrawer(),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Image(image: AssetImage('assets/about.png')),
              const SizedBox(height: 15),
              const Text(
                'Aplicación desarrollada por la Facultad de Estudios Superiores Iztacala. '
                'Hecho en México, Universidad Nacional Autónoma de México (UNAM), '
                'todos los derechos reservados 2021.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'apps@iztacala.unam.mx',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 50,
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const CreditsPage();
                        },
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: const Text(
                    'Creditos',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
