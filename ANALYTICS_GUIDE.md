# Guía de Firebase Analytics

Esta guía documenta cómo usar el sistema centralizado de Firebase Analytics en la aplicación SUAyED.

## Resumen

El servicio `Analytics` (ubicado en `lib/utils/analytics.dart`) proporciona una interfaz centralizada para rastrear eventos de usuario y navegación mediante Firebase Analytics.

**Características:**

- Rastreo automático de navegación mediante `FirebaseAnalyticsObserver`
- Métodos estáticos simples para eventos personalizados
- Manejo robusto de errores sin interrupciones en la app
- Logging integrado con AppLogger para debugging

## Integración Automática

El rastreo de navegación está integrado automáticamente en `main.dart`:

```dart
MaterialApp(
  navigatorObservers: [
    Analytics.observer,  // Rastrea cada navegación automáticamente
  ],
)
```

**Qué se rastrea automáticamente:**

- Cada vez que el usuario navega a una nueva pantalla
- Parámetros de ruta si están disponibles
- Duración del tiempo en cada pantalla

## Eventos Disponibles

### 1. Evento Personalizado

Rastrear cualquier evento personalizado con parámetros opcionales.

```dart
import 'package:suayed/utils/analytics.dart';

await Analytics.logEvent(
  name: 'post_search',
  parameters: {
    'search_term': 'psicología',
    'result_count': 42,
  },
);
```

**Mejores prácticas:**

- Nombres de eventos: snake_case, descriptivos
- Parámetros: máximo 25, valores simples (string, int, double, bool)
- Nombres de parámetros: snake_case
- Ejemplo real: `bookmark_added`, `notification_received`, `video_played`

### 2. Vista de Pantalla

Rastrear que el usuario vio una pantalla (automático, pero puedes forzar manual):

```dart
await Analytics.logScreenView(
  screenName: 'post_detail',
  screenClass: 'PostDetail',
);
```

**Cuándo usar:**

- Solo si necesitas rastrear vista manual (raro)
- La navegación automática es suficiente para la mayoría de casos
- Útil para screens que no usan Navigator (web, custom routes)

### 3. Búsqueda

Rastrear búsquedas de usuarios.

```dart
await Analytics.logSearch(
  searchTerm: 'psicología evolutiva',
);
```

**Cuándo usar:**

- Campo de búsqueda en HomeScreen
- Filtros en TeachersScreen
- Búsquedas en AreasScreen

**Ejemplo en código:**

```dart
void _onSearchSubmitted(String query) {
  Analytics.logSearch(searchTerm: query);
  homeProvider.searchPosts(query);
}
```

### 4. Vista de Contenido

Rastrear cuando el usuario visualiza contenido específico.

```dart
await Analytics.logViewContent(
  contentType: 'post',
  itemId: '12345',
  parameters: {
    'title': 'Introducción a la Psicología',
    'category': 'noticias',
  },
);
```

**Cuándo usar:**

- Usuario abre PostDetail
- Usuario abre TeacherDetail
- Usuario visualiza contenido HTML

**Ejemplo en código:**

```dart
// En PostDetail.initState()
@override
void initState() {
  super.initState();
  Analytics.logViewContent(
    contentType: 'post',
    itemId: widget.postModel.id.toString(),
    parameters: {
      'title': widget.postModel.title,
    },
  );
}
```

### 5. Marcador Agregado

Rastrear cuando el usuario guarda un post a marcadores.

```dart
await Analytics.logBookmarkAdded(
  postId: '12345',
);
```

**Dónde se usa:**

- En `BookmarkProvider.addBookmark()`
- En handlers de botones "Guardar"

**Ejemplo:**

```dart
class BookmarkProvider extends ChangeNotifier {
  Future<void> addBookmark(PostModel post) async {
    try {
      await LocalService.addPost(post);
      Analytics.logBookmarkAdded(postId: post.id.toString());
      notifyListeners();
    } catch (e) {
      AppLogger.e('Error guardando bookmark', e);
    }
  }
}
```

### 6. Notificación Abierta

Rastrear cuando el usuario abre una notificación push.

