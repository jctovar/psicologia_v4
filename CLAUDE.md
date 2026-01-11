# CLAUDE.md

Este archivo proporciona orientacion a Claude Code (claude.ai/code) cuando trabaja con el codigo de este repositorio.

## Resumen del Proyecto

Esta es una aplicacion movil Flutter para la carrera de Psicologia del sistema SUAyED de la UNAM FES Iztacala. Proporciona noticias, eventos, areas de conocimiento, informacion de profesores, marcadores y notificaciones push a los estudiantes.

| Atributo | Valor |
|----------|-------|
| Nombre del paquete | `suayed` |
| Version | 0.8.120+20251014 |
| Flutter SDK | ^3.9.2 |
| Color principal | #d81b60 |
| API Base | https://suayed.iztacala.unam.mx/ |

---

## Comandos de Desarrollo

### Configuracion Inicial
```bash
flutter pub get          # Instalar dependencias
```

### Ejecucion
```bash
flutter run              # Ejecutar en dispositivo conectado o emulador
flutter run -d <id>      # Ejecutar en dispositivo especifico
flutter run --release    # Ejecutar en modo release
```

### Construccion
```bash
flutter build apk        # Build Android APK (release)
flutter build appbundle  # Build Android App Bundle (Play Store)
flutter build ios        # Build iOS app
flutter build macos      # Build macOS app
flutter build web        # Build version web
```

### Generacion de Assets
```bash
dart run flutter_launcher_icons:generate -f flutter_launcher_icons.yaml   # Generar iconos
dart run flutter_native_splash:create --path=flutter_native_splash.yaml   # Generar splash screen
```

### Calidad de Codigo
```bash
dart analyze             # Ejecutar linter
dart format lib/         # Formatear codigo
flutter clean            # Limpiar artefactos de build
flutter test             # Ejecutar pruebas
flutter test --coverage  # Ejecutar pruebas con cobertura
```

---

## Arquitectura

### Diagrama de Capas

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│     Screens (lib/screens/) + Widgets (lib/widgets/)         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   State Layer (Provider)                     │
│                    lib/providers/                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
│                     lib/services/                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│        REST API / Hive / Localstore / Firebase              │
└─────────────────────────────────────────────────────────────┘
```

### Gestion de Estado

Usa el paquete **Provider** (v6.1.2) para gestion de estado con el patron `ChangeNotifier`.

**Providers disponibles:**

| Provider | Archivo | Responsabilidad |
|----------|---------|-----------------|
| `HomeProvider` | lib/providers/home_provider.dart | Maneja posts/noticias con paginacion |
| `BookmarkProvider` | lib/providers/bookmark_provider.dart | Maneja posts guardados |
| `NotificationProvider` | lib/providers/notification_provider.dart | Maneja notificaciones push |
| `ThemeProvider` | lib/providers/theme_provider.dart | Maneja tema claro/oscuro |

**Ejemplo de uso:**

```dart
// Lectura reactiva (se reconstruye cuando cambia)
context.watch<HomeProvider>().posts

// Lectura unica (no se reconstruye)
context.read<HomeProvider>().fetchPosts()

// Con Consumer
Consumer<HomeProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return ShimmerPlaceholder();
    return ListView.builder(
      itemCount: provider.posts.length,
      itemBuilder: (_, i) => PostCard(post: provider.posts[i]),
    );
  },
)
```

### Capa de Servicios

La aplicacion sigue una separacion limpia entre llamadas API y logica de negocio:

| Servicio | Archivo | Responsabilidad |
|----------|---------|-----------------|
| `HttpProvider` | lib/services/posts_service.dart | Obtener posts con paginacion |
| `HttpService` | lib/services/http_service.dart | Configuracion de Dio con cache |
| `SuayedServices` | lib/services/suayed_service.dart | Operaciones de API de alto nivel (legacy) |
| `FirebaseService` | lib/services/firebase_service.dart | Inicializacion de Firebase y analytics |
| `CrashlyticsService` | lib/services/crashlytics_service.dart | Reporte de errores |
| `LocalService` | lib/services/local_service.dart | Operaciones de almacenamiento local |
| `AppLogger` | lib/services/logger_service.dart | Sistema de logging unificado |

**Configuracion HTTP (Dio):**
- Base URL: `https://suayed.iztacala.unam.mx/`
- Timeout de conexion: 5 segundos
- Timeout de recepcion: 3 segundos
- Politica de cache: 7 dias max stale con HiveCacheStore
- Interceptores: DioCacheInterceptor + LoggingInterceptor

