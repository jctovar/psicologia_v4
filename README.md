# Psicología SUAyED - FES Iztacala

Aplicación móvil desarrollada en Flutter para la comunidad de la carrera de Psicología en el sistema SUAyED de la FES Iztacala, UNAM.

## ✨ Características

*   **Noticias y Eventos:** Mantente al día con las últimas publicaciones y avisos de la carrera.
*   **Áreas de Conocimiento:** Explora las diferentes áreas de la psicología disponibles en el plan de estudios.
*   **Planta Docente:** Consulta información sobre los profesores de la carrera.
*   **Marcadores:** Guarda publicaciones importantes para leerlas más tarde.
*   **Notificaciones Push:** Recibe notificaciones importantes directamente en tu dispositivo.
*   **Acerca de y Créditos:** Información sobre el desarrollo de la aplicación.

## 🛠️ Stack Tecnológico

*   **Framework:** [Flutter](https://flutter.dev/)
*   **Lenguaje:** [Dart](https://dart.dev/)
*   **Gestión de Estado:** setState / ValueNotifier (implícito por la estructura)
*   **Peticiones HTTP:** [Dio](https://pub.dev/packages/dio) con [DioCacheInterceptor](https://pub.dev/packages/dio_cache_interceptor) para caché.
*   **Notificaciones:** [Firebase Cloud Messaging](https://pub.dev/packages/firebase_messaging)
*   **Almacenamiento Local:** [Shared Preferences](https://pub.dev/packages/shared_preferences) y [localstore](https://pub.dev/packages/localstore) para marcadores.
*   **Renderizado de HTML:** [flutter_widget_from_html_core](https://pub.dev/packages/flutter_widget_from_html_core)

## 📂 Estructura del Proyecto

Una descripción general de los directorios clave en `lib/`:

*   `lib/models`: Contiene los modelos de datos para áreas, posts, profesores, etc.
*   `lib/screens`: Contiene las diferentes pantallas o vistas de la aplicación.
*   `lib/services`: Lógica para consumir servicios externos (API de WordPress) y locales (base de datos).
*   `lib/widgets`: Widgets reutilizables como el menú lateral (`drawer`), avatares, etc.
*   `lib/utils`: Clases de utilidad y constantes de la aplicación.
*   `lib/routes`: Definición de las rutas de navegación de la app.
*   `main.dart`: Punto de entrada principal de la aplicación.

## 🚀 Cómo empezar

1.  **Clona el repositorio:**
    ```bash
    git clone <URL_DEL_REPOSITORIO>
    cd psicologia_v4
    ```

2.  **Instala las dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Configura Firebase:**
    Asegúrate de tener los archivos `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) en las carpetas correspondientes.

4.  **Ejecuta la aplicación:**
    ```bash
    flutter run
    ```

## 📝 Comandos Útiles

Para generar los iconos de la aplicación y la pantalla de bienvenida (splash screen), puedes usar los siguientes comandos:

*   **Generar Iconos:**
    ```bash
    flutter pub run flutter_launcher_icons
    ```

*   **Generar Splash Screen:**
    ```bash
    flutter pub run flutter_native_splash:create
    ```


# psicologia4

https://suayed.iztacala.unam.mx/?rest_route=/wp/v2/posts&per_page=15
Main color: "#d81b60"