```dart
await Analytics.logNotificationOpened(
  notificationId: 'push_123_xyz',
);
```

**Dónde se usa:**

- En handlers de FCM cuando usuario toca notificación
- En `NotificationProvider` cuando procesa notificación

**Ejemplo:**

```dart
// En FirebaseService.handleMessage()
void handleMessage(RemoteMessage message) {
  Analytics.logNotificationOpened(
    notificationId: message.messageId ?? 'unknown',
  );
  // Navegar a pantalla apropiada
}
```

### 7. Compartir Contenido

Rastrear cuando el usuario comparte contenido.

```dart
await Analytics.logShare(
  contentType: 'post',
  itemId: '12345',
);
```

**Dónde se usa:**

- En botones "Compartir" de PostCard/PostDetail
- Cuando se usa `share_plus`

**Ejemplo:**

```dart
void _sharePost(PostModel post) async {
  await Share.share(post.title);
  Analytics.logShare(
    contentType: 'post',
    itemId: post.id.toString(),
  );
}
```

### 8. Error de la App

Rastrear errores importantes en la aplicación.

```dart
await Analytics.logAppError(
  errorType: 'network_error',
  errorMessage: 'Connection timeout after 5s',
);
```

**Cuándo usar:**

- Errores de red críticos
- Errores de validación
- Fallos al cargar datos importantes
- **No usar para**: Debug logs, logs de flujo normal

**Ejemplo:**

```dart
class HomeProvider extends ChangeNotifier {
  Future<void> fetchPosts() async {
    try {
      _posts = await HttpProvider.getPosts();
    } catch (e) {
      _errorMessage = e.toString();
      Analytics.logAppError(
        errorType: 'fetch_posts_failed',
        errorMessage: e.toString(),
      );
      AppLogger.e('Error cargando posts', e);
    }
  }
}
```

## Manejo de Errores

Todos los métodos de Analytics capturan excepciones internas sin interrumpir el flujo de la app.

```dart
static Future<void> logEvent({
  required String name,
  Map<String, Object>? parameters,
}) async {
  try {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  } catch (e) {
    // Error capturado, la app continúa funcionando
    AppLogger.w('Analytics event failed: $e');
  }
}
```

**Implicaciones:**

- Fallos en Analytics nunca rompen la experiencia del usuario
- Errores se registran en AppLogger (útil para debugging)
- No es necesario envolver llamadas de Analytics en try-catch

## Buenas Prácticas

### 1. Nombres Descriptivos

```dart
// ✅ BIEN
Analytics.logEvent(name: 'post_opened');
Analytics.logSearch(searchTerm: 'psicología evolutiva');

// ❌ MALO
Analytics.logEvent(name: 'event1');
Analytics.logSearch(searchTerm: 'abc');
```

### 2. Parámetros Útiles

```dart
// ✅ BIEN - Información contextual relevante
await Analytics.logViewContent(
  contentType: 'teacher',
  itemId: teacher.id.toString(),
  parameters: {
    'department': 'Psicología Clínica',
    'experience_years': 15,
  },
);

// ❌ MALO - Parámetros que no aportan valor
await Analytics.logViewContent(
  contentType: 'teacher',
  itemId: teacher.id.toString(),
  parameters: {
    'timestamp': DateTime.now().toString(),
    'uuid': uuid.v4(),
  },
);
```

### 3. Privacidad de Datos

```dart
// ✅ BIEN - Información generalizadora
await Analytics.logEvent(
  name: 'search_performed',
  parameters: {
    'category': 'posts',
    'result_count': 5,
  },
);

// ❌ MALO - Datos personales
await Analytics.logEvent(
  name: 'search_performed',
  parameters: {
    'user_email': user.email,  // NUNCA
    'full_name': user.name,    // NUNCA
  },
);
```

### 4. Frecuencia Moderada

```dart
// ✅ BIEN - Evento importante
await Analytics.logBookmarkAdded(postId: '123');

// ❌ MALO - Muy frecuente (ralentiza app)
// No registrar cada milisegundo mientras el usuario scrollea
```

### 5. Integración con Logging