### Modelos de Datos

Ubicados en lib/models/:

| Modelo | Archivo | Descripcion |
|--------|---------|-------------|
| `PostModel` | post_model.dart | Datos de noticias/posts de WordPress API |
| `StoragePostModel` | storage_post_model.dart | Datos de marcadores almacenados localmente |
| `AreaModel` | area_model.dart | Informacion de areas de conocimiento |
| `TeacherModel` | teacher_model.dart | Informacion de profesores |
| `NotificationModel` | notification_model.dart | Notificaciones push |

### Navegacion

Las rutas estan centralizadas en lib/routes/routes.dart:

| Ruta | Pantalla | Descripcion |
|------|----------|-------------|
| `/` | HomeScreen | Pantalla principal con noticias |
| `/teachers` | TeachersPage | Lista de profesores |
| `/areas` | AreasPage | Areas de conocimiento |
| `/bookmarks` | BookmarksScreen | Marcadores guardados |
| `/notifications` | NotificationsScreen | Historial de notificaciones |
| `/privacy` | PrivacyNotice | Aviso de privacidad |
| `/about` | AboutScreen | Informacion de la app |

### Estructura de UI

| Directorio | Contenido |
|------------|-----------|
| lib/screens/ | Pantallas/paginas de la aplicacion |
| lib/widgets/ | Componentes reutilizables |
| lib/theme.dart | Configuracion de tema Material Design |
| lib/utils/app_constants.dart | Constantes globales |

### Sistema Tipográfico

La aplicación usa un sistema tipográfico optimizado con dos fuentes complementarias:

**Fuentes:**
- **Poppins**: Títulos grandes y destacados (Display, Headline)
- **Montserrat**: Cuerpo de texto y UI general (Title, Body, Label)

**Jerarquía Material Design 3:**

| Estilo | Tamaño | Fuente | Uso |
|--------|--------|--------|-----|
| displayLarge | 57px | Poppins Bold | Pantallas de bienvenida |
| displayMedium | 45px | Poppins Bold | Títulos hero |
| displaySmall | 36px | Poppins SemiBold | Títulos grandes |
| headlineLarge | 32px | Poppins SemiBold | Encabezados de página |
| headlineMedium | 28px | Poppins SemiBold | Encabezados de sección |
| headlineSmall | 24px | Poppins SemiBold | Subtítulos principales |
| titleLarge | 22px | Montserrat Bold | Títulos de diálogos |
| titleMedium | 16px | Montserrat SemiBold | Títulos de tarjetas (más usado) |
| titleSmall | 14px | Montserrat SemiBold | Subtítulos |
| bodyLarge | 16px | Montserrat Regular | Párrafos (recomendado) |
| bodyMedium | 14px | Montserrat Regular | Texto secundario |
| bodySmall | 12px | Montserrat Regular | Metadatos, fechas |
| labelLarge | 14px | Montserrat SemiBold | Botones grandes |
| labelMedium | 12px | Montserrat SemiBold | Chips, tabs |
| labelSmall | 11px | Montserrat Medium | Badges |

**Uso correcto de tipografía:**

```dart
// ✅ CORRECTO - Usar estilos del tema
Text('Título', style: Theme.of(context).textTheme.titleMedium)

// ✅ CORRECTO - Modificar propiedades específicas
Text(
  'Título',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
)

// ❌ INCORRECTO - No usar GoogleFonts directamente
Text('Título', style: GoogleFonts.montserrat(fontSize: 16))
```

**Características de legibilidad:**
- Line height optimizado: 1.12-1.5 según el estilo
- Letter spacing ajustado: -0.25 a 0.5 según tamaño
- Colores con contraste WCAG AAA
- Respeta preferencias de accesibilidad del sistema

Ver `lib/theme_typography_guide.md` para documentación completa.

---

## Convenciones de Codigo

### Nombrado

