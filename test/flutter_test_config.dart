import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Configuración global de pruebas (flutter_test la aplica a cada archivo).
///
/// En pruebas de escritorio, localstore guarda en `Directory.current` (la raíz
/// del repo), creando `bookmarks/` y `notifications/` en el proyecto. Aquí se
/// cambia el directorio de trabajo a uno temporal que se elimina al terminar.
///
/// No se usa `Localstore.getInstance(customPath:)` porque en localstore 1.4.0
/// ignora la ruta, y `setCustomSavePath` entra en recursión infinita.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final originalDir = Directory.current;
  final tempDir = await Directory.systemTemp.createTemp(
    'suayed_test_localstore_',
  );
  Directory.current = tempDir;

  tearDownAll(() async {
    Directory.current = originalDir;
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  await testMain();
}
