import 'package:flutter/material.dart';
import 'package:suayed/widgets/app_drawer.dart';
import 'credits_screen.dart';
import 'package:flutter_svg/svg.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.title});
  static const String routeName = 'about';
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              SizedBox(
                height: 100,
                width: 400,
                child: SvgPicture.asset(
                  'assets/logo_coordinacion.svg',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                  semanticsLabel: 'Iztamind Logo',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Aplicación desarrollada por la Facultad de Estudios Superiores Iztacala. '
                'Hecho en México, Universidad Nacional Autónoma de México (UNAM), '
                'todos los derechos reservados 2021.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'apps@iztacala.unam.mx',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 20),
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
                  child: const Text('Creditos'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
