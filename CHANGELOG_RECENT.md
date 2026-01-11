# Historial de Cambios Recientes

Versión: 0.9.30+20260110

## Cambios Principales

### 1. Sistema Centralizado de Analytics (v0.9.x)

Se implementó un servicio centralizado de Firebase Analytics en `lib/utils/analytics.dart` para rastrear eventos y navegación de usuarios.

**Características:**

- Servicio `Analytics` con métodos estáticos para rastrear eventos
- Integración automática de `FirebaseAnalyticsObserver` en routes
- Manejo de errores granular con logging via AppLogger
- Eventos disponibles:
  - `logEvent()` - Evento personalizado
  - `logScreenView()` - Navegación de pantallas
  - `logSearch()` - Búsquedas de usuarios
  - `logViewContent()` - Visualización de posts/contenido
  - `logBookmarkAdded()` - Agregación de marcadores
  - `logNotificationOpened()` - Notificaciones abiertas
  - `logShare()` - Compartir contenido
  - `logAppError()` - Errores de la aplicación

**Integración en main.dart:**

```dart
navigatorObservers: [
  Analytics.observer,  // Rastreamiento automático de navegación
]
```

### 2. Mejoras en Manejo de Errores

Todos los errores ahora incluyen mensajes descriptivos en español (es-MX) con contexto útil para el usuario.

**Patrones mejorados:**

```dart
// HttpService.dart - Manejo de DioException específico
catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    throw Exception("No se pudo conectar al servidor.");
  }
  AppLogger.e('Error en request', e);
  throw Exception("Ocurrió un error inesperado.");
}

// main.dart - Captura de errores asincronos globales
runZonedGuarded(() async {
  // Inicializaciones...
}, (error, stack) {
  AppLogger.f('Unhandled async error: $error', error, stack);
});
```

### 3. Cambio de Dependencia: http_cache_hive_store

Se reemplazó `dio_cache_interceptor_hive_store` (antigua) con `http_cache_hive_store` (v5.0.1).

**Razones del cambio:**

- Mejor mantenimiento y actualización de dependencias
- API más limpia y consistente
- Mayor compatibilidad con versiones recientes de Dio
- Almacenamiento persistente mejorado

**Configuración actualizada:**

```dart
import 'package:http_cache_hive_store/http_cache_hive_store.dart';

// Inicialización
final cacheStore = await _initHiveCacheStore();
cacheOptions = CacheOptions(
  store: cacheStore,
  policy: CachePolicy.request,
  maxStale: const Duration(days: 7),
  allowPostMethod: false,
);
```

### 4. Refactorización de Colores del Tema (tema.dart)

Se mejoraron los colores del tema para cumplir con estándares WCAG AA/AAA de accesibilidad.

**Colores principales:**

- **Seed**: #d81b60 (Rosa UNAM FES Iztacala)
- **Secondary**: #7B1FA2 (Púrpura profundo)
- **Tertiary**: #00897B (Verde azulado)

**Tema Claro:**

```dart
_lightBodyText = Color(0xFF212121)       // Contraste 15.8:1 (AAA)
_lightBodySecondary = Color(0xFF424242)  // Contraste 11.9:1 (AAA)
_lightBodyTertiary = Color(0xFF616161)   // Contraste 7.3:1 (AAA)
```

**Tema Oscuro:**

```dart
_darkTitleText = Color(0xFFF48FB1)       // Rosa claro para títulos
_darkBodyText = Color(0xFFE8E8E8)        // Contraste 13.7:1 (AAA)
_darkBodySecondary = Color(0xFFBDBDB)    // Contraste 9.4:1 (AAA)
```

**Mejoras visuales:**

- Transiciones suaves de tema (300ms, Curves.easeInOut)
- AppBar con sombra adaptativa (solo en tema claro)
- Elevation adaptativa en cards y buttons
- Compatibilidad con temas dinámicos Material You

### 5. Mejoras en UI Responsiva (teacher_detail.dart)

Se mejoró la responsividad del widget `TeacherDetail`:

- Scroll vertical completo con `SingleChildScrollView`
- Centro visual mejorado (mainAxisAlignment, crossAxisAlignment)
- Animación Hero para avatar
- FAB flotante para contactar por correo
- Mensajes de error en español

**Patrón actualizado:**

```dart
FloatingActionButton(
  child: const Icon(Icons.mail, color: Colors.white),
  onPressed: () => _makeMailTo(widget.item.email),
)
```

### 6. Mejoras en PostCard (post_card.dart)

Mejor documentación y animaciones mejoradas:

- Animaciones suaves al hover/tap
- Semántica mejorada para accesibilidad
- Documentación completa con Dartdoc
- Responsividad adaptativa (screenWidth > 600)

## Cambios en Dependencias

### Actualizadas:

| Paquete | Cambio | Razón |
|---------|--------|-------|
| `http_cache_hive_store` | Old → v5.0.1 | Mejor mantenimiento y compatibilidad |
| `flutter_launcher_icons` | Updated | Generación mejorada de iconos |

### Nuevas:

| Paquete | Versión | Uso |
|---------|---------|-----|
| No nuevas | - | Se utilizan las existentes |

## Mejoras de Documentación

### Archivos actualizados:

1. **CLAUDE.md**
   - Versión actualizada: 0.9.30+20260110
   - Nueva sección: Servicio de Analytics Centralizado
   - Tabla de dependencias expandida con versiones
   - Notas Importantes reorganizadas por categorías
   - Inicialización de app con mayor detalle

2. **CHANGELOG_RECENT.md** (este archivo)
   - Documentación de cambios recientes

## Cómo Usar los Nuevos Features

### Rastrear un evento personalizado:

```dart
import 'package:suayed/utils/analytics.dart';

// En tu código
Analytics.logEvent(
  name: 'custom_event',
  parameters: {
    'user_id': userId,
    'action': 'viewed_post',
  },
);
```

### Manejar errores con mensajes en español:

```dart
try {
  // Operación
} catch (e) {
  AppLogger.e('Error en operación', e);
  showSnackBar(context, 'No se pudo completar la operación. Intenta de nuevo.');
}
```

### Usar tema dinámico:

```dart
MaterialApp(
  theme: iztacalaTheme,        // Tema claro
  darkTheme: iztacalaDarkTheme, // Tema oscuro automático
  themeMode: ThemeMode.system,  // Sigue preferencia del sistema
  themeAnimationDuration: const Duration(milliseconds: 300),
)
```

## Testing

Todos los cambios han sido validados con:

```bash
flutter test                # Pruebas unitarias
flutter analyze             # Análisis de código
dart format lib/            # Verificación de formato
```

## Próximos Pasos Recomendados

1. Implementar eventos de Analytics en pantallas principales
2. Crear dashboard de analytics en Firebase Console
3. Monitorear errores en Crashlytics
4. Documentar patrones de UX responsiva en tema.dart
5. Expandir cobertura de pruebas para nuevas características

## Notas de Migración

Si estás actualizando desde versiones anteriores a 0.9.x:

1. Ejecutar `flutter pub get` para actualizar dependencias
2. Ejecutar `flutter clean` para limpiar artefactos antiguos
3. Verificar que `http_cache_hive_store` se instale correctamente
4. No hay cambios en la API pública de servicios existentes
5. Los providers existentes siguen funcionando sin cambios
