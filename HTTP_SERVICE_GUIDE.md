# Guía de Servicio HTTP y Cache

Documentación del sistema HTTP centralizado con cache persistente en `lib/services/http_service.dart`.

## Resumen

El servicio HTTP implementa:

- Cliente Dio configurado con base URL y timeouts
- Cache persistente con HiveCacheStore (7 días máximo)
- Interceptadores para cache y logging
- Soporte para testing con cache en memoria
- Inicialización asincrónica garantizada

## Configuración

### Variables Globales

```dart
// Cliente HTTP principal
late final Dio dio;

// Opciones de caché
late CacheOptions cacheOptions;

// Flag de inicialización
bool _isInitialized = false;
```

### Opciones Base

```dart
var options = BaseOptions(
  baseUrl: Constants.uriHttp,  // https://suayed.iztacala.unam.mx/
  connectTimeout: const Duration(milliseconds: 5000),  // 5 segundos
  receiveTimeout: const Duration(milliseconds: 3000),  // 3 segundos
  receiveDataWhenStatusError: true,  // Recibir body incluso en error
);
```

## Inicialización

### Función Principal

```dart
Future<void> initHttpService({
  bool useMemoryCache = false,
  bool forceReinit = false,
}) async {
  // Si ya está inicializado y no se fuerza reinicialización, retornar
  if (_isInitialized && !forceReinit) {
    return;
  }

  // Crear el store de caché (Hive para producción, Memory para testing)
  final CacheStore cacheStore;
  if (useMemoryCache) {
    cacheStore = MemCacheStore();
    AppLogger.i('✅ HTTP service initialized with memory cache (testing mode)');
  } else {
    cacheStore = await _initHiveCacheStore();
    AppLogger.i('✅ HTTP service initialized with persistent cache');
  }

  // ... resto de configuración
  _isInitialized = true;
}
```

**Parámetros:**

- `useMemoryCache`: bool (default: false)
  - true: Cache en memoria (para testing)
  - false: Cache persistente con Hive (producción)

- `forceReinit`: bool (default: false)
  - true: Reinicializar aunque esté ya inicializado
  - false: Usar instancia existente

### Inicialización de Hive

```dart
Future<HiveCacheStore> _initHiveCacheStore() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  return HiveCacheStore(appDocDir.path);
}
```

**Ubicación del cache:**

- Android: `/data/user/0/com.suayed/app_flutter/`
- iOS: `Documents/` en app sandbox
- macOS: `Application Support/`

## Configuración de Cache

### CacheOptions

```dart
cacheOptions = CacheOptions(
  store: cacheStore,              // HiveCacheStore o MemCacheStore
  policy: CachePolicy.request,    // Política de caché (solicitud-respuesta)
  maxStale: const Duration(days: 7),  // Máximo tiempo stale: 7 días
  priority: CachePriority.normal,  // Prioridad: normal
  cipher: null,                    // Sin cifrado
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,  // Constructor de claves
  allowPostMethod: false,          // No cachear POST
);
```

**Opciones explicadas:**

| Opción | Valor | Explicación |
|--------|-------|-------------|
| `policy` | CachePolicy.request | Caché basada en solicitud/respuesta |
| `maxStale` | 7 días | Usar datos en caché hasta 7 días después de expiración |
| `priority` | normal | Prioridad normal (no urgente) |
| `cipher` | null | No cifrar datos en caché |
| `allowPostMethod` | false | Solo cachear GET, no POST |

### Políticas de Cache Disponibles

```dart
enum CachePolicy {
  noCache,        // No usar caché en absoluto
  noStore,        // No guardar en caché
  forceCache,     // Forzar uso de caché
  refreshForceCache,  // Refrescar y guardar en caché
  request,        // Política por defecto (solicitud-respuesta)
  refreshIfNotStale,  // Refrescar si no está actualizado
}
```

## Interceptadores

### DioCacheInterceptor

Maneja automáticamente el cacheo de respuestas:

```dart
dio.interceptors.add(DioCacheInterceptor(options: cacheOptions))
```

**Flujo:**

```
Request
  │
  ▼
¿Está en caché?
  │
  ├─ SÍ → ¿Está fresco?
  │        │
  │        ├─ SÍ → Retornar del caché ✅
  │        │
  │        └─ NO → ¿maxStale válido? (< 7 días)
  │                │
  │                ├─ SÍ → Retornar del caché (stale) ⚠️
  │                │
  │                └─ NO → Hacer request
  │
  └─ NO → Hacer request → Guardar en caché
```

