# Psicologia SUAyED - FES Iztacala

Aplicacion movil desarrollada en Flutter para la comunidad de la carrera de Psicologia en el Sistema Universidad Abierta y Educacion a Distancia (SUAyED) de la Facultad de Estudios Superiores Iztacala, UNAM.

---

## Tabla de Contenidos

- [Descripcion General](#descripcion-general)
- [Capturas de Pantalla](#capturas-de-pantalla)
- [Caracteristicas](#caracteristicas)
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalacion](#instalacion)
- [Configuracion de Firebase](#configuracion-de-firebase)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Arquitectura](#arquitectura)
- [Comandos Utiles](#comandos-utiles)
- [Pruebas](#pruebas)
- [Contribucion](#contribucion)
- [Licencia](#licencia)
- [Creditos](#creditos)

---

## Descripcion General

Esta aplicacion esta disenada para mantener informados a los estudiantes de la carrera de Psicologia del sistema SUAyED FES Iztacala. Proporciona acceso a noticias, eventos, informacion de profesores, areas de conocimiento y permite guardar publicaciones importantes para consultarlas posteriormente.

### Datos del Proyecto

| Atributo | Valor |
|----------|-------|
| **Version** | 0.8.120+20251014 |
| **Flutter SDK** | ^3.9.2 |
| **Plataformas** | Android, iOS, macOS, Web |
| **Color Principal** | #d81b60 |
| **API Base** | https://suayed.iztacala.unam.mx/ |

---

## Capturas de Pantalla

<!-- Agrega capturas de pantalla de la aplicacion aqui -->

| Pantalla Principal | Profesores | Areas de Conocimiento |
|:------------------:|:----------:|:--------------------:|
| ![Home](docs/screenshots/home.png) | ![Profesores](docs/screenshots/teachers.png) | ![Areas](docs/screenshots/areas.png) |

| Detalle de Noticia | Marcadores | Menu Lateral |
|:------------------:|:----------:|:------------:|
| ![Detalle](docs/screenshots/detail.png) | ![Marcadores](docs/screenshots/bookmarks.png) | ![Menu](docs/screenshots/drawer.png) |

> **Nota:** Si las capturas de pantalla no existen, crea una carpeta `docs/screenshots/` y agrega las imagenes correspondientes.

---

## Caracteristicas

- **Noticias y Eventos**: Mantente al dia con las ultimas publicaciones y avisos de la carrera, con soporte de paginacion y cache inteligente.
- **Areas de Conocimiento**: Explora las diferentes areas de la psicologia disponibles en el plan de estudios.
- **Planta Docente**: Consulta informacion sobre los profesores de la carrera con sus datos de contacto.
- **Marcadores**: Guarda publicaciones importantes para leerlas mas tarde con persistencia local.
- **Notificaciones Push**: Recibe notificaciones importantes directamente en tu dispositivo via Firebase Cloud Messaging.
- **Tema Claro/Oscuro**: Soporte completo para temas claro y oscuro con cumplimiento WCAG AA/AAA.
- **Acerca de y Creditos**: Informacion sobre el desarrollo de la aplicacion.

---

## Requisitos del Sistema

### Para Desarrollo

| Requisito | Version Minima |
|-----------|----------------|
| Flutter SDK | 3.9.2 o superior |
| Dart SDK | 3.0.0 o superior |
| Android Studio / VS Code | Ultima version estable |
| Xcode (para iOS/macOS) | 14.0 o superior |

### Para Dispositivos

| Plataforma | Version Minima |
|------------|----------------|
| Android | API 21 (Android 5.0) |
| iOS | 12.0 |
| macOS | 10.14 |

---

## Instalacion

### Paso 1: Clonar el Repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd psicologia_v4
```

### Paso 2: Verificar Instalacion de Flutter

```bash
flutter doctor
```

Asegurate de que no haya errores criticos antes de continuar.

### Paso 3: Instalar Dependencias

```bash
flutter pub get
```

### Paso 4: Configurar Firebase (Ver seccion siguiente)

### Paso 5: Ejecutar la Aplicacion

```bash
# En un dispositivo conectado o emulador
flutter run

# Para un dispositivo especifico
flutter devices  # Lista dispositivos disponibles
flutter run -d <device_id>
```

---

## Configuracion de Firebase

La aplicacion utiliza Firebase para notificaciones push, analiticas y reporte de errores (Crashlytics).

### Proyecto Firebase

- **Nombre del Proyecto**: `app-de-psicologia-suayed`

### Archivos de Configuracion Requeridos

| Plataforma | Archivo | Ubicacion |
|------------|---------|-----------|
| Android | `google-services.json` | `android/app/` |
| iOS | `GoogleService-Info.plist` | `ios/Runner/` |
| macOS | `GoogleService-Info.plist` | `macos/Runner/` |
| Dart | `firebase_options.dart` | `lib/` (auto-generado) |

### Pasos para Configurar Firebase

1. **Accede a la Consola de Firebase**
   - Ve a [console.firebase.google.com](https://console.firebase.google.com)
   - Selecciona el proyecto `app-de-psicologia-suayed`

2. **Descarga los Archivos de Configuracion**
   - Para Android: Descarga `google-services.json`
   - Para iOS/macOS: Descarga `GoogleService-Info.plist`

3. **Coloca los Archivos en las Ubicaciones Correctas**
   - Sigue la tabla de ubicaciones anterior

4. **Regenerar firebase_options.dart (opcional)**
   ```bash
   flutterfire configure
   ```

### Servicios de Firebase Utilizados

| Servicio | Paquete | Version |
|----------|---------|---------|
| Core | `firebase_core` | 4.2.0 |
| Analytics | `firebase_analytics` | 12.0.3 |
| Messaging | `firebase_messaging` | 16.0.3 |
| Crashlytics | `firebase_crashlytics` | 5.0.6 |

---

## Estructura del Proyecto

```
psicologia_v4/
├── lib/
│   ├── main.dart                 # Punto de entrada de la aplicacion
│   ├── theme.dart                # Configuracion de temas (claro/oscuro)
│   ├── firebase_options.dart     # Configuracion de Firebase (auto-generado)
│   │
│   ├── models/                   # Modelos de datos
│   │   ├── post_model.dart       # Modelo para noticias/posts
│   │   ├── storage_post_model.dart # Modelo para almacenamiento local
│   │   ├── area_model.dart       # Modelo para areas de conocimiento
│   │   ├── teacher_model.dart    # Modelo para profesores
│   │   └── notification_model.dart # Modelo para notificaciones
│   │
│   ├── providers/                # Gestion de estado (Provider)
│   │   ├── home_provider.dart    # Estado de la pantalla principal
│   │   ├── bookmark_provider.dart # Estado de marcadores
│   │   ├── notification_provider.dart # Estado de notificaciones
│   │   └── theme_provider.dart   # Estado del tema (claro/oscuro)
│   │
│   ├── services/                 # Capa de servicios
│   │   ├── http_service.dart     # Cliente HTTP con cache (Dio)
│   │   ├── posts_service.dart    # Servicio de posts con paginacion
│   │   ├── suayed_service.dart   # Operaciones de API de alto nivel
│   │   ├── local_service.dart    # Almacenamiento local
│   │   ├── firebase_service.dart # Inicializacion de Firebase
│   │   ├── crashlytics_service.dart # Reporte de errores
│   │   └── logger_service.dart   # Sistema de logging
│   │
│   ├── screens/                  # Pantallas de la aplicacion
│   │   ├── home_screen.dart      # Pantalla principal (noticias)
│   │   ├── post_detail.dart      # Detalle de noticia
│   │   ├── teachers_screen.dart  # Lista de profesores
│   │   ├── teacher_detail.dart   # Detalle de profesor
│   │   ├── areas_screen.dart     # Areas de conocimiento
│   │   ├── area_detail.dart      # Detalle de area
│   │   ├── bookmarks_screen.dart # Marcadores guardados
│   │   ├── notifications_screen.dart # Pantalla de notificaciones
│   │   ├── about_screen.dart     # Acerca de la app
│   │   ├── credits_screen.dart   # Creditos
│   │   └── privacy_notice.dart   # Aviso de privacidad
│   │
│   ├── widgets/                  # Componentes reutilizables
│   │   ├── app_drawer.dart       # Menu lateral de navegacion
│   │   ├── post_card.dart        # Tarjeta de noticia
│   │   ├── avatar.dart           # Avatar de usuario
│   │   ├── thumbnail_image.dart  # Imagen miniatura
│   │   ├── shimmer_placeholder.dart # Placeholder de carga
│   │   ├── empty_state.dart      # Estado vacio
│   │   └── show_snack_bar.dart   # Notificaciones en pantalla
│   │
│   ├── routes/                   # Navegacion
│   │   └── routes.dart           # Definicion de rutas
│   │
│   └── utils/                    # Utilidades
│       ├── app_constants.dart    # Constantes de la aplicacion
│       ├── url_launcher_utils.dart # Utilidades para abrir URLs
│       ├── url_validator.dart    # Validacion de URLs
│       └── logger.dart           # Logger (legacy)
│
├── assets/                       # Recursos estaticos
│   ├── images/                   # Imagenes
│   │   └── no_image.jpg          # Placeholder de imagen
│   ├── icon/                     # Iconos de la aplicacion
│   │   ├── icon.png              # Icono principal
│   │   └── apple.png             # Icono para iOS
│   ├── areas.json                # Datos de areas de conocimiento
│   ├── teachers.json             # Datos de profesores
│   └── privacity.html            # Aviso de privacidad HTML
│
├── test/                         # Pruebas unitarias
│   ├── models/                   # Tests de modelos
│   ├── providers/                # Tests de providers
│   └── services/                 # Tests de servicios
│
├── android/                      # Configuracion de Android
├── ios/                          # Configuracion de iOS
├── macos/                        # Configuracion de macOS
├── web/                          # Configuracion de Web
│
├── pubspec.yaml                  # Dependencias del proyecto
├── CLAUDE.md                     # Guia para Claude Code
├── CONTRIBUTING.md               # Guia de contribucion
└── README.md                     # Este archivo
```

---

## Arquitectura

### Patron de Arquitectura

La aplicacion sigue una arquitectura simple pero efectiva basada en:

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │   Widgets   │  │       Routes        │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                │                     │             │
└─────────┼────────────────┼─────────────────────┼─────────────┘
          │                │                     │
          ▼                ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     State Layer (Provider)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ HomeProvider │  │BookmarkProv. │  │ NotificationProv │   │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘   │
│         │                 │                    │             │
└─────────┼─────────────────┼────────────────────┼─────────────┘
          │                 │                    │
          ▼                 ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐   │
│  │HttpServ. │  │LocalServ.│  │FirebaseSv│  │PostsService│   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────┬──────┘   │
│       │             │             │              │           │
└───────┼─────────────┼─────────────┼──────────────┼───────────┘
        │             │             │              │
        ▼             ▼             ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐   │
│  │ REST API │  │  Hive DB │  │ Firebase │  │Localstore  │   │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Gestion de Estado

Se utiliza **Provider** con el patron `ChangeNotifier`:

```dart
// Ejemplo de uso en un widget
Consumer<HomeProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      itemCount: provider.posts.length,
      itemBuilder: (context, index) => PostCard(post: provider.posts[index]),
    );
  },
)
```

### Sistema de Cache

El cliente HTTP (Dio) implementa un sistema de cache inteligente:

- **Almacenamiento**: Hive (persistente) o Memory (para testing)
- **Politica**: Request-level caching
- **Duracion**: 7 dias maximo
- **Timeouts**: 5s conexion, 3s recepcion

---

## Comandos Utiles

### Desarrollo

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Limpiar cache de build
flutter clean && flutter pub get
```

### Construccion

```bash
# Build Android APK
flutter build apk

# Build Android App Bundle (para Play Store)
flutter build appbundle

# Build iOS
flutter build ios

# Build macOS
flutter build macos

# Build Web
flutter build web
```

### Generacion de Assets

```bash
# Generar iconos de la aplicacion
dart run flutter_launcher_icons:generate -f flutter_launcher_icons.yaml

# Generar splash screen
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

### Analisis de Codigo

```bash
# Ejecutar linter
dart analyze

# Formatear codigo
dart format lib/

# Verificar dependencias desactualizadas
flutter pub outdated
```

### Pruebas

```bash
# Ejecutar todas las pruebas
flutter test

# Ejecutar con cobertura
flutter test --coverage

# Ejecutar una prueba especifica
flutter test test/providers/home_provider_test.dart
```

---

## Pruebas

El proyecto incluye pruebas unitarias para modelos, providers y servicios.

### Estructura de Pruebas

```
test/
├── models/
│   ├── post_model_test.dart
│   └── storage_post_model_test.dart
├── providers/
│   ├── bookmark_provider_test.dart
│   ├── home_provider_test.dart
│   ├── notification_provider_test.dart
│   └── theme_provider_test.dart
└── services/
    └── http_service_test.dart
```

### Ejecutar Pruebas

```bash
# Todas las pruebas
flutter test

# Con cobertura
flutter test --coverage

# Generar reporte HTML (requiere lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Contribucion

Por favor, lee el archivo [CONTRIBUTING.md](CONTRIBUTING.md) para conocer las directrices de contribucion.

### Resumen Rapido

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/mi-nueva-caracteristica`)
3. Realiza tus cambios siguiendo las convenciones del proyecto
4. Escribe pruebas para tu codigo
5. Asegurate de que todas las pruebas pasen (`flutter test`)
6. Ejecuta el linter (`dart analyze`)
7. Haz commit de tus cambios (`git commit -m 'feat: agrega nueva caracteristica'`)
8. Push a la rama (`git push origin feature/mi-nueva-caracteristica`)
9. Abre un Pull Request

---

## Licencia

Este proyecto es software propietario desarrollado para la UNAM FES Iztacala.

---

## Creditos

### Desarrollo

- **Institucion**: Universidad Nacional Autonoma de Mexico (UNAM)
- **Facultad**: Facultad de Estudios Superiores Iztacala
- **Sistema**: Sistema Universidad Abierta y Educacion a Distancia (SUAyED)
- **Carrera**: Psicologia

### Tecnologias

- [Flutter](https://flutter.dev/) - Framework de desarrollo
- [Firebase](https://firebase.google.com/) - Backend services
- [Dio](https://pub.dev/packages/dio) - Cliente HTTP
- [Provider](https://pub.dev/packages/provider) - Gestion de estado
- [Hive](https://pub.dev/packages/hive) - Base de datos local

---

## Contacto

Para reportar problemas o sugerencias, por favor abre un Issue en el repositorio.

---

## Roadmap

Funcionalidades planeadas para futuras versiones:

- [ ] Enlaces a sitios de importancia para los alumnos
- [ ] Pantalla de notificaciones mejorada
- [ ] Tema oscuro (completado)
- [ ] Soporte multiidiomas
- [ ] Pantalla de videos
- [ ] Asistente virtual

---

<p align="center">
  <strong>Desarrollado con Flutter para la comunidad SUAyED</strong><br>
  UNAM FES Iztacala
</p>
