# CLAUDE.md

Este archivo proporciona orientacion a Claude Code (claude.ai/code) cuando trabaja con el codigo de este repositorio.

## Resumen del Proyecto

Esta es una aplicacion movil Flutter para la carrera de Psicologia del sistema SUAyED de la UNAM FES Iztacala. Proporciona noticias, eventos, calendario escolar, areas de conocimiento, informacion de profesores, marcadores y notificaciones push a los estudiantes.

| Atributo | Valor |
|----------|-------|
| Nombre del paquete | `suayed` |
| Version | 0.9.30+20260110 |
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
| `CalendarioService` | lib/services/calendario_service.dart | Obtener calendario escolar desde JSON externo |
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
- Store de cache: HiveCacheStore (almacenamiento persistente)

**URLs externas adicionales:**
- Calendario escolar JSON: `https://jctovar.github.io/calendario.json` (CalendarioService)

#### Servicio de Analytics Centralizado

El archivo `lib/utils/analytics.dart` proporciona un servicio centralizado para rastrear eventos y navegación con Firebase Analytics.

**Eventos disponibles:**

```dart
// Rastrear evento personalizado
await Analytics.logEvent(
  name: 'nombre_evento',
  parameters: {'parametro1': 'valor1'},
);

// Rastrear navegación (automático con observer en routes)
await Analytics.logScreenView(
  screenName: 'mi_pantalla',
  screenClass: 'MiScreen',
);

// Rastrear búsqueda
await Analytics.logSearch(searchTerm: 'termino_busqueda');

// Rastrear visualización de contenido
await Analytics.logViewContent(
  contentType: 'post',
  itemId: '12345',
  parameters: {'titulo': 'Mi Post'},
);

// Rastrear bookmark
await Analytics.logBookmarkAdded(postId: '12345');

// Rastrear notificación abierta
await Analytics.logNotificationOpened(notificationId: 'push123');

// Rastrear compartir
await Analytics.logShare(
  contentType: 'post',
  itemId: '12345',
);

// Rastrear error
await Analytics.logAppError(
  errorType: 'network_error',
  errorMessage: 'No se pudo conectar al servidor',
);
```

**Integración con Navigator:**
El `Analytics.observer` se registra automáticamente en `main.dart` para rastrear navegación automáticamente.

### Modelos de Datos

Ubicados en lib/models/:

| Modelo | Archivo | Descripcion |
|--------|---------|-------------|
| `PostModel` | post_model.dart | Datos de noticias/posts de WordPress API |
| `StoragePostModel` | storage_post_model.dart | Datos de marcadores almacenados localmente |
| `AreaModel` | area_model.dart | Informacion de areas de conocimiento |
| `TeacherModel` | teacher_model.dart | Informacion de profesores |
| `NotificationModel` | notification_model.dart | Notificaciones push |
| `CalendarioModel` | calendario_model.dart | Modelo raiz del calendario escolar con periodos y dias inhabiles |
| `ContactoModel` | calendario_model.dart | Informacion de contacto institucional |
| `PeriodoModel` | calendario_model.dart | Semestre academico con eventos |
| `EventoModel` | calendario_model.dart | Evento del calendario con fechas y descripcion |
| `PeriodoFechaModel` | calendario_model.dart | Sub-periodos anidados en eventos |
| `DiaInhabilModel` | calendario_model.dart | Dias inhabiles y vacaciones |

### Navegacion

Las rutas estan centralizadas en lib/routes/routes.dart:

| Ruta | Pantalla | Descripcion |
|------|----------|-------------|
| `/` | HomeScreen | Pantalla principal con noticias |
| `/teachers` | TeachersPage | Lista de profesores |
| `/areas` | AreasPage | Areas de conocimiento |
| `/calendario` | CalendarioScreen | Calendario escolar con eventos y periodos academicos |
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

La aplicación usa un sistema tipográfico optimizado con dos fuentes complementarias precargadas al inicio:

**Fuentes:**
- **Poppins**: Títulos grandes y destacados (Display, Headline). Moderna y con personalidad académica.
- **Montserrat**: Cuerpo de texto y UI general (Title, Body, Label). Excelente legibilidad en pantallas digitales.

**Jerarquía Material Design 3 con cumplimiento WCAG AAA:**