### LoggingInterceptor

Registra todas las peticiones y respuestas:

```dart
class LoggingInterceptor extends Interceptor {
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.d('🔵 HTTP Request: ${options.method} ${options.uri}');
  }

  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.d('🟢 HTTP Response: ${response.statusCode} ${response.requestOptions.uri}');
  }

  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e('🔴 HTTP Error: ${err.type} ${err.requestOptions.uri}', err.error);
  }
}
```

**Códigos de color:**

- 🔵 Azul: Request enviado
- 🟢 Verde: Respuesta exitosa
- 🔴 Rojo: Error en la petición

## Uso en la Aplicación

### En main.dart

```dart
Future<void> main() async {
  await runZonedGuarded(() async {
    // ... otras inicializaciones

    // Inicializar servicio HTTP con cache persistente
    await initHttpService();

    // ... continuar con app
  }, (error, stack) {
    AppLogger.f('Unhandled error', error, stack);
  });
}
```

### En Servicios

```dart
import 'package:dio/dio.dart';
import 'package:suayed/services/http_service.dart';

class PostsService {
  static Future<List<PostModel>> getPosts({int page = 1}) async {
    try {
      Response response = await dio.get(
        '/posts',
        queryParameters: {'page': page},
      );
      return (response.data as List)
          .map((x) => PostModel.fromJson(x))
          .toList();
    } catch (e) {
      AppLogger.e('Error fetching posts', e);
      throw Exception("No se pudo cargar las noticias.");
    }
  }
}
```

## Ejemplo: Carga de Posts

```
HomeProvider.fetchPosts()
     │
     ▼
dio.get('/posts')
     │
     ├─ [Caché] ¿/posts está cacheado?
     │   │
     │   ├─ SÍ y está fresco → Retornar del caché (Hive)
     │   │                      ↓
     │   │                   PostModel.fromJson()
     │   │                      ↓
     │   │                   notifyListeners()
     │   │                      ↓
     │   │                   UI actualizada
     │   │
     │   └─ NO o expirado → Hacer request HTTP
     │
     └─ [Red] GET https://suayed.iztacala.unam.mx/posts
          │
          ├─ ✅ 200 OK
          │   ├─ DioCacheInterceptor guarda en Hive
          │   ├─ LoggingInterceptor registra "🟢 HTTP Response: 200"
          │   ├─ PostModel.fromJson()
          │   ├─ notifyListeners()
          │   └─ UI actualizada
          │
          └─ ❌ Error
              ├─ LoggingInterceptor registra "🔴 HTTP Error"
              ├─ AppLogger.e() registra excepción
              ├─ throw Exception("No se pudo cargar...")
              ├─ Provider captura error
              ├─ errorMessage se actualiza
              └─ UI muestra EmptyState con error
```

## Manejo de Errores

### DioException Tipos

```dart
enum DioExceptionType {
  connectionTimeout,    // Timeout al conectar
  sendTimeout,         // Timeout al enviar data
  receiveTimeout,      // Timeout al recibir data
  badResponse,         // Respuesta con error (4xx, 5xx)
  cancel,              // Request cancelada
  unknown,             // Error desconocido
}
```

### Manejo en Servicio

```dart
static Future<List<PostModel>> getPosts() async {
  try {
    Response response = await dio.request('/posts');
    return (response.data as List)
        .map((x) => PostModel.fromJson(x))
        .toList();
  } on DioException catch (e) {
    // Manejar diferentes tipos de error
    if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception("No se pudo conectar al servidor. Revisa tu conexión a internet.");
    } else if (e.type == DioExceptionType.receiveTimeout) {
      throw Exception("La respuesta tardó demasiado. Intenta de nuevo.");
    } else if (e.type == DioExceptionType.badResponse) {
      throw Exception("Error del servidor: ${e.response?.statusCode}");
    } else {
      throw Exception("Ocurrió un error inesperado. Intenta de nuevo.");
    }
  }
}
```

## Testing

### Uso de Memory Cache

```dart
// En test_main.dart o setUp de tests
setUp(() async {
  // Inicializar con cache en memoria para tests
  await initHttpService(useMemoryCache: true);
});

test('getPosts returns list of posts', () async {
  final posts = await PostsService.getPosts();
  expect(posts.isNotEmpty, true);
});
```

### Mock de Dio