| Tipo | Convencion | Ejemplo |
|------|------------|---------|
| Archivos | snake_case | `home_screen.dart`, `post_model.dart` |
| Clases | PascalCase | `HomeScreen`, `PostModel` |
| Variables | camelCase | `isLoading`, `errorMessage` |
| Constantes | camelCase o SCREAMING_SNAKE_CASE | `maxPostsInMemory`, `Constants.appName` |
| Metodos privados | _camelCase | `_buildTheme()`, `_initHiveCacheStore()` |
| Parametros nombrados | camelCase | `fetchPosts({bool refresh = false})` |

### Patrones de Codigo

**Patron para Screens:**
```dart
class MiScreen extends StatelessWidget {
  // Siempre definir routeName como constante estatica
  static const String routeName = '/mi-screen';

  final String title;

  const MiScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),  // Menu lateral
      body: Consumer<MiProvider>(
        builder: (context, provider, child) {
          // Manejar estados: loading, error, data
          if (provider.isLoading) return const ShimmerPlaceholder();
          if (provider.errorMessage != null) return EmptyState(message: provider.errorMessage!);
          return _buildContent(provider.data);
        },
      ),
    );
  }
}
```

**Patron para Providers:**
```dart
class MiProvider extends ChangeNotifier {
  // Estado privado
  List<MiModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters publicos
  List<MiModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Metodos de accion
  Future<void> fetchItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await MiService.getItems();
      AppLogger.i('Items cargados: ${_items.length}');
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e('Error cargando items', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**Patron para Servicios HTTP:**
```dart
class MiService {
  static Future<List<MiModel>> getItems() async {
    try {
      Response response = await dio.request('endpoint');
      return (response.data as List)
          .map((x) => MiModel.fromJson(x))
          .toList();
    } on DioException catch (e) {
      // Manejar diferentes tipos de error
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("No se pudo conectar al servidor.");
      }
      throw Exception("Ocurrio un error inesperado.");
    }
  }
}
```

### Mensajes de Error

Todos los mensajes de error estan en espanol (es-MX):

```dart
// Correcto
throw Exception("No se pudo conectar al servidor. Revisa tu conexion a internet.");

// Incorrecto
throw Exception("Could not connect to server.");
```

### Logging

Usar `AppLogger` para todos los logs:

```dart
AppLogger.d('Mensaje de debug');     // Debug
AppLogger.i('Mensaje informativo');  // Info
AppLogger.w('Advertencia');          // Warning
AppLogger.e('Error', exception);     // Error
AppLogger.f('Error fatal', exception, stackTrace);  // Fatal
```

---

## Dependencias Clave

| Paquete | Uso |
|---------|-----|
| `provider` | Gestion de estado |
| `dio` | Cliente HTTP |
| `dio_cache_interceptor` | Cache de peticiones HTTP |
| `http_cache_hive_store` | Almacenamiento de cache HTTP con Hive |
| `hive_flutter` | Base de datos local para cache |
| `localstore` | Persistencia de marcadores |
| `firebase_messaging` | Notificaciones push |
| `firebase_analytics` | Analiticas |
| `firebase_crashlytics` | Reporte de errores |
| `flutter_widget_from_html_core` | Renderizar HTML de WordPress |
| `cached_network_image` | Cache y display de imagenes |
| `google_fonts` | Fuente Montserrat |
| `shimmer` | Efecto de carga |

---

## Configuracion de Firebase

**Proyecto Firebase:** `app-de-psicologia-suayed`

**Archivos de configuracion:**
| Plataforma | Archivo | Ubicacion |
|------------|---------|-----------|
| Android | google-services.json | android/app/ |
| iOS | GoogleService-Info.plist | ios/Runner/ |
| macOS | GoogleService-Info.plist | macos/Runner/ |
| Dart | firebase_options.dart | lib/ (auto-generado) |

---

## Patrones Comunes

### Agregar una Nueva Pantalla

1. Crear un StatelessWidget o StatefulWidget en lib/screens/
2. Definir una constante `routeName` en la clase
3. Agregar la ruta a lib/routes/routes.dart
4. Agregar icono/item de menu a AppDrawer (lib/widgets/app_drawer.dart)

**Ejemplo:**

```dart
// lib/screens/nueva_screen.dart
class NuevaScreen extends StatelessWidget {
  static const String routeName = '/nueva';

  final String title;

  const NuevaScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Nueva pantalla')),
    );
  }
}