| Estilo | Tamaño | Fuente | Altura | Uso |
|--------|--------|--------|--------|-----|
| displayLarge | 57px | Poppins Bold | 1.12 | Pantallas de bienvenida |
| displayMedium | 45px | Poppins Bold | 1.16 | Títulos hero |
| displaySmall | 36px | Poppins SemiBold | 1.22 | Títulos grandes |
| headlineLarge | 32px | Poppins SemiBold | 1.25 | Encabezados de página |
| headlineMedium | 28px | Poppins SemiBold | 1.29 | Encabezados de sección |
| headlineSmall | 24px | Poppins SemiBold | 1.33 | Subtítulos principales |
| titleLarge | 22px | Montserrat Bold | 1.27 | Títulos de diálogos |
| titleMedium | 16px | Montserrat SemiBold | 1.5 | Títulos de tarjetas (más usado) |
| titleSmall | 14px | Montserrat SemiBold | 1.43 | Subtítulos |
| bodyLarge | 16px | Montserrat Regular | 1.5 | Párrafos (recomendado) |
| bodyMedium | 14px | Montserrat Regular | 1.43 | Texto secundario |
| bodySmall | 12px | Montserrat Regular | 1.33 | Metadatos, fechas |
| labelLarge | 14px | Montserrat SemiBold | 1.43 | Botones grandes |
| labelMedium | 12px | Montserrat SemiBold | 1.33 | Chips, tabs |
| labelSmall | 11px | Montserrat Medium | 1.45 | Badges |

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

**Características de accesibilidad y legibilidad:**
- Line height optimizado: 1.12-1.5 según el estilo para óptima legibilidad
- Letter spacing ajustado: -0.25 a 0.5 según tamaño de fuente
- Colores con contraste WCAG AAA (ratio ≥ 7:1) para todos los textos principales
- Colores WCAG AA (ratio ≥ 4.5:1) para texto secundario
- Respeta preferencias de accesibilidad del sistema (large fonts, high contrast)
- Temas claro y oscuro con colores específicamente calibrados para ambos modos

