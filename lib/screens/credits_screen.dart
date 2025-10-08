import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  Text _title(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: GoogleFonts.lora(
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w800,
          color: Colors.blue,
          letterSpacing: -.3,
        ),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _subtitle(String subTitle) {
    return Text(
      subTitle,
      style: GoogleFonts.lora(
        textStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
          letterSpacing: -.3,
        ),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Creditos")),
      body: Center(
        child: SizedBox(
          width: 300,
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
                    colorFilter: const ColorFilter.mode(
                      Colors.pink,
                      BlendMode.srcIn,
                    ),
                    semanticsLabel: 'Iztacala Logo',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _title('Lider de proyecto'),
              _subtitle('Ing. Juan Carlos Tovar Gómez'),
              const SizedBox(height: 10),
              _title('Desarrollo'),
              _subtitle('Ing. Juan Carlos Tovar Gómez'),
              const SizedBox(height: 10),
              _title('Diseño UI y UX'),
              _subtitle('Ing. Juan Carlos Tovar Gómez'),
            ],
          ),
        ),
      ),
    );
  }
}