// lib/routes/routes.dart - agregar:
static const String nueva = NuevaScreen.routeName;
// En getRoutes():
Routes.nueva: (context) => const NuevaScreen(title: 'Nueva'),
```

### Obtener Datos de API

1. Agregar metodo a lib/services/posts_service.dart o crear nuevo servicio
2. Crear provider correspondiente si es necesario (lib/providers/)
3. Usar provider en pantalla con Consumer/context.watch()

### Almacenar Marcadores

- Usar BookmarkProvider (lib/providers/bookmark_provider.dart)
- Los datos persisten via LocalService usando localstore
- StoragePostModel mapea al formato de almacenamiento, PostModel al formato API

### Manejo de Errores

1. Los servicios lanzan excepciones con mensajes en espanol
2. Los providers capturan excepciones y almacenan en _errorMessage
3. La UI muestra errores via EmptyState o showSnackBar

```dart
// En servicio
throw Exception("No se pudo conectar al servidor.");

// En provider
catch (e) {
  _errorMessage = e.toString();
  AppLogger.e('Error', e);
}

// En UI
if (provider.errorMessage != null) {
  return EmptyState(message: provider.errorMessage!);
}
```

---

## Assets y Recursos

| Ubicacion | Contenido |
|-----------|-----------|
| assets/ | Directorio raiz de assets |
| assets/images/ | Imagenes |
| assets/icon/ | Iconos de la aplicacion |
| assets/areas.json | Datos de areas de conocimiento (fallback) |
| assets/teachers.json | Datos de profesores (fallback) |
| assets/privacity.html | Aviso de privacidad |

---

## Notas Importantes

- **API base URL**: Definida en Constants.uriHttp (lib/utils/app_constants.dart)
- **Mensajes de error**: Todos en espanol (es-MX)
- **Placeholder de imagen**: assets/images/no_image.jpg
- **Color principal**: #d81b60 (rosa institucional)
- **Fuentes**: Poppins (títulos) + Montserrat (cuerpo) - precargadas al inicio
- **Temas**: Soporte claro/oscuro con cumplimiento WCAG AA/AAA
- **Cache HTTP**: 7 dias con HiveCacheStore
- **Limite de posts en memoria**: 200 (para prevenir memory leaks)

---

## Testing

El proyecto incluye pruebas unitarias:

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

Para ejecutar pruebas:
```bash
flutter test                    # Todas las pruebas
flutter test --coverage         # Con cobertura
flutter test test/providers/    # Solo providers
```

---

## Flujos de Datos Importantes

### Flujo de Carga de Posts

```
HomeScreen.initState()
       │
       ▼
HomeProvider.fetchPosts()
       │
       ▼
HttpProvider.getPosts()
       │
       ▼
dio.request() ─────► DioCacheInterceptor
       │                    │
       │              ┌─────┴─────┐
       │              │           │
       │         Cache Hit   Cache Miss
       │              │           │
       │              ▼           ▼
       │         Retorna      API Call
       │         Cache            │
       │                          ▼
       │                    Guarda en
       │                      Hive
       │                          │
       └──────────────────────────┘
                    │
                    ▼
            PostModel.fromJson()
                    │
                    ▼
            HomeProvider.notifyListeners()
                    │
                    ▼
            UI se reconstruye
```

### Flujo de Guardado de Marcador

```
PostCard ────► onBookmark()
                   │
                   ▼
          BookmarkProvider.addBookmark()
                   │
                   ▼
          LocalService.addPost()
                   │
                   ▼
          localstore.collection().doc().set()
                   │
                   ▼
          notifyListeners()
                   │
                   ▼
          UI actualiza icono
```

---

## Inicializacion de la App

El flujo de inicializacion en `main.dart`:

```dart
main()
  │
  ├─► runZonedGuarded()        // Captura errores asincronos
  │
  ├─► Hive.initFlutter()       // Inicializa Hive para cache
  │
  ├─► initHttpService()        // Configura Dio con cache persistente
  │
  ├─► AppFonts.preloadFonts()  // Precarga Poppins + Montserrat
  │
  ├─► FirebaseService.initialize()  // Firebase Core + Analytics + FCM
  │
  ├─► CrashlyticsService.initialize()  // Crashlytics
  │
  └─► runApp(AppState())       // Inicia la app con MultiProvider
```