**Paleta de colores WCAG AA/AAA:**
- Tema claro: Textos oscuros (#212121, #424242, #616161) sobre fondo claro (#FDF8F8)
- Tema oscuro: Textos claros (#E8E8E8, #BDBDBD) sobre fondo oscuro (#121212, #1E1E1E)
- Rosa rosa principal (#d81b60) para títulos con contraste óptimo en ambos temas

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

| Paquete | Version | Uso |
|---------|---------|-----|
| `provider` | ^6.1.2 | Gestion de estado con ChangeNotifier |
| `dio` | ^5.9.0 | Cliente HTTP con interceptores |
| `dio_cache_interceptor` | ^4.0.5 | Cache inteligente de peticiones HTTP |
| `http_cache_hive_store` | ^5.0.1 | Almacenamiento persistente de cache con Hive |
| `hive_flutter` | ^1.1.0 | Base de datos NoSQL local para cache y datos |
| `localstore` | ^1.3.1 | Persistencia JSON para marcadores |
| `firebase_core` | ^4.2.0 | Core de Firebase (requerido por otros servicios) |
| `firebase_messaging` | ^16.0.3 | Notificaciones push FCM |
| `firebase_analytics` | ^12.0.3 | Analiticas de eventos y navegación |
| `firebase_crashlytics` | ^5.0.6 | Reporte y monitoreo de errores |
| `flutter_widget_from_html_core` | ^0.17.0 | Renderizar HTML/CSS de WordPress API |
| `cached_network_image` | ^3.1.0 | Cache y display optimizado de imagenes |
| `google_fonts` | ^7.0.0 | Fuentes Poppins y Montserrat precargadas |
| `shimmer` | ^3.0.0 | Efecto shimmer para placeholders de carga |
| `share_plus` | ^12.0.0 | Compartir contenido via sistema nativo |
| `url_launcher` | ^6.3.2 | Abrir URLs, emails y llamadas |
| `intl` | ^0.19.0 | Formateo de fechas y números en español |

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

### Calendario Escolar

El calendario escolar se obtiene desde un JSON externo hospedado en GitHub Pages. La pantalla incluye búsqueda, filtros y funcionalidad offline con cache.

**Servicio CalendarioService:**

```dart
// Obtener calendario desde URL externa con cache
CalendarioModel calendario = await CalendarioService.getCalendario();

// Forzar actualización ignorando cache
CalendarioModel calendario = await CalendarioService.getCalendario(forceRefresh: true);
```

**URL del JSON:** `https://jctovar.github.io/calendario.json`

**Características:**
- Cache HTTP persistente (7 días max-stale con HiveCacheStore)
- Funciona offline mientras cache sea válido
- Pull-to-refresh para actualización manual
- Búsqueda por nombre y descripción de eventos
- Filtrado por tipo: Vacaciones, Exámenes, Inscripción, Calificaciones, Administrativo
- ExpansionTile agrupado por semestre
- Diálogo de detalles con información completa del evento
- Soporte para URLs externas (convocatorias, formularios)
- Analytics integrado para rastrear vistas y filtros

**Estructura de datos:**

```dart
CalendarioModel
  ├─ institucion: String
  ├─ modalidad: String
  ├─ nivel: String
  ├─ contacto: ContactoModel
  │    ├─ departamento: String
  │    ├─ telefono: String
  │    ├─ email: String
  │    └─ sitioWeb: String
  ├─ periodos: List<PeriodoModel>
  │    ├─ nombre: String (ej: "2025-1")
  │    ├─ tipo: String (ej: "Semestre")
  │    ├─ fechaInicio: String
  │    ├─ fechaFin: String
  │    └─ eventos: List<EventoModel>
  │         ├─ nombre: String
  │         ├─ tipo: String (Vacaciones, Examenes, Inscripcion, Calificaciones, Administrativo)
  │         ├─ fechaInicio: String? (opcional)
  │         ├─ fechaFin: String? (opcional)
  │         ├─ descripcion: String? (opcional)
  │         ├─ url: String? (opcional)
  │         └─ periodos: List<PeriodoFechaModel>? (opcional, sub-periodos anidados)
  └─ diasInhabiles: List<DiaInhabilModel>
       ├─ fecha: String
       ├─ motivo: String
       └─ tipo: String
```

**Iconos por tipo de evento:**

| Tipo | Icono | LineIcons |
|------|-------|-----------|
| Vacaciones | LineIcons.umbrellaAlt | umbrella |
| Exámenes | LineIcons.fileAlt | file |
| Inscripción | LineIcons.userPlus | user-plus |
| Calificaciones | LineIcons.tasks | tasks |
| Administrativo | LineIcons.cog | cog |
| Default | LineIcons.calendarAlt | calendar |

**Ejemplo de uso en pantalla:**

```dart
// La pantalla no requiere provider, maneja estado localmente con StatefulWidget
class CalendarioScreen extends StatefulWidget {
  static const String routeName = 'calendario';

  @override
  _CalendarioScreenState createState() => _CalendarioScreenState();
}

// Formato de fechas en español
String formatearFecha(String fecha) {
  DateTime dt = DateTime.parse(fecha);
  return DateFormat('d \'de\' MMMM \'de\' y', 'es').format(dt);
}
```

**Analytics:**
```dart
// Rastrear vista de calendario
Analytics.logScreenView(
  screenName: 'calendario',
  screenClass: 'CalendarioScreen',
);

// Rastrear uso de filtros
Analytics.logEvent(
  name: 'calendario_filtro_aplicado',
  parameters: {'tipo_filtro': 'Examenes'},
);
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

### Configuración

- **API base URL**: Definida en Constants.uriHttp (lib/utils/app_constants.dart)
- **Color principal**: #d81b60 (rosa institucional UNAM FES Iztacala)
- **Colores secundarios**: Púrpura #7B1FA2, Verde azulado #00897B

### Internacionalización y Mensajes

- **Idioma**: Español (es-MX) para todos los mensajes de usuario y error
- **Todos los mensajes de error**: Deben estar en español con contexto útil para el usuario
- **Ejemplo correcto**: "No se pudo conectar al servidor. Revisa tu conexión a internet."

### Tipografía y Accesibilidad

- **Fuentes**: Poppins (títulos) + Montserrat (cuerpo) - precargadas al inicio de la app
- **Precarga**: AppFonts.preloadFonts() se llama en main.dart para mejor rendimiento offline
- **Temas**: Soporte claro/oscuro con transiciones suaves (300ms) y cumplimiento WCAG AA/AAA
- **Animaciones tema**: Las transiciones de tema usan Curves.easeInOut para mejor UX

### Caché y Persistencia

- **Cache HTTP**: Almacenamiento persistente con HiveCacheStore (7 días max-stale)
- **Interceptadores**: DioCacheInterceptor + LoggingInterceptor en Dio
- **Persistencia de marcadores**: localstore (JSON) via BookmarkProvider + LocalService
- **Base de datos Hive**: Usada para cache HTTP y datos locales persistentes

### Rendimiento

- **Limite de posts en memoria**: 200 (para prevenir memory leaks)
- **Placeholder de imagen**: assets/images/no_image.jpg
- **Lazy loading**: Implementado en listas con paginación
- **Precarga de assets**: Fuentes se precargan al iniciar la app

### Analytics y Monitoreo

- **Firebase Analytics**: Integrado via `Analytics` class (lib/utils/analytics.dart)
- **Navegación automática**: Rastreada via `Analytics.observer` en routes
- **Eventos personalizados**: Disponibles para bookmarks, búsquedas, compartir, etc.
- **Crashlytics**: Integrado para monitoreo de errores en producción
- **Logging**: Centralizado con AppLogger (debug, info, warning, error, fatal)

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

### Flujo de Carga del Calendario Escolar

```
CalendarioScreen.initState()
       │
       ▼
_cargarCalendario()
       │
       ▼
CalendarioService.getCalendario()
       │
       ▼
dio.get(URL_EXTERNA) ─────► DioCacheInterceptor
       │                           │
       │                     ┌─────┴─────┐
       │                     │           │
       │                Cache Hit   Cache Miss
       │                     │           │
       │                     ▼           ▼
       │                Retorna      HTTP GET
       │                Cache       (GitHub Pages)
       │                     │           │
       │                     │           ▼
       │                     │      Guarda en
       │                     │        Hive
       │                     │           │
       └─────────────────────┴───────────┘
                             │
                             ▼
                  CalendarioModel.fromJson()
                             │
                             ▼
                  setState() con calendario
                             │
                             ▼
                  UI se reconstruye con ExpansionTiles
```

---

## Inicializacion de la App

El flujo de inicializacion en `main.dart` con manejo de errores asincronos:

```dart
main()
  │
  ├─► runZonedGuarded(() async {
  │     │
  │     ├─► Hive.initFlutter()
  │     │   └─ Inicializa base de datos local para cache persistente
  │     │
  │     ├─► initHttpService()
  │     │   ├─ Crea HiveCacheStore para cache persistente
  │     │   ├─ Configura CacheOptions (7 días max-stale)
  │     │   ├─ Inicializa Dio con base URL y timeouts
  │     │   └─ Añade interceptadores: DioCacheInterceptor + LoggingInterceptor
  │     │
  │     ├─► AppFonts.preloadFonts()
  │     │   ├─ Precarga Poppins con pesos: 400, 500, 600, 700, 800
  │     │   └─ Precarga Montserrat con pesos: 400, 500, 600, 700, 800
  │     │
  │     ├─► FirebaseService.initialize()
  │     │   ├─ Firebase.initializeApp() con configuración automática
  │     │   ├─ Firebase Analytics: logEvent, logScreenView, etc.
  │     │   └─ Firebase Messaging: FCM para notificaciones push
  │     │
  │     ├─► CrashlyticsService.initialize()
  │     │   ├─ Crashlytics.instance.recordFlutterError()
  │     │   └─ Captura excepciones no manejadas
  │     │
  │     └─► runApp(AppState())
  │         └─ MultiProvider con: ThemeProvider, HomeProvider,
  │            BookmarkProvider, NotificationProvider
  │
  └─► Manejo de errores asincronos con AppLogger.f()
```

**Configuración de caché HTTP:**
- **Política**: Request-based con max-stale de 7 días
- **Store**: HiveCacheStore (persistente en disco)
- **Cifrado**: Deshabilitado (permitir datos sin cifrar)
- **POST**: No cachear (solo GET)
- **Priority**: Normal

**Captura de errores asincronos:**
Los errores que ocurren fuera de runApp() son capturados y registrados con `AppLogger.f()` para debugging en Crashlytics.