```dart
// ✅ BIEN - Analytics + Logger juntos
try {
  await operation();
  Analytics.logEvent(name: 'operation_success');
  AppLogger.i('Operation completed successfully');
} catch (e) {
  Analytics.logAppError(
    errorType: 'operation_failed',
    errorMessage: e.toString(),
  );
  AppLogger.e('Operation failed', e);
}
```

## Casos de Uso Comunes

### Rastrear Post Visto

```dart
// En PostDetail.initState()
Analytics.logViewContent(
  contentType: 'post',
  itemId: widget.postModel.id.toString(),
  parameters: {
    'title': widget.postModel.title,
    'author': widget.postModel.author,
    'date': widget.postModel.date.toIso8601String(),
  },
);
```

### Rastrear Profesor Visto

```dart
// En TeacherDetail.initState()
Analytics.logViewContent(
  contentType: 'teacher',
  itemId: widget.item.id,
  parameters: {
    'name': widget.item.firstname,
    'department': widget.item.fields,
  },
);
```

### Rastrear Búsqueda con Resultados

```dart
void _performSearch(String query) {
  final results = searchPosts(query);
  Analytics.logSearch(searchTerm: query);
  Analytics.logEvent(
    name: 'search_completed',
    parameters: {
      'query': query,
      'result_count': results.length,
    },
  );
}
```

### Rastrear Navegación de Menu

```dart
// En AppDrawer al navegar
onTap: () {
  Analytics.logEvent(
    name: 'menu_navigation',
    parameters: {'destination': 'bookmarks'},
  );
  Navigator.pushNamed(context, Routes.bookmarks);
}
```

## Dashboard en Firebase Console

Para ver los datos en Firebase Console:

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Seleccionar proyecto `app-de-psicologia-suayed`
3. Analytics → Events
4. Ver eventos en tiempo real o reportes históricos

**Eventos predefinidos que Firebase rastrea automáticamente:**

- `screen_view` (rastreado por observer)
- `session_start`
- `session_end`
- `app_open`

**Eventos personalizados:**

- `search` (de Analytics.logSearch)
- `view_item` (de Analytics.logViewContent)
- `share` (de Analytics.logShare)
- `app_error` (de Analytics.logAppError)
- Y cualquier otro con Analytics.logEvent

## Debugging

### Ver logs de Analytics en consola

Analytics usa AppLogger para registrar eventos:

```bash
# En Android Studio Logcat
flutter clean
flutter run

# Buscar líneas con "Analytics"
# 📊 Analytics event: post_opened
# 📊 Analytics screen: post_detail
```

### Habilitar modo debug en Firebase Analytics

```dart
// En FirebaseService.initialize()
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Opcional: en desarrollo
if (kDebugMode) {
  await FirebaseAnalytics.instance.setDefaultEventParameters({
    'environment': 'development',
  });
}
```

## Limitaciones y Consideraciones

### Límites de Firebase Analytics

- Máximo 500 eventos diferentes
- Máximo 25 parámetros por evento
- Máximo 100 bytes por nombre de evento
- Máximo 100 caracteres por valor de parámetro

### Latencia

- Los eventos se envían cada 60 segundos
- En desarrollo (debug): puede haber retrasos
- En producción (release): envío más eficiente

### Almacenamiento

- Datos se retienen 60 días por defecto
- Los eventos se envían si hay conexión
- Si no hay conexión, se envían cuando vuelve

## Testing

Para pruebas unitarias que usan Analytics:

```dart
// Mock Firebase Analytics
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

// En test
setUp(() {
  // Analytics.logEvent() no falla en testing
  // Simplemente no hace nada en tests
});

test('logEvent is called when post is opened', () async {
  // El test pasa aunque Analytics falle
  // porque Analytics captura excepciones internamente
});
```

## Referencias

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Firebase Analytics Events](https://support.google.com/firebase/answer/9234069)
- [Analytics Best Practices](https://firebase.google.com/docs/analytics/best-practices)

## Changelog

### v1.0 (Actual)

- Servicio centralizado Analytics
- 8 métodos para rastrear eventos
- Integración automática con Navigator
- Manejo robusto de errores
- Logging integrado