```dart
import 'package:mockito/mockito.dart';

class MockDio extends Mock implements Dio {}

test('handles network error correctly', () async {
  final mockDio = MockDio();
  when(mockDio.get('/posts')).thenThrow(
    DioException(
      type: DioExceptionType.connectionTimeout,
      requestOptions: RequestOptions(path: '/posts'),
    ),
  );

  expect(
    () => PostsService.getPosts(),
    throwsA(isA<Exception>()),
  );
});
```

## Performance

### Optimización de Cache

**Ventajas:**

- Menor uso de datos (evita requests innecesarias)
- Respuesta instantánea desde caché local
- Funciona offline (con datos stale)
- Menos carga en servidor

**Desventajas:**

- Datos pueden estar desactualizados
- Mayor uso de almacenamiento local
- Requiere limpieza periódica

### Límites

```dart
// No hay límite de tamaño en CacheOptions
// Hive maneja automáticamente el crecimiento

// Sin embargo, considerar:
// - Hive crece con cada request
// - En dispositivos con poco espacio, puede ser un problema
// - Considerar implementar limpieza periódica
```

### Monitoreo

```dart
// Ver logs en Logcat
// Buscar líneas con "HTTP Request" y "HTTP Response"

AppLogger.d('🔵 HTTP Request: GET /posts?page=1');
AppLogger.d('🟢 HTTP Response: 200 https://suayed.iztacala.unam.mx/posts');
```

## Forzar Refresco

### Sin Cache

```dart
// Obtener datos frescos (bypass cache)
Response response = await dio.get(
  '/posts',
  options: Options(
    extra: {
      'noCache': true,  // Para DioCacheInterceptor
    },
  ),
);
```

### Con Cache Forzado

```dart
// Forzar uso de caché aunque esté expirado
Response response = await dio.get(
  '/posts',
  options: Options(
    extra: {
      'forceCache': true,
    },
  ),
);
```

## Límpieza de Cache

### Manual

```dart
// Limpiar todo el caché
await cacheStore.clean();

// Limpiar un endpoint específico
// (Requiere acceso al store, no implementado actualmente)
```

### Automático

```dart
// El caché automáticamente invalida datos después de 7 días
// No se requiere limpieza manual
```

## Debugging

### Ver Cache en Disco

**Android:**

```bash
adb shell
cd /data/user/0/com.suayed/app_flutter/
ls -la
```

**iOS:**

```bash
xcrun simctl spawn booted launchctl stop com.apple.SpringBoard
# O usar Xcode Device Storage
```

### Logs Detallados

```dart
// En AppLogger, filtrar por "HTTP"
// Ver todos los requests y responses
adb logcat | grep "HTTP"
```

## Buenas Prácticas

### 1. Usar Servicios, No Dio Directamente

```dart
// ✅ BIEN
final posts = await PostsService.getPosts();

// ❌ MALO - Directo en Widget
final response = await dio.get('/posts');
```

### 2. Manejar Errores Apropiadamente

```dart
// ✅ BIEN
catch (e) {
  AppLogger.e('Error', e);
  throw Exception("Mensaje en español para usuario");
}

// ❌ MALO
catch (e) {
  // Ignorar error
}
```

### 3. Usar try-catch en Servicios

```dart
// ✅ BIEN
static Future<List<PostModel>> getPosts() async {
  try {
    // ... request
  } catch (e) {
    AppLogger.e('Error fetching posts', e);
    rethrow;  // O throw Exception con mensaje español
  }
}

// ❌ MALO - Sin manejo de error
static Future<List<PostModel>> getPosts() async {
  Response response = await dio.get('/posts');
  return response.data;  // Podría fallar
}
```

### 4. Logging de Requests Importantes

```dart
// En servicio crítico
AppLogger.i('Fetching posts from API');
final posts = await PostsService.getPosts();
AppLogger.i('Successfully loaded ${posts.length} posts');
```

## Referencias

- [Dio Documentation](https://pub.dev/packages/dio)
- [dio_cache_interceptor](https://pub.dev/packages/dio_cache_interceptor)
- [http_cache_hive_store](https://pub.dev/packages/http_cache_hive_store)
- [Hive Database](https://pub.dev/packages/hive)

## Changelog

### v2.0 (Actual: 0.9.30+20260110)

- Cambio a `http_cache_hive_store` v5.0.1
- Mejor configuración de timeouts
- Logging mejorado con emojis
- Soporte para memory cache en testing

### v1.0

- Configuración básica de Dio
- Cache con dio_cache_interceptor_hive_store
- Logging interceptor
